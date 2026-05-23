import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/notifications_remote_datasource.dart';
import '../../domain/entities/notification_entity.dart';

class NotificationsState {
  const NotificationsState({
    this.notifications = const [],
    this.unreadCount = 0,
    this.isLoading = true,
    this.isLoadingMore = false,
    this.error,
    this.currentPage = 1,
    this.hasNextPage = true,
  });

  final List<AppNotification> notifications;
  final int unreadCount;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final int currentPage;
  final bool hasNextPage;

  NotificationsState copyWith({
    List<AppNotification>? notifications,
    int? unreadCount,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    bool clearError = false,
    int? currentPage,
    bool? hasNextPage,
  }) {
    return NotificationsState(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: clearError ? null : (error ?? this.error),
      currentPage: currentPage ?? this.currentPage,
      hasNextPage: hasNextPage ?? this.hasNextPage,
    );
  }
}

final notificationsProvider =
    StateNotifierProvider.autoDispose<
      NotificationsNotifier,
      NotificationsState
    >((ref) {
      final dataSource = ref.watch(notificationsRemoteDataSourceProvider);
      final isAuthenticated = ref.watch(authProvider).isAuthenticated;
      return NotificationsNotifier(dataSource, isAuthenticated)..load();
    });

class NotificationsNotifier extends StateNotifier<NotificationsState> {
  NotificationsNotifier(this._dataSource, this._isAuthenticated)
    : super(const NotificationsState());

  final NotificationsRemoteDataSource _dataSource;
  final bool _isAuthenticated;

  Future<void> load() async {
    if (!_isAuthenticated) {
      // Guard: notifier may have been disposed before we even start
      if (!mounted) return;
      state = state.copyWith(isLoading: false);
      return;
    }

    if (!mounted) return;
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final responses = await Future.wait([
        _dataSource.getNotifications(page: 1),
        _dataSource.getUnreadCount(),
      ]);

      // Guard: user may have navigated away while the two requests were in
      // flight. The provider is autoDispose so the notifier gets disposed as
      // soon as no widget is watching it. Without this check, setting state
      // on a disposed notifier throws:
      // "Bad state: Tried to use NotificationsNotifier after dispose was called."
      if (!mounted) return;

      final paginated =
          responses[0] as dynamic; // PaginatedResponse<NotificationModel>
      final count = responses[1] as int;
      final entities = (paginated.data as List)
          .map((m) => m.toEntity())
          .toList()
          .cast<AppNotification>();

      state = state.copyWith(
        notifications: entities,
        unreadCount: count,
        isLoading: false,
        currentPage: paginated.meta.page,
        hasNextPage: paginated.hasNextPage,
      );
    } catch (e) {
      // Guard on the error path too — disposal can happen mid-catch
      if (!mounted) return;
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> fetchNextPage() async {
    if (!_isAuthenticated ||
        state.isLoading ||
        state.isLoadingMore ||
        !state.hasNextPage)
      return;

    if (!mounted) return;
    state = state.copyWith(isLoadingMore: true);

    try {
      final nextPage = state.currentPage + 1;
      final res = await _dataSource.getNotifications(page: nextPage);

      if (!mounted) return; // Guard after await
      final entities = res.data.map((m) => m.toEntity()).toList();
      state = state.copyWith(
        notifications: [...state.notifications, ...entities],
        isLoadingMore: false,
        currentPage: res.meta.page,
        hasNextPage: res.hasNextPage,
      );
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(isLoadingMore: false);
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await _dataSource.markAsRead(id);
      if (!mounted) return; // Guard after await
      // Update local state instantly
      final updatedList = state.notifications.map((n) {
        if (n.id == id && !n.isRead) {
          return AppNotification(
            id: n.id,
            type: n.type,
            title: n.title,
            message: n.message,
            data: n.data,
            isRead: true,
            readAt: DateTime.now(),
            createdAt: n.createdAt,
          );
        }
        return n;
      }).toList();
      state = state.copyWith(
        notifications: updatedList,
        unreadCount: (state.unreadCount - 1).clamp(0, 999), // Prevent negatives
      );
    } catch (_) {}
  }

  Future<void> markAllAsRead() async {
    try {
      await _dataSource.markAllAsRead();
      if (!mounted) return; // Guard after await
      final updatedList = state.notifications.map((n) {
        return AppNotification(
          id: n.id,
          type: n.type,
          title: n.title,
          message: n.message,
          data: n.data,
          isRead: true,
          readAt: n.readAt ?? DateTime.now(),
          createdAt: n.createdAt,
        );
      }).toList();
      state = state.copyWith(notifications: updatedList, unreadCount: 0);
    } catch (_) {}
  }

  Future<void> deleteNotification(String id) async {
    try {
      await _dataSource.deleteNotification(id);
      if (!mounted) return; // Guard after await
      final wasUnread =
          state.notifications.firstWhere((n) => n.id == id).isRead == false;
      final updatedList = state.notifications.where((n) => n.id != id).toList();
      state = state.copyWith(
        notifications: updatedList,
        unreadCount: wasUnread
            ? (state.unreadCount - 1).clamp(0, 999)
            : state.unreadCount,
      );
    } catch (_) {}
  }
}

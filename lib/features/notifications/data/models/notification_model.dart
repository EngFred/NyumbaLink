import '../../domain/entities/notification_entity.dart';

class NotificationModel {
  const NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    this.data,
    required this.isRead,
    this.readAt,
    required this.createdAt,
  });

  final String id;
  final String type;
  final String title;
  final String message;
  final Map<String, dynamic>? data;
  final bool isRead;
  final String? readAt;
  final String createdAt;

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      data: json['data'] as Map<String, dynamic>?,
      isRead: json['isRead'] as bool? ?? false,
      readAt: json['readAt'] as String?,
      createdAt: json['createdAt'] as String,
    );
  }

  AppNotification toEntity() {
    return AppNotification(
      id: id,
      type: type,
      title: title,
      message: message,
      data: data,
      isRead: isRead,
      readAt: readAt != null ? DateTime.tryParse(readAt!) : null,
      createdAt: DateTime.parse(createdAt),
    );
  }
}

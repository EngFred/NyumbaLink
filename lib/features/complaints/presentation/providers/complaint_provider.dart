import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/complaint_entities.dart';
import '../../domain/usecases/submit_complaint_usecase.dart';
import 'complaint_usecase_providers.dart';

class ComplaintState {
  const ComplaintState({
    this.isLoading = false,
    this.isSuccess = false,
    this.error,
  });

  final bool isLoading;
  final bool isSuccess;
  final String? error;

  ComplaintState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? error,
    bool clearError = false,
  }) {
    return ComplaintState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

final complaintProvider =
    StateNotifierProvider.autoDispose<ComplaintNotifier, ComplaintState>((ref) {
      return ComplaintNotifier(ref.watch(submitComplaintUseCaseProvider));
    });

class ComplaintNotifier extends StateNotifier<ComplaintState> {
  ComplaintNotifier(this._submitComplaint) : super(const ComplaintState());

  final SubmitComplaintUseCase _submitComplaint;

  Future<void> submit(ComplaintRequest request) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _submitComplaint(request);
      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

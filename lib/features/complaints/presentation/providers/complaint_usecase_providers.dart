import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/complaint_repository_impl.dart';
import '../../domain/usecases/submit_complaint_usecase.dart';

final submitComplaintUseCaseProvider = Provider<SubmitComplaintUseCase>((ref) {
  return SubmitComplaintUseCase(ref.watch(complaintRepositoryProvider));
});

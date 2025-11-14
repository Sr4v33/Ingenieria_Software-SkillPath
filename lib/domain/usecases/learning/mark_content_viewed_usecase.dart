// lib/domain/usecases/learning/mark_content_viewed_usecase.dart
import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../../core/constants/score_constants.dart';
import '../../repositories/progress_repository.dart';

class MarkContentViewedUseCase {
  final ProgressRepository repository;

  MarkContentViewedUseCase(this.repository);

  Future<Either<Failure, int>> execute({
    required String userId,
    required String nodeId,
  }) async {
    if (userId.isEmpty || nodeId.isEmpty) {
      return const Left(ValidationFailure('Invalid parameters'));
    }

    final result = await repository.markContentAsViewed(userId, nodeId);

    return result.fold(
          (failure) => Left(failure),
          (_) => Right(ScoreConstants.contentReadingPoints),
    );
  }
}
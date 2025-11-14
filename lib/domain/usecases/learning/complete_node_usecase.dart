// lib/domain/usecases/learning/complete_node_usecase.dart
import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../../core/constants/score_constants.dart';
import '../../repositories/progress_repository.dart';

class CompleteNodeUseCase {
  final ProgressRepository repository;

  CompleteNodeUseCase(this.repository);

  Future<Either<Failure, int>> execute({
    required String userId,
    required String nodeId,
    required int quizScore,
  }) async {
    // Validar que pasó el quiz
    if (quizScore < ScoreConstants.minimumPassingPercentage) {
      return Left(
        ValidationFailure(
          'No aprobaste el quiz. Necesitas al menos ${ScoreConstants.minimumPassingPercentage}%',
        ),
      );
    }

    final result = await repository.completeNode(userId, nodeId, quizScore);

    return result.fold(
          (failure) => Left(failure),
          (_) {
        // Calcular puntos ganados
        final points = ScoreConstants.nodeCompletionPoints +
            (quizScore * ScoreConstants.quizCompletionPoints ~/ 100);
        return Right(points);
      },
    );
  }
}
// lib/domain/usecases/learning/load_learning_path_usecase.dart
import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/learning/path_node.dart';
import '../../repositories/progress_repository.dart';

class LoadLearningPathUseCase {
  final ProgressRepository repository;

  LoadLearningPathUseCase(this.repository);

  Future<Either<Failure, List<PathNode>>> execute(String userId) async {
    if (userId.isEmpty) {
      return const Left(ValidationFailure('User ID is required'));
    }

    return await repository.loadProgress(userId);
  }
}
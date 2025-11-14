// lib/domain/repositories/progress_repository.dart
import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/learning/path_node.dart';

abstract class ProgressRepository {
  Future<Either<Failure, List<PathNode>>> loadProgress(String userId);
  Future<Either<Failure, void>> saveProgress(
      String userId,
      List<PathNode> nodes,
      );
  Future<Either<Failure, void>> markContentAsViewed(
      String userId,
      String nodeId,
      );
  Future<Either<Failure, void>> completeNode(
      String userId,
      String nodeId,
      int quizScore,
      );
  Future<Either<Failure, void>> resetProgress(String userId);
}
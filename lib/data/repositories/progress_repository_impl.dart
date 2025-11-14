// lib/data/repositories/progress_repository_impl.dart
import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/learning/path_node.dart';
import '../../domain/repositories/progress_repository.dart';
import '../datasources/local/shared_prefs_datasource.dart';
import '../datasources/remote/firestore_datasource.dart';
import '../models/path_node_model.dart';

class ProgressRepositoryImpl implements ProgressRepository {
  final FirestoreDataSource remoteDataSource;
  final SharedPrefsDataSource localDataSource;
  final NetworkInfo networkInfo;

  ProgressRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<PathNode>>> loadProgress(String userId) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteNodes = await remoteDataSource.getProgress(userId);
        await localDataSource.cacheProgress(remoteNodes);
        return Right(remoteNodes);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } on CacheException {
        // Si no hay datos remotos, intentar cache local
        return _getFromCache();
      }
    } else {
      return _getFromCache();
    }
  }

  Future<Either<Failure, List<PathNode>>> _getFromCache() async {
    try {
      final localNodes = await localDataSource.getCachedProgress();
      return Right(localNodes);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> saveProgress(
      String userId,
      List<PathNode> nodes,
      ) async {
    try {
      final nodeModels = nodes.map((n) => PathNodeModel.fromEntity(n)).toList();

      // Guardar localmente siempre
      await localDataSource.cacheProgress(nodeModels);

      // Si hay internet, sincronizar
      if (await networkInfo.isConnected) {
        await remoteDataSource.saveProgress(userId, nodeModels);
      }

      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> markContentAsViewed(
      String userId,
      String nodeId,
      ) async {
    try {
      final progressResult = await loadProgress(userId);

      return progressResult.fold(
            (failure) => Left(failure),
            (nodes) async {
          final updatedNodes = nodes.map((node) {
            if (node.id == nodeId) {
              return node.markContentAsViewed();
            }
            return node;
          }).toList();

          return saveProgress(userId, updatedNodes);
        },
      );
    } catch (e) {
      return Left(ServerFailure('Error marking content as viewed: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> completeNode(
      String userId,
      String nodeId,
      int quizScore,
      ) async {
    try {
      final progressResult = await loadProgress(userId);

      return progressResult.fold(
            (failure) => Left(failure),
            (nodes) async {
          final updatedNodes = nodes.map((node) {
            if (node.id == nodeId) {
              return node.complete(quizScore: quizScore);
            }
            return node;
          }).toList();

          return saveProgress(userId, updatedNodes);
        },
      );
    } catch (e) {
      return Left(ServerFailure('Error completing node: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> resetProgress(String userId) async {
    try {
      await localDataSource.clearCache();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Error resetting progress: $e'));
    }
  }
}
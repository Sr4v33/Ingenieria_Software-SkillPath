// lib/data/datasources/remote/firestore_datasource.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/errors/exceptions.dart';
import '../../models/path_node_model.dart';

abstract class FirestoreDataSource {
  Future<List<PathNodeModel>> getProgress(String userId);
  Future<void> saveProgress(String userId, List<PathNodeModel> nodes);
}

class FirestoreDataSourceImpl implements FirestoreDataSource {
  final FirebaseFirestore firestore;

  FirestoreDataSourceImpl({required this.firestore});

  @override
  Future<List<PathNodeModel>> getProgress(String userId) async {
    try {
      final doc = await firestore
          .collection('users')
          .doc(userId)
          .collection('progress')
          .doc('nodes')
          .get();

      if (!doc.exists || doc.data() == null) {
        throw CacheException('No progress found for user');
      }

      final nodesData = doc.data()?['nodes'] as List?;
      if (nodesData == null || nodesData.isEmpty) {
        throw CacheException('Empty progress data');
      }

      return nodesData
          .map((node) => PathNodeModel.fromJson(node as Map<String, dynamic>))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Firebase error');
    } catch (e) {
      if (e is CacheException) rethrow;
      throw ServerException('Error fetching progress: $e');
    }
  }

  @override
  Future<void> saveProgress(String userId, List<PathNodeModel> nodes) async {
    try {
      final nodesRef = firestore
          .collection('users')
          .doc(userId)
          .collection('progress')
          .doc('nodes');

      await nodesRef.set({
        'nodes': nodes.map((n) => n.toJson()).toList(),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Firebase error');
    } catch (e) {
      throw ServerException('Error saving progress: $e');
    }
  }
}
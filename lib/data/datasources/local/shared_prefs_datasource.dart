// lib/data/datasources/local/shared_prefs_datasource.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/errors/exceptions.dart';
import '../../models/path_node_model.dart';

abstract class SharedPrefsDataSource {
  Future<List<PathNodeModel>> getCachedProgress();
  Future<void> cacheProgress(List<PathNodeModel> nodes);
  Future<void> clearCache();
}

class SharedPrefsDataSourceImpl implements SharedPrefsDataSource {
  final SharedPreferences sharedPreferences;
  static const String _nodesKey = 'CACHED_NODES';

  SharedPrefsDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<PathNodeModel>> getCachedProgress() async {
    final jsonString = sharedPreferences.getString(_nodesKey);

    if (jsonString == null) {
      throw CacheException('No cached progress found');
    }

    try {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList
          .map((json) => PathNodeModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw CacheException('Error parsing cached progress: $e');
    }
  }

  @override
  Future<void> cacheProgress(List<PathNodeModel> nodes) async {
    try {
      final jsonList = nodes.map((node) => node.toJson()).toList();
      final jsonString = json.encode(jsonList);
      await sharedPreferences.setString(_nodesKey, jsonString);
    } catch (e) {
      throw CacheException('Error caching progress: $e');
    }
  }

  @override
  Future<void> clearCache() async {
    await sharedPreferences.remove(_nodesKey);
  }
}
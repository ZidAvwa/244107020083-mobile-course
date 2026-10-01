import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:sqflite/sqflite.dart';

import '../local/db.dart';
import '../post.dart';

class PostRepository {
  PostRepository({Future<Database> Function()? openDb, Dio? dio})
      : _openDb = openDb ?? openNotesDb,
        _dio = dio ?? Dio();

  final Future<Database> Function() _openDb;
  final Dio _dio;

  /// Reads posts from the local cached_posts table.
  Future<List<Post>> readCachedPosts() async {
    final db = await _openDb();
    final rows = await db.query('cached_posts', orderBy: 'id');
    return rows
        .map((r) => Post.fromJson(
            jsonDecode(r['payload'] as String) as Map<String, dynamic>))
        .toList();
  }

  /// Fetches posts from the API and saves them into cached_posts.
  Future<void> refreshPosts() async {
    final res = await _dio.get('https://jsonplaceholder.typicode.com/posts');
    final db = await _openDb();
    final now = DateTime.now().toIso8601String();
    final batch = db.batch();
    for (final p in res.data as List) {
      batch.insert(
        'cached_posts',
        {'id': p['id'], 'payload': jsonEncode(p), 'cached_at': now},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }
}

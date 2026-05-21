import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'signal_cache_service.dart';

// Firebase note: If you want to enable Firebase Firestore sync:
// 1. Add cloud_firestore package to pubspec.yaml
// 2. Initialize Firebase in main.dart
// 3. Uncomment/add Firestore calls inside the load/save methods below.

class PostDatabaseService {
  PostDatabaseService._internal();
  static final PostDatabaseService instance = PostDatabaseService._internal();

  static const _postsKey = 'ciro.database.posts';

  /// Saves a user post locally (with optional Firebase Firestore sync).
  Future<void> savePost({
    required String author,
    required String handle,
    required String title,
    required String body,
    required String location,
    required String tag,
    required String iconName,
    required String colorHex,
    int? avatarIndex,
    String? customAvatarUrl,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> savedList = prefs.getStringList(_postsKey) ?? [];

      final postMap = {
        'author': author,
        'handle': handle,
        'time': 'now',
        'title': title,
        'body': body,
        'location': location,
        'tag': tag,
        'iconName': iconName,
        'colorHex': colorHex,
        'avatarIndex': avatarIndex,
        'customAvatarUrl': customAvatarUrl,
        'latitude': latitude,
        'longitude': longitude,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      savedList.insert(0, jsonEncode(postMap));
      await prefs.setStringList(_postsKey, savedList);
      await SignalCacheService.instance.cacheUserReport(
        title: title,
        body: body,
        location: location,
        tag: tag,
        latitude: latitude,
        longitude: longitude,
      );

      // ───────────────────────────────────────────────────────────────────────
      // FIREBASE SYNC HOOK (Uncomment when Firebase cloud_firestore is added):
      // ───────────────────────────────────────────────────────────────────────
      // await FirebaseFirestore.instance.collection('posts').add({
      //   ...postMap,
      //   'timestamp': FieldValue.serverTimestamp(),
      // });
      
    } catch (e) {
      debugPrint('Error saving post to local database: $e');
    }
  }

  /// Loads all user posts (with optional Firebase Firestore fallback).
  Future<List<Map<String, dynamic>>> loadPosts() async {
    try {
      // ───────────────────────────────────────────────────────────────────────
      // FIREBASE RETRIEVAL HOOK (Uncomment when Firebase is ready):
      // ───────────────────────────────────────────────────────────────────────
      // final snapshot = await FirebaseFirestore.instance
      //     .collection('posts')
      //     .orderBy('timestamp', descending: true)
      //     .get();
      // return snapshot.docs.map((doc) => doc.data()).toList();

      final prefs = await SharedPreferences.getInstance();
      final List<String> savedList = prefs.getStringList(_postsKey) ?? [];

      return savedList.map((str) {
        return jsonDecode(str) as Map<String, dynamic>;
      }).toList();
    } catch (e) {
      debugPrint('Error loading posts from database: $e');
      return [];
    }
  }

  /// Clears database (e.g. on sign-out/reset)
  Future<void> clearDatabase() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_postsKey);
  }
}

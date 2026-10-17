import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:developer' as developer;

enum StorageKey {
  accessToken,
  refreshToken,
  isBlocked,
  districtId,
  username,
  userId,
  isSpecialUser, // Специальный пользователь (может загружать фото с галереи)
  limitKm, // Лимит координат в км
  fcmToken, // Firebase Cloud Messaging token
}

class AppStorage {
  factory AppStorage() => _service;

  AppStorage._internal();

  static final AppStorage _service = AppStorage._internal();
  static final FlutterSecureStorage _secureStorage =
      const FlutterSecureStorage();

  // Keys for secure storage (sensitive data)
  static const String _secureKeyAccessToken = 'access_token';
  static const String _secureKeyRefreshToken = 'refresh_token';

  static Future<SharedPreferences> _getPrefs() async {
    return await SharedPreferences.getInstance();
  }

  // ===== SECURE STORAGE METHODS (for tokens) =====

  /// Read access token from secure storage
  static Future<String?> $readSecureToken(
      {required bool isRefreshToken}) async {
    try {
      final key =
          isRefreshToken ? _secureKeyRefreshToken : _secureKeyAccessToken;
      return await _secureStorage.read(key: key);
    } catch (e) {
      developer.log('Error reading secure token: $e');
      return null;
    }
  }

  /// Write access token to secure storage
  static Future<void> $writeSecureToken({
    required bool isRefreshToken,
    required String value,
  }) async {
    try {
      final key =
          isRefreshToken ? _secureKeyRefreshToken : _secureKeyAccessToken;
      await _secureStorage.write(key: key, value: value);
    } catch (e) {
      developer.log('Error writing secure token: $e');
    }
  }

  /// Delete tokens from secure storage
  static Future<void> $deleteSecureTokens() async {
    try {
      await _secureStorage.delete(key: _secureKeyAccessToken);
      await _secureStorage.delete(key: _secureKeyRefreshToken);
    } catch (e) {
      developer.log('Error deleting secure tokens: $e');
    }
  }

  // ===== MIGRATION: Move tokens from SharedPreferences to Secure Storage =====

  /// Migrate tokens from SharedPreferences to SecureStorage
  /// This is a one-time migration for backward compatibility
  static Future<void> _migrateTokensIfNeeded() async {
    try {
      final prefs = await _getPrefs();

      // Check if tokens exist in SharedPreferences
      final oldAccessToken = prefs.getString(StorageKey.accessToken.name);
      final oldRefreshToken = prefs.getString(StorageKey.refreshToken.name);

      // Check if tokens already migrated (exist in secure storage)
      final newAccessToken =
          await _secureStorage.read(key: _secureKeyAccessToken);

      // If old tokens exist and new ones don't, migrate
      if ((oldAccessToken != null || oldRefreshToken != null) &&
          newAccessToken == null) {
        developer
            .log('Migrating tokens from SharedPreferences to SecureStorage...');

        if (oldAccessToken != null) {
          await _secureStorage.write(
              key: _secureKeyAccessToken, value: oldAccessToken);
          developer.log('Access token migrated');
        }

        if (oldRefreshToken != null) {
          await _secureStorage.write(
              key: _secureKeyRefreshToken, value: oldRefreshToken);
          developer.log('Refresh token migrated');
        }

        // Remove old tokens from SharedPreferences after successful migration
        await prefs.remove(StorageKey.accessToken.name);
        await prefs.remove(StorageKey.refreshToken.name);
        developer.log('Old tokens removed from SharedPreferences');
      }
    } catch (e) {
      developer.log('Error during token migration: $e');
    }
  }

  // ===== LEGACY METHODS (for non-sensitive data) =====

  static Future<String?> $read({required StorageKey key}) async {
    // Handle token keys specially
    if (key == StorageKey.accessToken) {
      // Ensure migration is done
      await _migrateTokensIfNeeded();
      return await $readSecureToken(isRefreshToken: false);
    }
    if (key == StorageKey.refreshToken) {
      await _migrateTokensIfNeeded();
      return await $readSecureToken(isRefreshToken: true);
    }

    // Non-sensitive data uses SharedPreferences
    final prefs = await _getPrefs();
    return prefs.getString(key.name);
  }

  static Future<void> $write(
      {required StorageKey key, required String value}) async {
    // Handle token keys specially
    if (key == StorageKey.accessToken) {
      await $writeSecureToken(isRefreshToken: false, value: value);
      return;
    }
    if (key == StorageKey.refreshToken) {
      await $writeSecureToken(isRefreshToken: true, value: value);
      return;
    }

    // Non-sensitive data uses SharedPreferences
    final prefs = await _getPrefs();
    await prefs.setString(key.name, value);
  }

  static Future<bool?> $readBool({required StorageKey key}) async {
    final prefs = await _getPrefs();
    return prefs.getBool(key.name);
  }

  static Future<void> $writeBool(
      {required StorageKey key, required bool value}) async {
    final prefs = await _getPrefs();
    await prefs.setBool(key.name, value);
  }

  static Future<int?> $readInt({required StorageKey key}) async {
    final prefs = await _getPrefs();
    return prefs.getInt(key.name);
  }

  static Future<void> $writeInt(
      {required StorageKey key, required int value}) async {
    final prefs = await _getPrefs();
    await prefs.setInt(key.name, value);
  }

  static Future<double?> $readDouble({required StorageKey key}) async {
    final prefs = await _getPrefs();
    final value = prefs.getDouble(key.name);
    return value;
  }

  static Future<void> $writeDouble(
      {required StorageKey key, required double value}) async {
    final prefs = await _getPrefs();
    await prefs.setDouble(key.name, value);
  }

  /// Clear all data (both secure and non-secure)
  static Future<void> clearAllData() async {
    try {
      // Full logout: wipe the whole secure storage, not just the token keys.
      await _secureStorage.deleteAll();

      // Clear SharedPreferences
      final prefs = await _getPrefs();
      await prefs.clear();
    } catch (e) {
      developer.log('Error clearing all data: $e');
    }
  }

  static Future<void> $delete({required StorageKey key}) async {
    // Handle token keys specially
    if (key == StorageKey.accessToken || key == StorageKey.refreshToken) {
      await $deleteSecureTokens();
      return;
    }

    // Non-sensitive data
    final prefs = await _getPrefs();
    await prefs.remove(key.name);
  }

  /// Initialize storage - call this on app start to ensure migration
  static Future<void> initialize() async {
    await _migrateTokensIfNeeded();
  }
}

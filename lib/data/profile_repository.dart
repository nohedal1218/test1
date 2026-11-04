import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/player_profile.dart';

class ProfileRepository {
  static const String _profileKey = 'tech_quest_player_profile';

  final SharedPreferencesAsync _preferences = SharedPreferencesAsync();

  Future<PlayerProfile?> loadProfile() async {
    final raw = await _preferences.getString(_profileKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('저장된 사용자 정보 형식이 올바르지 않습니다.');
      }
      return PlayerProfile.fromJson(decoded);
    } on FormatException {
      await _preferences.remove(_profileKey);
      return null;
    }
  }

  Future<void> saveProfile(PlayerProfile profile) async {
    await _preferences.setString(_profileKey, jsonEncode(profile.toJson()));
  }

  Future<void> clearProfile() async {
    await _preferences.remove(_profileKey);
  }
}

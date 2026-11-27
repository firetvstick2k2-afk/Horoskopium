import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/birth_profile.dart';

class ProfileStore {
  static const _storageKey = 'horoskopium.birth_profiles.v1';

  Future<List<BirthProfile>> loadProfiles() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_storageKey);
    if (raw == null || raw.isEmpty) return [];

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((item) => BirthProfile.fromJson(
                Map<String, dynamic>.from(item as Map),
              ))
          .toList();
    } on FormatException {
      return [];
    } on TypeError {
      return [];
    }
  }

  Future<void> saveProfiles(List<BirthProfile> profiles) async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = jsonEncode(profiles.map((profile) => profile.toJson()).toList());
    await preferences.setString(_storageKey, encoded);
  }
}

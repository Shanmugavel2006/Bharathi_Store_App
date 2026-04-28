import 'package:flutter/material.dart';

class UserSettingsProvider with ChangeNotifier {
  String _profileImageUrl = '';
  int _selectedAvatarIndex = 0;

  final List<String> defaultAvatars = [
    'https://cdn-icons-png.flaticon.com/512/4140/4140048.png',
    'https://cdn-icons-png.flaticon.com/512/4140/4140037.png',
    'https://cdn-icons-png.flaticon.com/512/4140/4140051.png',
    'https://cdn-icons-png.flaticon.com/512/4140/4140047.png',
    'https://cdn-icons-png.flaticon.com/512/4140/4140061.png',
  ];

  String get profileImageUrl => _profileImageUrl.isEmpty ? defaultAvatars[_selectedAvatarIndex] : _profileImageUrl;
  int get selectedAvatarIndex => _selectedAvatarIndex;

  void setAvatarIndex(int index) {
    if (index >= 0 && index < defaultAvatars.length) {
      _selectedAvatarIndex = index;
      _profileImageUrl = ''; // Clear custom URL if selecting a default
      notifyListeners();
    }
  }

  void setCustomProfileImage(String url) {
    _profileImageUrl = url;
    notifyListeners();
  }
}

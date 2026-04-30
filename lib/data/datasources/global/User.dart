import 'package:flutter/material.dart';

import '../DTOs/UserDTO.dart';

class UserProvider extends ChangeNotifier {
  UserModelDTO? _user;

  UserModelDTO? get user => _user;
  void setUser(UserModelDTO user) {
    _user = user;
    notifyListeners();
  }
  void clearUser() {
    _user = null;
    notifyListeners();
  }
}
//reference our box
import 'package:hive_flutter/hive_flutter.dart';

final _userBox = Hive.box("User_Database");

class UserDatabase {
  bool isUserLogginInFirstTime = true;

  //create initial default data
  void putUserStatusFirstTime() {
    if (_userBox.get("USER_LOGIN_FIRST") == null) {
      isUserLogginInFirstTime = true;
      _userBox.put("USER_LOGIN_FIRST", isUserLogginInFirstTime);
    }
  }

  void getUserStatusFirstTime() {
    var check = _userBox.get("USER_LOGIN_FIRST");
    if (check != null) {
      isUserLogginInFirstTime = false;
    }
  }

  void putUserStatusOnLogout() {
    if (_userBox.get("USER_LOGIN_FIRST") != null) {
      isUserLogginInFirstTime = true;
      _userBox.put("USER_LOGIN_FIRST", isUserLogginInFirstTime);
    }
  }
}

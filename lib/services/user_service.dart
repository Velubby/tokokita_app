import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  static Future<bool> isNewUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isNewUser') ?? true; // Default to true if not set
  }

  static Future<void> setUserStatus(bool isNew) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isNewUser', isNew);
  }
}

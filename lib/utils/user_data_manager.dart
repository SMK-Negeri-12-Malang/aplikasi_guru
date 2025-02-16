import 'package:shared_preferences/shared_preferences.dart';

class UserDataManager {
  static final String NAME_KEY = 'user_name';
  static final String EMAIL_KEY = 'user_email';

  static Future<void> saveUserData(String name, String email) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(NAME_KEY, name);
    await prefs.setString(EMAIL_KEY, email);
  }

  static Future<Map<String, String>> getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString(NAME_KEY) ?? 'User',
      'email': prefs.getString(EMAIL_KEY) ?? 'user@example.com',
    };
  }
}

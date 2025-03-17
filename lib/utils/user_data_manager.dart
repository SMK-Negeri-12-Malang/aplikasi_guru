import 'package:shared_preferences/shared_preferences.dart';

class UserDataManager {
  static final String NAME_KEY = 'user_name';
  static final String EMAIL_KEY = 'user_email';

  static Future<void> saveUserData(String name, String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(NAME_KEY, name);
    await prefs.setString(EMAIL_KEY, email);
    await prefs.setString('user_password', password); // Tambah password
    await prefs.setBool('is_logged_in', true);
  }

  static Future<Map<String, String>> getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString(NAME_KEY) ?? 'User',
      'email': prefs.getString(EMAIL_KEY) ?? 'user@example.com',
    };
  }
  
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email');
    return email != null;
  }

  static getUserEmail() {}

  static Future<String?> getUserPassword() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_password');
  }
}

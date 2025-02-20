import 'package:http/http.dart' as http;
import 'dart:convert';
import '../MODELS/guru_model.dart';
import '../MODELS/musyrif_model.dart';

class AuthService {
  static const String guruApiUrl = 'https://677d1f084496848554c91eb9.mockapi.io/Guru';
  static const String musyrifApiUrl = 'https://677d1f084496848554c91eb9.mockapi.io/Musryf';

  Future<(GuruModel?, MusyrifModel?)> login(String email, String password) async {
    // Try login as guru
    try {
      final guruResponse = await http.get(Uri.parse(guruApiUrl));
      if (guruResponse.statusCode == 200) {
        final List<dynamic> guruList = json.decode(guruResponse.body);
        final guru = guruList.firstWhere(
          (guru) => guru['email'] == email && guru['password'] == password,
          orElse: () => null,
        );
        if (guru != null) {
          return (GuruModel.fromJson(guru), null);
        }
      }
    } catch (e) {
      print('Guru login error: $e');
    }

    // Try login as musyrif
    try {
      final musyrifResponse = await http.get(Uri.parse(musyrifApiUrl));
      if (musyrifResponse.statusCode == 200) {
        final List<dynamic> musyrifList = json.decode(musyrifResponse.body);
        final musyrif = musyrifList.firstWhere(
          (musyrif) => musyrif['email'] == email && musyrif['password'] == password,
          orElse: () => null,
        );
        if (musyrif != null) {
          return (null, MusyrifModel.fromJson(musyrif));
        }
      }
    } catch (e) {
      print('Musyrif login error: $e');
    }

    return (null, null);
  }
}

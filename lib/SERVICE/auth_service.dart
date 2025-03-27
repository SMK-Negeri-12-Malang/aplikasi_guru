import 'package:aplikasi_guru/MODELS/guru_model.dart';
import 'package:aplikasi_guru/MODELS/guru_quran_model.dart';
import 'package:aplikasi_guru/MODELS/musyrif_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class AuthService {
  static const String guruApiUrl = 'https://677d1f084496848554c91eb9.mockapi.io/Guru';
  static const String musyrifApiUrl = 'https://677d1f084496848554c91eb9.mockapi.io/Musryf';
  static const String guruQuranApiUrl = 'https://67e4bcd02ae442db76d56140.mockapi.io/login/guru_quran';

  Future<(GuruModel?, MusyrifModel?, GuruQuran?)> login(String email, String password) async {
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
          return (GuruModel.fromJson(guru), null, null);
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
          return (null, MusyrifModel.fromJson(musyrif), null);
        }
      }
    } catch (e) {
      print('Musyrif login error: $e');
    }
    
    // Try login as guru quran
    try {
      final guruQuranResponse = await http.get(Uri.parse(guruQuranApiUrl));
      if (guruQuranResponse.statusCode == 200) {
        final List<dynamic> guruQuranList = json.decode(guruQuranResponse.body);
        final guruQuran = guruQuranList.firstWhere(
          (guruQuran) => guruQuran['email'] == email && guruQuran['password'] == password,
          orElse: () => null,
        );
        if (guruQuran != null) {
          return (null, null, GuruQuran.fromJson(guruQuran));
        }
      }
    } catch (e) {
      print('Guru Quran login error: $e');
    }

    return (null, null, null);
  }
}

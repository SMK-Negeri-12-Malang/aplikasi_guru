import 'package:aplikasi_guru/MODELS/class_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class ClassService {
  final String baseUrl = 'https://67ac42f05853dfff53d9e093.mockapi.io/kalas';

  Future<List<ClassModel>> getClasses() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => ClassModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load classes');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}

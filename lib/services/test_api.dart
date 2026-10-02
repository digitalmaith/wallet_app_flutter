import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class TestApi {
  static Future<void> ping() async {
    try {
      final res = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/inscription'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'telephone': '+221763104000',
          'email': 'digitalmaith@gmail.com',
        }),
      );
      print('✅ STATUS: ${res.statusCode}');
      print('✅ BODY: ${res.body}');
    } catch (e) {
      print('❌ ERREUR: $e');
    }
  }
}
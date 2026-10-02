import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class AuthService {
  // 1️⃣ INSCRIPTION
  static Future<Map<String, dynamic>> inscription({
    required String telephone,
    required String email,
  }) async {
    final res = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/inscription'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'telephone': telephone, 'email': email}),
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    // Essaie de récupérer le message d'erreur du back
    try {
      final err = jsonDecode(res.body);
      throw Exception(err['message'] ?? 'Inscription échouée');
    } catch (_) {
      throw Exception('Inscription échouée (${res.statusCode})');
    }
  }

  // 2️⃣ VÉRIFIER OTP
  static Future<void> verifierOtp({
    required String destinataire,
    required String type,
    required String code,
  }) async {
    final res = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/otp/verifier'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'destinataire': destinataire,
        'type': type,
        'code': code,
      }),
    );
    if (res.statusCode != 200) {
      try {
        final err = jsonDecode(res.body);
        throw Exception(err['message'] ?? 'Code invalide');
      } catch (_) {
        throw Exception('Code OTP invalide');
      }
    }
  }

  // 3️⃣ CRÉER PIN
  static Future<String> creerPin({
    required String telephone,
    required String pin,
  }) async {
    final res = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/pin/creer'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'telephone': telephone, 'pin': pin}),
    );
    if (res.statusCode == 200 || res.statusCode == 201) {
      final data = jsonDecode(res.body);
      final token = data['token'] as String;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      await prefs.setString('telephone', telephone);

      return token;
    }
    try {
      final err = jsonDecode(res.body);
      throw Exception(err['message'] ?? 'Création PIN échouée');
    } catch (_) {
      throw Exception('Création PIN échouée (${res.statusCode})');
    }
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

    // 4️⃣ LOGIN
  static Future<String> login({
    required String telephone,
    required String pin,
  }) async {
    final res = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'telephone': telephone,
        'pin': pin,
      }),
    );

    if (res.statusCode == 200 || res.statusCode == 201) {
      final data = jsonDecode(res.body);
      final token = data['token'] as String;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      await prefs.setString('telephone', telephone);

      return token;
    }

    try {
      final err = jsonDecode(res.body);
      throw Exception(err['message'] ?? 'Connexion échouée');
    } catch (_) {
      throw Exception('Identifiants incorrects');
    }
  }
}
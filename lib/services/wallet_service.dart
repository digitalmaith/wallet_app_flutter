import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/wallet_model.dart';

class WalletService {
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // 🔹 SOLDE
  static Future<SoldeModel> getSolde() async {
    final token = await _getToken();
    if (token == null) throw Exception('Non connecté');

    final res = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/wallet/solde'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode == 200) {
      return SoldeModel.fromJson(jsonDecode(res.body));
    }
    throw Exception('Erreur solde (${res.statusCode})');
  }

  // 🔹 TRANSACTIONS
  static Future<List<TransactionModel>> getTransactions() async {
    final token = await _getToken();
    if (token == null) throw Exception('Non connecté');

    final res = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/wallet/transactions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => TransactionModel.fromJson(e)).toList();
    }
    throw Exception('Erreur transactions (${res.statusCode})');
  }

    // 🔹 DÉPÔT
  static Future<TransactionModel> depot({required double montant}) async {
    final token = await _getToken();
    if (token == null) throw Exception('Non connecté');

    final res = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/wallet/depot'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'montant': montant}),
    );

    if (res.statusCode == 200 || res.statusCode == 201) {
      return TransactionModel.fromJson(jsonDecode(res.body));
    }
    try {
      final err = jsonDecode(res.body);
      throw Exception(err['message'] ?? 'Dépôt échoué');
    } catch (_) {
      throw Exception('Dépôt échoué (${res.statusCode})');
    }
  }

  // 🔹 RETRAIT
  static Future<TransactionModel> retrait({
    required double montant,
    required String pin,
  }) async {
    final token = await _getToken();
    if (token == null) throw Exception('Non connecté');

    final res = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/wallet/retrait'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'montant': montant, 'pin': pin}),
    );

    if (res.statusCode == 200 || res.statusCode == 201) {
      return TransactionModel.fromJson(jsonDecode(res.body));
    }
    try {
      final err = jsonDecode(res.body);
      throw Exception(err['message'] ?? 'Retrait échoué');
    } catch (_) {
      throw Exception('Retrait échoué (${res.statusCode})');
    }
  }
}
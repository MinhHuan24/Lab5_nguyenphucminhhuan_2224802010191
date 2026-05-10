import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/config.dart';

class AuthService {

  Future<bool> register(
      String email,
      String password) async {

    final response = await http.post(
      Uri.parse(
          "${Config.baseUrl}/auth/register"),
      headers: {
        "Content-Type": "application/json"
      },
      body: jsonEncode({
        "email": email,
        "password": password
      }),
    );

    return response.statusCode == 200;
  }

  Future<bool> login(
      String email,
      String password) async {

    final response = await http.post(
      Uri.parse(
          "${Config.baseUrl}/auth/login"),
      headers: {
        "Content-Type": "application/json"
      },
      body: jsonEncode({
        "email": email,
        "password": password
      }),
    );

    if (response.statusCode == 200) {

      final data =
          jsonDecode(response.body);

      SharedPreferences prefs =
          await SharedPreferences.getInstance();

      await prefs.setString(
          "token",
          data['token']);

      return true;
    }

    return false;
  }

  Future<void> logout() async {

    SharedPreferences prefs =
        await SharedPreferences.getInstance();

    await prefs.remove("token");
  }

  Future<String?> getToken() async {

    SharedPreferences prefs =
        await SharedPreferences.getInstance();

    return prefs.getString("token");
  }
}
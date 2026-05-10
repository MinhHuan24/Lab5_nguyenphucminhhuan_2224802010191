import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/config.dart';
import '../models/todo_model.dart';

class TodoService {

  Future<List<TodoModel>> getTodos() async {

    SharedPreferences prefs =
        await SharedPreferences.getInstance();

    String token = prefs.getString("token")!;

    final response = await http.get(
      Uri.parse("${Config.baseUrl}/todo"),
      headers: {
        "Authorization": "Bearer $token"
      },
    );

    if (response.statusCode == 200) {

      List data = jsonDecode(response.body);

      return data
          .map((e) => TodoModel.fromJson(e))
          .toList();
    }

    return [];
  }

  Future<bool> addTodo(String title) async {

    SharedPreferences prefs =
        await SharedPreferences.getInstance();

    String token = prefs.getString("token")!;

    final response = await http.post(
      Uri.parse("${Config.baseUrl}/todo"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
      body: jsonEncode({
        "title": title
      }),
    );

    return response.statusCode == 200;
  }
}
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class UserService {
  static const baseUrl = "https://luminacine-be-901699795850.us-central1.run.app";

  static Future<User> getUserProfile(int idUser) async {
    final response = await http.get(Uri.parse("$baseUrl/users/$idUser"));
    final body = jsonDecode(response.body);
    return User.fromJson(body['data']);
  }
}
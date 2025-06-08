import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/seat_model.dart';

class SeatService {
  static const baseUrl = "https://luminacine-be-901699795850.us-central1.run.app";

  static Future<List<Seat>> getSeatsBySchedule(int scheduleId) async {
    final response = await http.get(Uri.parse("$baseUrl/seats/schedule/$scheduleId/status"));
    final body = jsonDecode(response.body);
    if (body['status'] == 'Success') {
      return SeatModel.fromJson(body).data ?? [];
    } else {
      throw Exception("Failed to load seats");
    }
  }
}

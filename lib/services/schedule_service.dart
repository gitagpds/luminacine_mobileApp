import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/schedule_model.dart';

class ScheduleService {
  static const baseUrl =
      "https://luminacine-be-901699795850.us-central1.run.app";

  // ✅ GET /movies/:movieId/schedules
  static Future<List<Schedule>> getSchedulesByMovieId(int movieId) async {
    final response =
        await http.get(Uri.parse("$baseUrl/movies/$movieId/schedules"));
    final body = jsonDecode(response.body);
    if (body['status'] == 'Success') {
      return ScheduleModel.fromJson(body).data ?? [];
    } else {
      throw Exception("Failed to load schedules");
    }
  }

  // ✅ GET /movies/:movieId/schedules/:id
  static Future<Schedule> getScheduleDetail(int movieId, int scheduleId) async {
    final response = await http
        .get(Uri.parse("$baseUrl/movies/$movieId/schedules/$scheduleId"));
    final body = jsonDecode(response.body);
    return Schedule.fromJson(body['data']);
  }

  // ✅ POST /movies/:movieId/schedules
  static Future<Schedule> createSchedule(
      int movieId, Map<String, dynamic> schedulePayload) async {
    final response = await http.post(
      Uri.parse("$baseUrl/movies/$movieId/schedules"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(schedulePayload),
    );
    final body = jsonDecode(response.body);
    return Schedule.fromJson(body['data']);
  }

  // ✅ PUT /movies/:movieId/schedules/:id
  static Future<Schedule> updateSchedule(
      int movieId, int scheduleId, Map<String, dynamic> updatedPayload) async {
    final response = await http.put(
      Uri.parse("$baseUrl/movies/$movieId/schedules/$scheduleId"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(updatedPayload),
    );
    final body = jsonDecode(response.body);
    return Schedule.fromJson(body['data']);
  }

  // ✅ DELETE /schedules/:id
  static Future<void> deleteSchedule(int scheduleId) async {
    final response =
        await http.delete(Uri.parse("$baseUrl/schedules/$scheduleId"));
    if (response.statusCode != 200) {
      throw Exception("Failed to delete schedule");
    }
  }
}

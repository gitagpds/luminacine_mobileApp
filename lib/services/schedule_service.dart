import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/schedule_model.dart';

class ScheduleService {
  static const baseUrl = "https://luminacine-be-901699795850.us-central1.run.app";

  static Future<List<Schedule>> getSchedulesByMovieId(int movieId) async {
    final response = await http.get(Uri.parse("$baseUrl/movies/$movieId/schedules"));
    final body = jsonDecode(response.body);
    if (body['status'] == 'Success') {
      return ScheduleModel.fromJson(body).data ?? [];
    } else {
      throw Exception("Failed to load schedules");
    }
  }

  static Future<Schedule> getScheduleDetail(int movieId, int scheduleId) async {
    final response = await http.get(Uri.parse("$baseUrl/movies/$movieId/schedules/$scheduleId"));
    return Schedule.fromJson(jsonDecode(response.body));
  }
}
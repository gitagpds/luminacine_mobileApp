import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/seat_model.dart';

class SeatService {
  static const baseUrl =
      "https://luminacine-be-901699795850.us-central1.run.app";

  // ✅ GET /seats?scheduleId=...
  static Future<List<Seat>> getSeats({int? scheduleId}) async {
    final url = scheduleId != null
        ? "$baseUrl/seats?scheduleId=$scheduleId"
        : "$baseUrl/seats";
    final response = await http.get(Uri.parse(url));
    final body = jsonDecode(response.body);
    if (body['status'] == 'Success') {
      return SeatModel.fromJson(body).data ?? [];
    } else {
      throw Exception("Failed to load seats");
    }
  }

  // ✅ GET /seats/schedule/:scheduleId
  static Future<List<Seat>> getSeatsByScheduleId(int scheduleId) async {
    final response =
        await http.get(Uri.parse("$baseUrl/seats/schedule/$scheduleId"));
    final body = jsonDecode(response.body);
    if (body['status'] == 'Success') {
      return SeatModel.fromJson(body).data ?? [];
    } else {
      throw Exception("Failed to load seats by scheduleId");
    }
  }

  // ✅ POST /seats
  static Future<Seat> createSeat(Map<String, dynamic> seatPayload) async {
    final response = await http.post(
      Uri.parse("$baseUrl/seats"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(seatPayload),
    );
    final body = jsonDecode(response.body);
    return Seat.fromJson(body['data']);
  }

  // ✅ PUT /seats/:id
  static Future<Seat> updateSeat(
      int seatId, Map<String, dynamic> updatedSeat) async {
    final response = await http.put(
      Uri.parse("$baseUrl/seats/$seatId"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(updatedSeat),
    );
    final body = jsonDecode(response.body);
    return Seat.fromJson(body['data']);
  }

  // ✅ DELETE /seats/:id
  static Future<void> deleteSeat(int seatId) async {
    final response = await http.delete(Uri.parse("$baseUrl/seats/$seatId"));
    if (response.statusCode != 200) {
      throw Exception("Failed to delete seat");
    }
  }

  // ✅ GET /seats/:id/status
  static Future<String> getSeatStatusById(int seatId) async {
    final response = await http.get(Uri.parse("$baseUrl/seats/$seatId/status"));
    final body = jsonDecode(response.body);
    if (body['status'] == 'Success') {
      return body['data']['status']; // misal: "available", "booked", dll
    } else {
      throw Exception("Failed to get seat status");
    }
  }

  // ✅ GET /seats/schedule/:scheduleId/status
  static Future<List<Seat>> getAllSeatStatusBySchedule(int scheduleId) async {
    final response =
        await http.get(Uri.parse("$baseUrl/seats/schedule/$scheduleId/status"));
    final body = jsonDecode(response.body);
    if (body['status'] == 'Success') {
      return SeatModel.fromJson(body).data ?? [];
    } else {
      throw Exception("Failed to load seat status by schedule");
    }
  }
}

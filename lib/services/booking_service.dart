import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/booking_model.dart';

class BookingService {
  static const baseUrl =
      "https://luminacine-be-901699795850.us-central1.run.app";

  // ✅ GET /bookings/user/:id_user
  static Future<List<Booking>> getBookingsByUser(int userId) async {
    final response =
        await http.get(Uri.parse("$baseUrl/bookings/user/$userId"));
    final body = jsonDecode(response.body);
    return (body['data'] as List).map((b) => Booking.fromJson(b)).toList();
  }

  // ✅ GET /booking-detail/:id
  static Future<Booking> getBookingDetailById(int id) async {
    final response = await http.get(Uri.parse("$baseUrl/booking-detail/$id"));
    final body = jsonDecode(response.body);
    return Booking.fromJson(body['data']);
  }

  // ✅ POST /bookings
  static Future<Booking> createBooking(
      Map<String, dynamic> bookingPayload) async {
    final response = await http.post(
      Uri.parse("$baseUrl/bookings"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(bookingPayload),
    );
    return Booking.fromJson(jsonDecode(response.body)['data']);
  }

  // ✅ PUT /bookings/:id
  static Future<Booking> updateBooking(
      int id, Map<String, dynamic> updatedPayload) async {
    final response = await http.put(
      Uri.parse("$baseUrl/bookings/$id"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(updatedPayload),
    );
    return Booking.fromJson(jsonDecode(response.body)['data']);
  }

  // ✅ DELETE /bookings/:id
  static Future<bool> deleteBooking(int id) async {
    final response = await http.delete(Uri.parse("$baseUrl/bookings/$id"));
    return response.statusCode == 200;
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/booking_model.dart';

class BookingService {
  static const baseUrl = "https://luminacine-be-901699795850.us-central1.run.app";

  static Future<List<Booking>> getBookingsByUser(int userId) async {
    final response = await http.get(Uri.parse("$baseUrl/bookings/user/$userId"));
    final body = jsonDecode(response.body);
    return (body['data'] as List).map((b) => Booking.fromJson(b)).toList();
  }

  static Future<Booking> createBooking(Map<String, dynamic> bookingPayload) async {
    final response = await http.post(
      Uri.parse("$baseUrl/bookings"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(bookingPayload),
    );
    return Booking.fromJson(jsonDecode(response.body)['data']);
  }
}

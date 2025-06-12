import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:luminacine/models/booking_model.dart';
import 'package:luminacine/models/movie_model.dart';
import 'package:luminacine/pages/user_pages/ticket_page.dart';
import 'package:luminacine/services/booking_service.dart';
import 'package:luminacine/services/movie_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:luminacine/pages/user_pages/home_page.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<Map<String, dynamic>> bookings = [];
  bool isLoading = true;
  String error = '';
  int? userId;

  @override
  void initState() {
    super.initState();
    _loadUserAndFetchBookings();
  }

  Future<void> _loadUserAndFetchBookings() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('idUser');

    if (userId == null) {
      setState(() {
        isLoading = false;
        error = "User not found. Please login.";
      });
      return;
    }

    await fetchBookings();
  }

  Future<void> fetchBookings() async {
    try {
      final rawBookings = await BookingService.getBookingsByUser(userId!);
      List<Map<String, dynamic>> combined = [];

      for (var booking in rawBookings) {
        try {
          final scheduleResponse = await http.get(Uri.parse(
              "https://luminacine-be-901699795850.us-central1.run.app/schedules/${booking.idSchedule}"));
          final scheduleData = jsonDecode(scheduleResponse.body)['data'];

          final movie =
              await MovieService.getMovieById(scheduleData['id_movie']);
          combined.add({
            'booking': booking,
            'schedule': scheduleData,
            'movie': movie,
          });
        } catch (_) {
          combined.add({'booking': booking, 'schedule': null, 'movie': null});
        }
      }

      setState(() {
        bookings = combined;
        isLoading = false;
        error = '';
      });
    } catch (_) {
      setState(() {
        isLoading = false;
        error = 'Failed to load bookings.';
      });
    }
  }

  String formatDate(String? dateStr) {
    if (dateStr == null) return '-';
    try {
      final dt = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy').format(dt);
    } catch (_) {
      return '-';
    }
  }

  Widget buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    if (error.isNotEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(error, style: TextStyle(color: Colors.redAccent)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("My Booking History",
            style: TextStyle(color: Colors.white, fontSize: 18)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              final state =
                  context.findAncestorStateOfType<UserHomePageState>();
              state?.switchToTab(0);
            }
          },
        ),
      ),
      body: bookings.isEmpty
          ? const Center(
              child: Text("You have no bookings yet.",
                  style: TextStyle(color: Colors.grey, fontSize: 14)),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final booking = bookings[index]['booking'] as Booking;
                final schedule = bookings[index]['schedule'];
                final movie = bookings[index]['movie'] as Movie?;

                return Card(
                  color: const Color(0xFF0D111C),
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            movie?.posterUrl ??
                                "https://via.placeholder.com/100x150",
                            width: 100,
                            height: 150,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                movie?.title ?? "Unknown Movie",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 16),
                              buildInfoRow(
                                  "Order ID", "${booking.idBooking}"),
                              const SizedBox(height: 8),
                              buildInfoRow(
                                  "Cinema", schedule?['cinema_name'] ?? '-'),
                              const SizedBox(height: 8),
                              buildInfoRow(
                                  "Date", formatDate(schedule?['date'])),
                              const SizedBox(height: 8),
                              buildInfoRow(
                                  "Time", schedule?['time'] ?? '-'),
                              const SizedBox(height: 8),
                              buildInfoRow("Cost",
                                  "Rp ${booking.totalPrice?.toStringAsFixed(0) ?? '0'}"),
                              const SizedBox(height: 16),
                              Align(
                                alignment: Alignment.centerRight,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.pink[600],
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 10),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => TicketPage(
                                            bookingId: booking.idBooking!),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    "Ticket Details",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

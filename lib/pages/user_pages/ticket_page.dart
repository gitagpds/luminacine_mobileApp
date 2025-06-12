import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:luminacine/models/booking_model.dart';
import 'package:luminacine/services/booking_service.dart';
import 'package:luminacine/services/movie_service.dart';

class TicketPage extends StatefulWidget {
  final int bookingId;

  const TicketPage({super.key, required this.bookingId});

  @override
  State<TicketPage> createState() => _TicketPageState();
}

class _TicketPageState extends State<TicketPage> {
  Booking? booking;
  Map<String, dynamic>? scheduleData;
  Map<String, dynamic>? movieData;
  List<String> seatCodes = [];

  bool isLoading = true;
  String error = '';

  @override
  void initState() {
    super.initState();
    fetchTicketDetail();
  }

  Future<void> fetchTicketDetail() async {
    try {
      final bookingDetail =
          await BookingService.getBookingDetailById(widget.bookingId);

      final scheduleResponse = await http.get(Uri.parse(
          "https://luminacine-be-901699795850.us-central1.run.app/schedules/${bookingDetail.idSchedule}"));
      final scheduleJson = jsonDecode(scheduleResponse.body)['data'];

      final movie = await MovieService.getMovieById(scheduleJson['id_movie']);

      final bookingResponse = await http.get(Uri.parse(
          "https://luminacine-be-901699795850.us-central1.run.app/booking-detail/${widget.bookingId}"));
      final seatJson = jsonDecode(bookingResponse.body)['data']['seats'];
      final seats = (seatJson as List)
          .map((seat) => seat['seat_code'].toString())
          .toList();

      setState(() {
        booking = bookingDetail;
        scheduleData = scheduleJson;
        movieData = {
          'title': movie.title,
          'poster_url': movie.posterUrl,
        };
        seatCodes = seats;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Gagal memuat tiket.';
        isLoading = false;
      });
    }
  }

  String formatDate(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy').format(dt);
    } catch (_) {
      return '-';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Your Ticket", style: TextStyle(color: Colors.white)),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                  context, '/home', (route) => false);
            }),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : error.isNotEmpty
              ? Center(
                  child: Text(error, style: const TextStyle(color: Colors.red)))
              : ticketContent(),
    );
  }

  Widget ticketContent() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 180),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.fromLTRB(16, 30, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ROW POSTER + INFO
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    movieData?['poster_url'] ?? '',
                    width: 120,
                    height: 170,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        movieData?['title'] ?? '-',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Show this ticket at the entrance!",
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        scheduleData?['cinema_name'] ?? '-',
                        style: const TextStyle(color: Colors.black),
                      ),
                      Text(
                        formatDate(scheduleData?['date'] ?? ''),
                        style: const TextStyle(color: Colors.black),
                      ),
                      Text(
                        scheduleData?['time'] ?? '-',
                        style: const TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
            const Divider(color: Colors.grey),

            // INFO DI BAWAH
            ticketInfo("Seat", seatCodes.join(', ')),
            ticketInfo(
                "Cost", "Rp. ${booking!.totalPrice?.toStringAsFixed(0)}"),
            ticketInfo("Order ID", "${booking!.idBooking}"),

            const SizedBox(height: 24),

            // BARCODE
            Center(
              child: Image.asset(
                'assets/images/barcode.png',
                height: 80,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget ticketInfo(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value ?? '-',
              style: const TextStyle(
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

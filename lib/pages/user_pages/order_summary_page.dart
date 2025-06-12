import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:luminacine/models/movie_model.dart';
import 'package:luminacine/models/schedule_model.dart';
import 'package:luminacine/models/seat_model.dart';
import 'package:luminacine/services/movie_service.dart';
import 'package:luminacine/services/schedule_service.dart';
import 'package:luminacine/services/booking_service.dart';

class OrderSummaryPage extends StatefulWidget {
  final int movieId;
  final int scheduleId;
  final List<Seat> selectedSeats;
  final bool isRescheduling;
  final int? bookingId;
  final int userId;

  const OrderSummaryPage({
    super.key,
    required this.movieId,
    required this.scheduleId,
    required this.selectedSeats,
    required this.userId,
    this.isRescheduling = false,
    this.bookingId,
  });

  @override
  State<OrderSummaryPage> createState() => _OrderSummaryPageState();
}

class _OrderSummaryPageState extends State<OrderSummaryPage> {
  Movie? _movie;
  Schedule? _schedule;
  String? _orderId;
  bool _loading = true;
  String? _error;
  final int serviceFee = 5000;

  @override
  void initState() {
    super.initState();
    if (widget.selectedSeats.isEmpty || widget.userId == 0) {
      setState(() {
        _error = 'Data pemesanan tidak valid. Silakan pilih kursi kembali.';
        _loading = false;
      });
    } else {
      _fetchData();
    }
  }

  Future<void> _fetchData() async {
    try {
      final movie = await MovieService.getMovieById(widget.movieId);
      final schedules =
          await ScheduleService.getSchedulesByMovieId(widget.movieId);
      final schedule =
          schedules.firstWhere((s) => s.idSchedule == widget.scheduleId);

      setState(() {
        _movie = movie;
        _schedule = schedule;
      });
    } catch (e) {
      setState(() {
        _error = 'Gagal memuat data film dan jadwal.';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  int get totalPrice {
    final price = _schedule?.price ?? 0;
    return (price * widget.selectedSeats.length) + serviceFee;
  }

  Future<void> _handleBooking() async {
    try {
      if (_schedule == null) return;

      final payload = {
        "id_user": widget.userId,
        "id_schedule": widget.scheduleId,
        "total_price": totalPrice,
        "seats": widget.selectedSeats.map((s) => s.idSeat).toList(),
      };

      debugPrint("📦 Booking payload: $payload");

      final booking = widget.isRescheduling && widget.bookingId != null
          ? await BookingService.updateBooking(widget.bookingId!, payload)
          : await BookingService.createBooking(payload);

      debugPrint("✅ Booking berhasil, ID: ${booking.idBooking}");

      setState(() {
        _orderId = booking.idBooking.toString();
      });

      if (!mounted) return;
      Navigator.pushNamed(context, '/ticket/${booking.idBooking}');
    } catch (e) {
      debugPrint("❌ Booking failed: $e");
      setState(() {
        _error = 'Gagal melakukan booking. Coba lagi.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp. ');

    if (_loading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(_error!, style: const TextStyle(color: Colors.red)),
        ),
      );
    }

    if (_movie == null || _schedule == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text('Data tidak ditemukan',
              style: TextStyle(color: Colors.white)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text('🧾 Order Summary')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.network(
                    _movie!.posterUrl ?? '',
                    width: 120,
                    height: 180,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _movie!.title ?? '',
                          style: const TextStyle(
                              color: Colors.yellowAccent,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${_movie!.genre} • ${DateTime.tryParse(_movie!.releaseDate ?? '')?.year ?? ''}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _schedule!.cinemaName ?? '',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        Text('Studio: ${_schedule!.studio}',
                            style: const TextStyle(color: Colors.white70)),
                        Text(
                          DateFormat('EEEE, dd MMMM yyyy • HH:mm', 'id_ID')
                              .format(
                            DateTime.parse(
                                '${_schedule!.date} ${_schedule!.time}'),
                          ),
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[850],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('🎟️ Order Details',
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                    if (_orderId != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'ORDER ID: $_orderId',
                          style: const TextStyle(
                              color: Colors.yellowAccent,
                              fontFamily: 'monospace'),
                        ),
                      ),
                    const SizedBox(height: 8),
                    Text(
                      'Seat: ${widget.selectedSeats.map((s) => s.seatCode).join(', ')}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    const Divider(height: 20, color: Colors.white24),
                    Text(
                      'Ticket: ${currency.format(_schedule!.price)} × ${widget.selectedSeats.length}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    Text(
                      'Service Fee: ${currency.format(serviceFee)}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Total: ${currency.format(totalPrice)}',
                      style: const TextStyle(
                          color: Colors.yellowAccent,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _orderId != null ? null : _handleBooking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _orderId != null ? Colors.green : Colors.yellow,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                        vertical: 16), // tinggi tombol
                    textStyle: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(_orderId != null
                      ? '✅ BOOKING SUCCESS!'
                      : '🎫 CONFIRM BOOKING'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

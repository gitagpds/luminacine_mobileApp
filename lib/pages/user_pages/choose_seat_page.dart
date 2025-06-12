import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:luminacine/models/schedule_model.dart';
import 'package:luminacine/models/seat_model.dart';
import 'package:luminacine/pages/user_pages/order_summary_page.dart';
import 'package:luminacine/services/schedule_service.dart';
import 'package:luminacine/services/seat_service.dart';

class ChooseSeatPage extends StatefulWidget {
  final int idMovie;
  final int idSchedule;
  final bool isReschedule;
  final int? bookingId;
  final num oldPrice;

  const ChooseSeatPage({
    super.key,
    required this.idMovie,
    required this.idSchedule,
    this.isReschedule = false,
    this.bookingId,
    this.oldPrice = 0,
  });

  @override
  State<ChooseSeatPage> createState() => _ChooseSeatPageState();
}

class _ChooseSeatPageState extends State<ChooseSeatPage> {
  Schedule? _schedule;
  List<Seat> _allSeats = [];
  final List<Seat> _selectedSeats = [];
  bool _loading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      final schedule = await ScheduleService.getScheduleDetail(
        widget.idMovie,
        widget.idSchedule,
      );
      final seatList =
          await SeatService.getAllSeatStatusBySchedule(widget.idSchedule);

      setState(() {
        _schedule = schedule;
        _allSeats = seatList;
      });
    } catch (e, stacktrace) {
      debugPrint('❌ ERROR saat fetch data kursi: $e');
      debugPrint('❌ STACKTRACE: $stacktrace');
      setState(() {
        _error = 'Gagal memuat data kursi. Silakan coba lagi.';
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  void _toggleSeat(Seat seat) {
    if (seat.seatStatus == 'booked') return;
    setState(() {
      final exists = _selectedSeats.any((s) => s.idSeat == seat.idSeat);
      if (exists) {
        _selectedSeats.removeWhere((s) => s.idSeat == seat.idSeat);
      } else {
        _selectedSeats.add(seat);
      }
    });
  }

  Widget _buildSeat(Seat seat) {
    final isBooked = seat.seatStatus == 'booked';
    final isSelected = _selectedSeats.any((s) => s.idSeat == seat.idSeat);

    Color bgColor;
    Color textColor = Colors.yellow;
    if (isBooked) {
      bgColor = Colors.white;
      textColor = Colors.black;
    } else if (isSelected) {
      bgColor = Colors.yellow;
      textColor = Colors.black;
    } else {
      bgColor = const Color(0xFF3A3A3A);
    }

    return GestureDetector(
      onTap: () => _toggleSeat(seat),
      child: Container(
        width: 40,
        height: 40,
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(6),
        ),
        alignment: Alignment.center,
        child: Text(
          seat.seatCode ?? '',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildSeatGrid() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error.isNotEmpty) {
      return Center(
        child: Text(_error, style: const TextStyle(color: Colors.red)),
      );
    }
    if (_allSeats.isEmpty) {
      return const Center(child: Text('Tidak ada kursi tersedia'));
    }

    final rows = <String, List<Seat>>{};
    for (var seat in _allSeats) {
      final rowKey = seat.seatCode?.substring(0, 1) ?? '-';
      rows.putIfAbsent(rowKey, () => []).add(seat);
    }

    final rowKeys = rows.keys.toList()..sort();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: rowKeys.map((row) {
            final seatsInRow = rows[row]!
              ..sort((a, b) {
                final numA = int.tryParse(a.seatCode!.substring(1)) ?? 0;
                final numB = int.tryParse(b.seatCode!.substring(1)) ?? 0;
                return numA.compareTo(numB);
              });
            return Row(
              children: seatsInRow.map(_buildSeat).toList(),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildScreenIndicator() {
    return Column(
      children: [
        const Text(
          'Screen',
          style: TextStyle(
            color: Colors.yellow,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: 4,
          width: 200,
          decoration: BoxDecoration(
            color: Colors.yellow,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Future<void> _goToOrderSummary() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('idUser') ?? 0;

    if (userId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal mendapatkan ID user dari session")),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderSummaryPage(
          movieId: widget.idMovie,
          scheduleId: widget.idSchedule,
          selectedSeats: _selectedSeats,
          isRescheduling: widget.isReschedule,
          bookingId: widget.bookingId,
          userId: userId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final price = _schedule?.price ?? 0;
    final total = price * _selectedSeats.length;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text('Choose Seat')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildScreenIndicator(),
                    Expanded(child: _buildSeatGrid()),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Text(
                          '${_selectedSeats.length} Kursi',
                          style: const TextStyle(color: Colors.white),
                        ),
                        const Spacer(),
                        Text(
                          'Rp ${total.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Tambahkan garis horizontal di atas row
                    Container(
                      height: 1,
                      color: Colors.white24, // Bisa disesuaikan warnanya
                      margin: EdgeInsets.only(
                          bottom: 20), // Jarak antara garis dan Row
                    ),

                    Row(children: const [
                      _Legend(color: Color(0xFF3A3A3A), label: 'Tersedia'),
                      SizedBox(width: 70),
                      _Legend(color: Colors.white, label: 'Terisi'),
                      SizedBox(width: 70),
                      _Legend(color: Colors.yellow, label: 'Dipilih'),
                    ]),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.black,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    onPressed:
                        _selectedSeats.isEmpty ? null : _goToOrderSummary,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Pay Now'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;

  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}

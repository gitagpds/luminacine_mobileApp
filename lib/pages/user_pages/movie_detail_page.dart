import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:luminacine/models/movie_model.dart';
import 'package:luminacine/models/schedule_model.dart';
import 'package:luminacine/services/movie_service.dart';
import 'package:luminacine/services/schedule_service.dart';
import 'choose_seat_page.dart';

class MovieDetailPage extends StatefulWidget {
  final int idMovie;
  final bool isReschedule;
  final int? bookingId;

  const MovieDetailPage({
    super.key,
    required this.idMovie,
    this.isReschedule = false,
    this.bookingId,
  });

  @override
  State<MovieDetailPage> createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage> {
  Movie? _movie;
  List<Schedule> _schedules = [];
  String? _selectedDate;
  int? _selectedScheduleId;
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final movie = await MovieService.getMovieById(widget.idMovie);
      final schedules =
          await ScheduleService.getSchedulesByMovieId(widget.idMovie);

      setState(() {
        _movie = movie;
        _schedules = schedules;
        if (schedules.isNotEmpty) {
          _selectedDate = schedules[0].date;
        }
      });
    } catch (e) {
      setState(() {
        _error = 'Gagal memuat data. Silakan coba lagi.';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error.isNotEmpty) {
      return Scaffold(
        body: Center(
          child: Text(_error, style: const TextStyle(color: Colors.red)),
        ),
      );
    }

    if (_movie == null) {
      return const Scaffold(
        body: Center(child: Text("Film tidak ditemukan")),
      );
    }

    final uniqueDates =
        _schedules.map((s) => s.date).whereType<String>().toSet().toList();
    final filtered = _schedules.where((s) => s.date == _selectedDate).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Film')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster + Info Movie
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    _movie!.posterUrl ?? '',
                    height: 160,
                    width: 110,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _movie?.title ?? 'Tanpa Judul',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      if (_movie?.genre != null && _movie!.genre!.isNotEmpty)
                        Text(_movie!.genre!),
                      const SizedBox(height: 4),
                      if (_movie?.releaseDate != null)
                        Text(DateFormat('yyyy')
                            .format(DateTime.parse(_movie!.releaseDate!))),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Sinopsis
            Text(
              _movie?.sinopsis ?? 'Sinopsis tidak tersedia.',
              textAlign: TextAlign.justify,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 24),

            // Date Selector
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: uniqueDates.map((date) {
                final selected = _selectedDate == date;
                return ChoiceChip(
                  label: Text(
                      DateFormat('dd MMM EEE').format(DateTime.parse(date))),
                  selected: selected,
                  onSelected: (_) {
                    setState(() {
                      _selectedDate = date;
                      _selectedScheduleId = null;
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            // Schedule List
            if (filtered.isEmpty)
              const Text("Tidak ada jadwal tayang untuk tanggal ini.")
            else
              ...filtered.map((s) {
                final isSelected = _selectedScheduleId == s.idSchedule;
                return Card(
                  child: ListTile(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (s.cinemaName != null && s.cinemaName!.isNotEmpty)
                          Text(
                            s.cinemaName!,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        if (s.studio != null && s.studio!.isNotEmpty)
                          Text(
                            s.studio!,
                            style: const TextStyle(color: Colors.grey),
                          ),
                      ],
                    ),
                    subtitle: Text('Rp ${s.price?.toStringAsFixed(0) ?? '0'}'),
                    trailing: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedScheduleId = s.idSchedule;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.amber : Colors.grey[850],
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.amber),
                        ),
                        child: Text(
                          s.time?.substring(0, 5) ?? '--:--',
                          style: TextStyle(
                            color: isSelected ? Colors.black : Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),

            const SizedBox(height: 20),

            // Book Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedScheduleId == null
                    ? null
                    : () {
                        final selected = filtered.firstWhere(
                          (s) => s.idSchedule == _selectedScheduleId,
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChooseSeatPage(
                              idMovie: widget.idMovie,
                              idSchedule: selected.idSchedule!,
                              isReschedule: widget.isReschedule,
                              bookingId: widget.bookingId,
                              oldPrice: selected.price ?? 0,
                            ),
                          ),
                        );
                      },
                child:
                    Text(widget.isReschedule ? 'Reschedule Now' : 'Book Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

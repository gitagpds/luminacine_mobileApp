import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:luminacine/models/schedule_model.dart';
import 'package:luminacine/pages/admin_pages/add_schedule_movie.dart';
import 'package:luminacine/pages/admin_pages/edit_schedule_movie_page.dart';
import 'package:luminacine/services/schedule_service.dart';

class ScheduleDetailPage extends StatefulWidget {
  final int movieId;
  final String movieTitle;

  const ScheduleDetailPage(
      {super.key, required this.movieId, required this.movieTitle});

  @override
  State<ScheduleDetailPage> createState() => _ScheduleDetailPageState();
}

class _ScheduleDetailPageState extends State<ScheduleDetailPage> {
  late Future<List<Schedule>> _schedulesFuture;

  @override
  void initState() {
    super.initState();
    _loadSchedules();
  }

  void _loadSchedules() {
    setState(() {
      _schedulesFuture = ScheduleService.getSchedulesByMovieId(widget.movieId);
    });
  }

  Future<void> _deleteSchedule(int scheduleId) async {
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete this schedule?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ScheduleService.deleteSchedule(scheduleId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Schedule deleted successfully')),
          );
        }
        _loadSchedules();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete schedule: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.movieTitle,
          style: GoogleFonts.playfairDisplay(
              fontWeight: FontWeight.bold, fontSize: 22),
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (context) => AddSchedulePage(movieId: widget.movieId),
            ),
          );
          if (result == true) {
            _loadSchedules();
          }
        },
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<Schedule>>(
        future: _schedulesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('Failed to load schedules: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No schedules found for this movie.\nPress the + button to add one.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.white54),
              ),
            );
          }

          final schedules = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: schedules.length,
            itemBuilder: (context, index) {
              final schedule = schedules[index];
              return _buildScheduleCard(schedule);
            },
          );
        },
      ),
    );
  }

  Widget _buildScheduleCard(Schedule schedule) {
    final theme = Theme.of(context);
    // Use 'en_US' for English date formatting
    final String date = schedule.date != null
        ? DateFormat('EEEE, MMMM dd, yyyy', 'en_US')
            .format(DateTime.parse(schedule.date!))
        : 'No Date';
    final String time = schedule.time != null
        ? DateFormat('HH:mm')
            .format(DateTime.parse('1970-01-01T${schedule.time!}Z').toLocal())
        : 'No Time';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(schedule.cinemaName ?? 'No Cinema',
                      style: theme.textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(date, style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 4),
                  Text(time, style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 8),
                  Text(
                    'Rp ${NumberFormat('#,###', 'id_ID').format(schedule.price ?? 0)}',
                    style: TextStyle(
                      color: theme.colorScheme.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton.icon(
                  onPressed: () async {
                    final result = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            EditSchedulePage(schedule: schedule),
                      ),
                    );
                    if (result == true) {
                      _loadSchedules();
                    }
                  },
                  icon: Icon(Icons.edit,
                      size: 18, color: theme.colorScheme.secondary),
                  label: Text('Edit',
                      style: TextStyle(color: theme.colorScheme.secondary)),
                ),
                TextButton.icon(
                  onPressed: () {
                    if (schedule.idSchedule != null) {
                      _deleteSchedule(schedule.idSchedule!);
                    }
                  },
                  icon: Icon(Icons.delete, size: 18, color: Colors.red[400]),
                  label:
                      Text('Delete', style: TextStyle(color: Colors.red[400])),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

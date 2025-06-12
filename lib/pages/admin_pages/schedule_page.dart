import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luminacine/models/movie_model.dart';
import 'package:luminacine/pages/admin_pages/card/schedule_movie_card.dart';
import 'package:luminacine/pages/admin_pages/detail_add_schedule.dart';
import 'package:luminacine/services/movie_service.dart';

class AdminSchedulePage extends StatefulWidget {
  const AdminSchedulePage({super.key});

  @override
  State<AdminSchedulePage> createState() => _AdminSchedulePageState();
}

class _AdminSchedulePageState extends State<AdminSchedulePage> {
  bool _isLoading = true;
  List<Movie> _allMovies = [];
  List<Movie> _filteredMovies = [];
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMovies();
    _searchController.addListener(_filterMovies);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMovies() async {
    setState(() => _isLoading = true);
    try {
      final movies = await MovieService.getMovies();
      setState(() {
        _allMovies = movies;
        _filteredMovies = movies;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal memuat film: ${e.toString()}')));
      }
    }
  }

  void _filterMovies() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredMovies = _allMovies.where((movie) {
        return movie.title?.toLowerCase().contains(query) ?? false;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Manajemen Jadwal',
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari film untuk diatur jadwalnya...',
                suffixIcon: Icon(Icons.search, color: theme.hintColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: const BorderSide(color: Colors.transparent),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: const BorderSide(color: Colors.transparent),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(color: theme.colorScheme.secondary),
                ),
                filled: true,
                fillColor: theme.colorScheme.surface,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 14.0),
              ),
            ),
          ),
          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_filteredMovies.isEmpty)
            const Expanded(child: Center(child: Text('Film tidak ditemukan.')))
          else
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  childAspectRatio: 0.54,
                ),
                itemCount: _filteredMovies.length,
                itemBuilder: (context, index) {
                  final movie = _filteredMovies[index];
                  return ScheduleMovieCard(
                    movie: movie,
                    onEditSchedule: () {
                      if (movie.idMovie != null) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ScheduleDetailPage(
                                movieId: movie.idMovie!,
                                movieTitle: movie.title ?? 'No Title',
                              ),
                            ));
                      }
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

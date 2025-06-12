import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luminacine/models/movie_model.dart';
import 'package:luminacine/pages/admin_pages/add_movie_page.dart';
import 'package:luminacine/pages/admin_pages/edit_movie_page.dart';
import 'package:luminacine/pages/admin_pages/card/admin_movie_card.dart';
import 'package:luminacine/pages/admin_pages/schedule_page.dart';
import 'package:luminacine/pages/login_page.dart';
import 'package:luminacine/services/movie_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    const AdminHomeContent(),
    const AdminSchedulePage(),
  ];

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (Route<dynamic> route) => false,
      );
    }
  }

  void _onItemTapped(int index) {
    if (index == 2) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Konfirmasi Logout'),
          content: const Text('Apakah Anda yakin ingin keluar?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Batal')),
            FilledButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                _logout();
              },
              child: const Text('Ya, Keluar'),
            ),
          ],
        ),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today), label: 'Scheduling'),
          BottomNavigationBarItem(icon: Icon(Icons.logout), label: 'Logout'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

class AdminHomeContent extends StatefulWidget {
  const AdminHomeContent({super.key});

  @override
  State<AdminHomeContent> createState() => _AdminHomeContentState();
}

class _AdminHomeContentState extends State<AdminHomeContent> {
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

  Future<void> _deleteMovie(int movieId) async {
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text(
            'Data film yang dihapus tidak dapat dikembalikan. Lanjutkan?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Batal')),
          TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Hapus', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await MovieService.deleteMovie(movieId);
        if (context.mounted)
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Film berhasil dihapus')));
        _loadMovies();
      } catch (e) {
        if (context.mounted)
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Gagal menghapus film: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'LuminaCine Admin Side',
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.bold,
            fontSize: 26,
          ),
        ),
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
      ),
      // Tombol Tambah Film baru
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push<bool>(context,
              MaterialPageRoute(builder: (context) => const AddMoviePage()));
          if (result == true) {
            _loadMovies();
          }
        },
        backgroundColor: theme.colorScheme.secondary,
        child: const Icon(Icons.add, color: Colors.black),
      ),
      body: RefreshIndicator(
        onRefresh: _loadMovies,
        child: Column(
          children: [
            // Kolom Pencarian
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Cari berdasarkan judul film...',
                  suffixIcon: Icon(
                    Icons.search,
                    color: theme.colorScheme.secondary,
                  ),
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
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
            // Kondisi jika tidak ada film
            else if (_filteredMovies.isEmpty)
              const Expanded(
                child:
                    Center(child: Text('Film tidak ditemukan atau belum ada.')),
              )
            // GridView untuk menampilkan film
            else
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                    childAspectRatio:
                        0.54, // Rasio disesuaikan untuk layout baru
                  ),
                  itemCount: _filteredMovies.length,
                  itemBuilder: (context, index) {
                    final movie = _filteredMovies[index];
                    return AdminMovieCard(
                      movie: movie,
                      onEdit: () async {
                        final result = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditMoviePage(movie: movie),
                          ),
                        );
                        if (result == true) {
                          _loadMovies();
                        }
                      },
                      onDelete: () => _deleteMovie(movie.idMovie!),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

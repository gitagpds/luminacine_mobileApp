import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luminacine/pages/user_pages/movie_card/user_movie_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/movie_model.dart';
import '../../services/movie_service.dart';
import '../login_page.dart';
import 'history_page.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  State<UserHomePage> createState() => UserHomePageState();
}

class UserHomePageState extends State<UserHomePage> {
  int _selectedIndex = 0;

  List<Widget> get _pages => [
        const _UserHomeContent(),
        HistoryPage(),
      ];

  void _onItemTapped(int index) {
    if (index == 2) {
      _confirmLogout(context);
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void switchToTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (_) => false,
                );
              }
            },
            child: const Text('Ya, Keluar'),
          ),
        ],
      ),
    );
    if (confirmed ?? false) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.logout), label: 'Logout'),
        ],
      ),
    );
  }
}

class _UserHomeContent extends StatefulWidget {
  const _UserHomeContent();

  @override
  State<_UserHomeContent> createState() => __UserHomeContentState();
}

class __UserHomeContentState extends State<_UserHomeContent> {
  bool _isLoading = true;
  List<Movie> _allMovies = [];
  List<Movie> _filteredMovies = [];
  final _searchController = TextEditingController();
  String _selectedYear = '';
  String _selectedGenre = '';

  @override
  void initState() {
    super.initState();
    _loadMovies();
    _searchController.addListener(_filterMovies);
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat film: $e')),
      );
    }
  }

  void _filterMovies() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredMovies = _allMovies.where((movie) {
        final matchesSearch = movie.title?.toLowerCase().contains(query) ?? false;
        final year = movie.releaseDate?.split('-').first ?? '';
        final matchesYear = _selectedYear.isEmpty || year == _selectedYear;
        final matchesGenre = _selectedGenre.isEmpty || (movie.genre?.toLowerCase().contains(_selectedGenre.toLowerCase()) ?? false);
        return matchesSearch && matchesYear && matchesGenre;
      }).toList();
    });
  }

  List<String> get _uniqueYears {
    final years = _allMovies.map((m) => m.releaseDate?.split('-').first ?? '').toSet().toList();
    years.sort((a, b) => b.compareTo(a));
    return years;
  }

  List<String> get _uniqueGenres {
    final genres = _allMovies
        .expand((m) => m.genre?.split(',') ?? [])
        .map((g) => g.trim())
        .where((g) => g.isNotEmpty)
        .toSet()
        .toList()
        .cast<String>();
    genres.sort();
    return genres;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildHorizontalMovieList(List<Movie> movies) {
    return SizedBox(
      height: 300,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: movies.length,
        itemBuilder: (context, index) => SizedBox(
          width: 240,
          child: UserMovieCard(movie: movies[index]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Luminacine',
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.bold,
            fontSize: 26,
          ),
        ),
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
      ),
      body: RefreshIndicator(
        onRefresh: _loadMovies,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search movies',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Row(
                children: [
                  DropdownButton<String>(
                    value: _selectedYear.isEmpty ? null : _selectedYear,
                    hint: const Text('All Years'),
                    onChanged: (value) {
                      setState(() => _selectedYear = value ?? '');
                      _filterMovies();
                    },
                    items: [
                      const DropdownMenuItem(value: '', child: Text('All Years')),
                      ..._uniqueYears.map((year) => DropdownMenuItem(value: year, child: Text(year))),
                    ],
                  ),
                  const SizedBox(width: 12),
                  DropdownButton<String>(
                    value: _selectedGenre.isEmpty ? null : _selectedGenre,
                    hint: const Text('All Genres'),
                    onChanged: (value) {
                      setState(() => _selectedGenre = value ?? '');
                      _filterMovies();
                    },
                    items: [
                      const DropdownMenuItem(value: '', child: Text('All Genres')),
                      ..._uniqueGenres.map((genre) => DropdownMenuItem(value: genre, child: Text(genre))),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(30, 10, 30, 130),
                      children: [
                        if (_filteredMovies.isNotEmpty) ...[
                          const Text(
                            'MOVIES',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          _buildHorizontalMovieList(_filteredMovies),
                          const SizedBox(height: 20),
                        ],
                        const Text(
                          '2025 MOVIES',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        _buildHorizontalMovieList(
                          _allMovies.where((m) => m.releaseDate?.startsWith('2025') ?? false).toList(),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'ANIMATION MOVIES',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        _buildHorizontalMovieList(
                          _allMovies.where((m) => (m.genre ?? '').toLowerCase().contains('animation')).toList(),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'HORROR MOVIES',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        _buildHorizontalMovieList(
                          _allMovies.where((m) => (m.genre ?? '').toLowerCase().contains('horror')).toList(),
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

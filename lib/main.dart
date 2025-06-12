import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:luminacine/pages/user_pages/ticket_page.dart';
import 'package:luminacine/style/app_theme.dart';
import 'package:luminacine/pages/admin_pages/admin_dashboard_page.dart';
import 'package:luminacine/pages/login_page.dart';
import 'package:luminacine/pages/user_pages/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null); // ✅ Inisialisasi format lokal Indonesia
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<String?> _checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    if (token == null || token.isEmpty) {
      return null;
    }

    return prefs.getString('role');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Luminacine',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,

      onGenerateRoute: (settings) {
        final uri = Uri.parse(settings.name ?? '');

        if (uri.pathSegments.length == 2 && uri.pathSegments[0] == 'ticket') {
          final bookingId = int.tryParse(uri.pathSegments[1]);
          if (bookingId != null) {
            return MaterialPageRoute(
              builder: (_) => TicketPage(bookingId: bookingId),
            );
          }
        }

        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('404 - Halaman tidak ditemukan')),
          ),
        );
      },

      home: FutureBuilder<String?>(
        future: _checkAuthStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasData && snapshot.data != null) {
            final role = snapshot.data;
            if (role == 'admin') {
              return const AdminDashboardPage();
            } else {
              return const UserHomePage();
            }
          } else {
            return const LoginPage();
          }
        },
      ),
    );
  }
}

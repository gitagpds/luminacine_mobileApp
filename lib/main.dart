import 'package:flutter/material.dart';
import 'package:luminacine/style/app_theme.dart';
import 'package:luminacine/pages/admin_pages/admin_dashboard_page.dart';
import 'package:luminacine/pages/login_page.dart';
import 'package:luminacine/pages/user_pages/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);

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
      home: FutureBuilder<String?>(
        future: _checkAuthStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
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

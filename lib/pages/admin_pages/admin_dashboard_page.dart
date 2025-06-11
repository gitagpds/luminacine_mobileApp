import 'package:flutter/material.dart';
import 'package:luminacine/pages/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
  // Fungsi untuk proses logout
  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (Route<dynamic> route) => false, // Predikat ini menghapus semua route
      );
    }
  }

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Luminacine'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext ctx) {
                  return AlertDialog(
                    title: const Text('Konfirmasi Logout'),
                    content: const Text('Apakah Anda yakin ingin keluar?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(ctx).pop(); 
                        },
                        child: const Text('Batal'),
                      ),
                      FilledButton(
                        onPressed: () {
                          Navigator.of(ctx).pop(); 
                          _logout(context);    
                        },
                        child: const Text('Ya, Keluar'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: const Center(child: Text('Selamat Datang, Admin!', style: TextStyle(fontSize: 24))),
    );
  }
}
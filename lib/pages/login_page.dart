import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luminacine/pages/admin_pages/admin_dashboard_page.dart';
import 'package:luminacine/pages/register_page.dart';
import 'package:luminacine/pages/user_pages/home_page.dart';
import 'package:luminacine/services/user_service.dart';
import 'package:luminacine/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final Map<String, dynamic> loginData = await UserService.loginUser(
            _emailController.text, _passwordController.text);

        final String accessToken = loginData['accessToken'];
        final User user = User.fromJson(loginData['data']);

        final userRole = user.role;
        final userId = user.idUser;
        final userName = user.name;

        if (userRole == null || userId == null || userName == null) {
          throw Exception('Respons data pengguna dari server tidak lengkap.');
        }

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', accessToken);
        await prefs.setString(
            'role', userRole); 
        await prefs.setInt(
            'idUser', userId); 
        await prefs.setString(
            'name', userName);

        if (mounted) {
          if (userRole == 'admin') {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const AdminDashboardPage()));
          } else {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const UserHomePage()));
          }
        }
      } catch (e) {
        if (mounted) {
          debugPrint('Login error detailed: ${e.toString()}');
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text(
                  'Login gagal, periksa kembali email dan password Anda.')));
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints
                      .maxHeight, 
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center, 
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'LuminaCine',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'More is never enough.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.secondary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 30),
                        // Input Field Email
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(labelText: 'Email'),
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 16),
                          validator: (value) => value!.isEmpty
                              ? 'Email tidak boleh kosong'
                              : null,
                        ),
                        const SizedBox(height: 24),

                        // Input Field Password
                        TextFormField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: Colors.white54,
                              ),
                              onPressed: () => setState(() =>
                                  _isPasswordVisible = !_isPasswordVisible),
                            ),
                          ),
                          style: const TextStyle(
                              color: Colors.white, fontSize: 16),
                          validator: (value) => value!.isEmpty
                              ? 'Password tidak boleh kosong'
                              : null,
                        ),
                        const SizedBox(height: 50),

                        // Tombol Login
                        _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : SizedBox(
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: _login,
                                  child: const Text('Login'),
                                ),
                              ),
                        const SizedBox(height: 30),

                        // Link ke Halaman Registrasi
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "New here? ",
                              style: TextStyle(color: Colors.white54),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) =>
                                        const RegisterPage()));
                              },
                              child: Text(
                                "Sign up",
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

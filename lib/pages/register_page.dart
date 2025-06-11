import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luminacine/models/user_model.dart';
import 'package:luminacine/services/user_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose(); 
    super.dispose();
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final Map<String, dynamic> userPayload = {
        'name': _nameController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
        'role': 'user'
      };

      try {
        final User newUser = await UserService.registerUser(userPayload);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Registrasi untuk ${newUser.name} berhasil! Silakan login.')),
          );
          Navigator.of(context).pop(); 
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Tidak ada AppBar
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Bagian Judul
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
                          'Hellow New Friend! Lets join Us',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.secondary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Input fields
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Nama Lengkap',
                            prefixIcon: Icon(Icons.person_outline,
                                color: Colors.white54),
                          ),
                          style: const TextStyle(
                              color: Colors.white, fontSize: 16),
                          validator: (value) =>
                              value!.isEmpty ? 'Nama tidak boleh kosong' : null,
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email_outlined,
                                color: Colors.white54),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 16),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Email tidak boleh kosong';
                            }
                            if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                              return 'Format email tidak valid';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline,
                                color: Colors.white54),
                            suffixIcon: IconButton(
                              icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: Colors.white54),
                              onPressed: () => setState(() =>
                                  _isPasswordVisible = !_isPasswordVisible),
                            ),
                          ),
                          style: const TextStyle(
                              color: Colors.white, fontSize: 16),
                          validator: (value) => value!.length < 8
                              ? 'Password minimal 8 karakter'
                              : null,
                        ),
                        const SizedBox(height: 24),

                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: !_isConfirmPasswordVisible,
                          decoration: InputDecoration(
                            labelText: 'Konfirmasi Password',
                            prefixIcon: const Icon(Icons.lock_outline,
                                color: Colors.white54),
                            suffixIcon: IconButton(
                              icon: Icon(
                                  _isConfirmPasswordVisible
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: Colors.white54),
                              onPressed: () => setState(() =>
                                  _isConfirmPasswordVisible =
                                      !_isConfirmPasswordVisible),
                            ),
                          ),
                          style: const TextStyle(
                              color: Colors.white, fontSize: 16),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Konfirmasi password tidak boleh kosong';
                            }
                            if (value != _passwordController.text) {
                              return 'Password tidak cocok';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 50),

                        // Tombol Daftar
                        _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : SizedBox(
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: _register,
                                  child: const Text('Sign Up'),
                                ),
                              ),
                        const SizedBox(height: 30),

                        // Link kembali ke Login
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Already have an account? ",
                              style: TextStyle(color: Colors.white54),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                              child: Text(
                                "Login",
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

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:luminacine/services/movie_service.dart';

class AddMoviePage extends StatefulWidget {
  const AddMoviePage({super.key});

  @override
  State<AddMoviePage> createState() => _AddMoviePageState();
}

class _AddMoviePageState extends State<AddMoviePage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final _titleController = TextEditingController();
  final _sinopsisController = TextEditingController();
  final _genreController = TextEditingController();
  final _durationController = TextEditingController();
  final _releaseDateController = TextEditingController();

  File? _posterImage;
  String? _posterFileName;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _titleController.dispose();
    _sinopsisController.dispose();
    _genreController.dispose();
    _durationController.dispose();
    _releaseDateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _releaseDateController.text =
            "${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _posterImage = File(pickedFile.path);
        _posterFileName = pickedFile.name;
      });
    }
  }

  Future<void> _saveMovie() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_posterImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a poster image first.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final cloudinaryUrl =
          Uri.parse("https://api.cloudinary.com/v1_1/dc4mguvug/image/upload");
      var request = http.MultipartRequest('POST', cloudinaryUrl);
      request.fields['upload_preset'] = 'first_try';
      request.files
          .add(await http.MultipartFile.fromPath('file', _posterImage!.path));

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final cloudinaryData = json.decode(responseData);
        final posterUrl = cloudinaryData['secure_url'];

        final movieData = {
          'title': _titleController.text,
          'sinopsis': _sinopsisController.text,
          'genre': _genreController.text,
          'duration': int.tryParse(_durationController.text) ?? 0,
          'poster_url': posterUrl,
          'release_date': _releaseDateController.text,
        };

        await MovieService.createMovie(movieData);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('New movie added successfully!')),
          );
          Navigator.of(context).pop(true);
        }
      } else {
        throw Exception('Failed to upload image to Cloudinary.');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add movie: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ADD MOVIE',
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold, color: theme.colorScheme.secondary),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.secondary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildLabeledTextField(
                    label: 'Title',
                    hint: 'Enter movie title',
                    controller: _titleController),
                const SizedBox(height: 16),
                _buildLabeledTextField(
                    label: 'Synopsis',
                    hint: 'Enter synopsis...',
                    controller: _sinopsisController,
                    maxLines: 4),
                const SizedBox(height: 16),
                _buildLabeledTextField(
                    label: 'Genre',
                    hint: 'e.g: Action, Comedy',
                    controller: _genreController),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildLabeledTextField(
                        label: 'Duration',
                        hint: 'Minutes',
                        controller: _durationController,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildLabeledTextField(
                        label: 'Release Date',
                        hint: 'YYYY-MM-DD',
                        controller: _releaseDateController,
                        readOnly: true,
                        onTap: _selectDate,
                        suffixIcon:
                            Icon(Icons.calendar_today, color: theme.hintColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Poster Upload',
                  style: TextStyle(
                    color: theme.colorScheme.secondary,
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  readOnly: true,
                  decoration: InputDecoration(
                      hintText: _posterFileName ?? 'No file chosen',
                      suffixIcon: IconButton(
                        icon: Icon(Icons.attach_file, color: theme.hintColor),
                        onPressed: _pickImage,
                      )),
                  validator: (v) =>
                      _posterImage == null ? 'Poster cannot be empty' : null,
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: _saveMovie,
                          child: const Text('ADD MOVIE'),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabeledTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    VoidCallback? onTap,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          readOnly: readOnly,
          onTap: onTap,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: suffixIcon,
          ),
          validator: (v) => v!.isEmpty ? '$label cannot be empty' : null,
        ),
      ],
    );
  }
}

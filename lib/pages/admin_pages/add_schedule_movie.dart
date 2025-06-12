import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:luminacine/services/schedule_service.dart';

class AddSchedulePage extends StatefulWidget {
  final int movieId;

  const AddSchedulePage({super.key, required this.movieId});

  @override
  State<AddSchedulePage> createState() => _AddSchedulePageState();
}

class _AddSchedulePageState extends State<AddSchedulePage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final _cinemaNameController = TextEditingController();
  final _studioController = TextEditingController();
  final _priceController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();

  @override
  void dispose() {
    _cinemaNameController.dispose();
    _studioController.dispose();
    _priceController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  // --- FUNGSI WAKTU DIPERBAIKI ---
  Future<void> _selectTime() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      // 2. Paksa penggunaan format 24 jam
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        final now = DateTime.now();
        final dt =
            DateTime(now.year, now.month, now.day, picked.hour, picked.minute);
        _timeController.text = DateFormat('HH:mm:ss').format(dt);
      });
    }
  }

  Future<void> _saveSchedule() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _isLoading = true);

    final payload = {
      'id_movie': widget.movieId,
      'cinema_name': _cinemaNameController.text,
      'studio': _studioController.text,
      'price': int.tryParse(_priceController.text) ?? 0,
      'date': _dateController.text,
      'time': _timeController.text,
    };

    try {
      await ScheduleService.createSchedule(widget.movieId, payload);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('New schedule added successfully')));
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save schedule: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      // --- APPBAR DIPERBAIKI ---
      appBar: AppBar(
        title: Text(
          'Add New Schedule',
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
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildLabeledTextField(
                  label: 'Cinema Name', controller: _cinemaNameController),
              const SizedBox(height: 16),
              _buildLabeledTextField(
                  label: 'Studio Name', controller: _studioController),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildLabeledTextField(
                      label: 'Show Date',
                      controller: _dateController,
                      readOnly: true,
                      onTap: _selectDate,
                      suffixIcon: const Icon(Icons.calendar_today),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildLabeledTextField(
                      label: 'Show Time',
                      controller: _timeController,
                      readOnly: true,
                      onTap: _selectTime,
                      suffixIcon: const Icon(Icons.access_time),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildLabeledTextField(
                label: 'Ticket Price',
                controller: _priceController,
                keyboardType: TextInputType.number,
                prefixText: 'Rp ',
              ),
              const SizedBox(height: 40),
              SizedBox(
                height: 50,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _saveSchedule,
                        child: const Text('SAVE SCHEDULE'),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabeledTextField({
    required String label,
    required TextEditingController controller,
    bool readOnly = false,
    VoidCallback? onTap,
    TextInputType? keyboardType,
    Widget? suffixIcon,
    String? prefixText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          onTap: onTap,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            prefixText: prefixText,
            suffixIcon: suffixIcon,
          ),
          validator: (value) =>
              value!.isEmpty ? '$label cannot be empty' : null,
        ),
      ],
    );
  }
}

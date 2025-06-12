import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:luminacine/models/schedule_model.dart';
import 'package:luminacine/services/schedule_service.dart';

class EditSchedulePage extends StatefulWidget {
  final Schedule schedule;

  const EditSchedulePage({super.key, required this.schedule});

  @override
  State<EditSchedulePage> createState() => _EditSchedulePageState();
}

class _EditSchedulePageState extends State<EditSchedulePage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late TextEditingController _cinemaNameController;
  late TextEditingController _studioController;
  late TextEditingController _priceController;
  late TextEditingController _dateController;
  late TextEditingController _timeController;

  @override
  void initState() {
    super.initState();
    _cinemaNameController =
        TextEditingController(text: widget.schedule.cinemaName);
    _studioController = TextEditingController(text: widget.schedule.studio);
    _priceController =
        TextEditingController(text: widget.schedule.price?.toString());
    _dateController = TextEditingController(text: widget.schedule.date);
    _timeController = TextEditingController(text: widget.schedule.time);
  }

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
      initialDate: DateTime.tryParse(_dateController.text) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _selectTime() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
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

  Future<void> _updateSchedule() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _isLoading = true);

    final payload = {
      'cinema_name': _cinemaNameController.text,
      'studio': _studioController.text,
      'price': int.tryParse(_priceController.text) ?? 0,
      'date': _dateController.text,
      'time': _timeController.text,
    };

    try {
      await ScheduleService.updateSchedule(
          widget.schedule.idMovie!, widget.schedule.idSchedule!, payload);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Schedule updated successfully')));
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update schedule: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Schedule',
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.secondary),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: Theme.of(context).colorScheme.secondary),
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
                        onPressed: _updateSchedule,
                        child: const Text('UPDATE SCHEDULE'),
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

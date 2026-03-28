import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/event.dart';
import '../../core/services/event_service.dart';

class AddEditEventScreen extends StatefulWidget {
  final String categoryId;
  final Event? event;

  const AddEditEventScreen({
    super.key,
    required this.categoryId,
    this.event,
  });

  @override
  State<AddEditEventScreen> createState() => _AddEditEventScreenState();
}

class _AddEditEventScreenState extends State<AddEditEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final EventService _eventService = EventService();

  late DateTime _selectedDate;
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 0);

  late final List<TimeOfDay> _timeOptions;

  @override
  void initState() {
    super.initState();
    _timeOptions = _buildTimeOptions();

    if (widget.event != null) {
      _titleController.text = widget.event!.title;
      _descriptionController.text = widget.event!.description;
      _selectedDate = widget.event!.date;
      _startTime = widget.event!.startTime;
      _endTime = widget.event!.endTime;
    } else {
      final now = DateTime.now();
      _selectedDate = DateTime(now.year, now.month, now.day);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  List<TimeOfDay> _buildTimeOptions() {
    final result = <TimeOfDay>[];
    for (int hour = 0; hour < 24; hour++) {
      result.add(TimeOfDay(hour: hour, minute: 0));
      result.add(TimeOfDay(hour: hour, minute: 30));
    }
    return result;
  }

  String _formatDate(DateTime date) {
    final dd = date.day.toString().padLeft(2, '0');
    final mm = date.month.toString().padLeft(2, '0');
    final yyyy = date.year.toString();
    return '$dd.$mm.$yyyy';
  }

  String _formatTime(TimeOfDay time) {
    final hh = time.hour.toString().padLeft(2, '0');
    final mm = time.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2100),
      helpText: 'Tag auswählen',
      cancelText: 'Abbrechen',
      confirmText: 'OK',
    );

    if (picked != null) {
      setState(() {
        _selectedDate = DateTime(picked.year, picked.month, picked.day);
      });
    }
  }

  Future<void> _selectTime(bool isStart) async {
    final selected = await showModalBottomSheet<TimeOfDay>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) {
        final currentValue = isStart ? _startTime : _endTime;

        return SafeArea(
          child: SizedBox(
            height: 420,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          isStart ? 'Startzeit wählen' : 'Endzeit wählen',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView.builder(
                    itemCount: _timeOptions.length,
                    itemBuilder: (context, index) {
                      final option = _timeOptions[index];
                      final isSelected = option.hour == currentValue.hour &&
                          option.minute == currentValue.minute;

                      return ListTile(
                        title: Text(_formatTime(option)),
                        trailing: isSelected
                            ? const Icon(Icons.check, color: Colors.green)
                            : null,
                        onTap: () => Navigator.of(sheetContext).pop(option),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selected != null) {
      setState(() {
        if (isStart) {
          _startTime = selected;
          if (_toMinutes(_endTime) <= _toMinutes(_startTime)) {
            _endTime = _nextTimeSlot(_startTime);
          }
        } else {
          _endTime = selected;
        }
      });
    }
  }

  int _toMinutes(TimeOfDay time) => time.hour * 60 + time.minute;

  TimeOfDay _nextTimeSlot(TimeOfDay time) {
    final currentMinutes = _toMinutes(time);
    final next = currentMinutes + 30;
    final capped = next > 23 * 60 + 30 ? 23 * 60 + 30 : next;
    return TimeOfDay(hour: capped ~/ 60, minute: capped % 60);
  }

  Future<void> _saveEvent() async {
    if (!_formKey.currentState!.validate()) return;

    if (_toMinutes(_endTime) <= _toMinutes(_startTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Endzeit muss nach der Startzeit liegen.'),
        ),
      );
      return;
    }

    final eventDate = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    );

    final event = Event(
      id: widget.event?.id ?? '',
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: widget.categoryId,
      date: eventDate,
      startTime: _startTime,
      endTime: _endTime,
    );

    if (widget.event == null) {
      await _eventService.createEvent(widget.categoryId, event);
    } else {
      await _eventService.updateEvent(
        widget.categoryId,
        widget.event!.id,
        event,
      );
    }

    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.event != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Ereignis bearbeiten' : 'Neues Ereignis'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Titel',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Titel erforderlich';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Beschreibung',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Tag'),
                subtitle: Text(_formatDate(_selectedDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: _selectDate,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _selectTime(true),
                      child: Text('Start: ${_formatTime(_startTime)}'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _selectTime(false),
                      child: Text('Ende: ${_formatTime(_endTime)}'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveEvent,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Speichern'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
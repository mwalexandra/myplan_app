import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/event.dart';
import '../../core/services/event_service.dart';

class AddEditEventScreen extends StatefulWidget {
  final String categoryId;
  final Event? event; // null для создания

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
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 0);
  final EventService _eventService = EventService();

  @override
  void initState() {
    super.initState();
    if (widget.event != null) {
      _titleController.text = widget.event!.title;
      _descriptionController.text = widget.event!.description;
      _startTime = widget.event!.startTime;
      _endTime = widget.event!.endTime;
    }
  }

  Future<void> _selectTime(bool isStart) async {
    final selected = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
    );
    if (selected != null) {
      setState(() {
        if (isStart) _startTime = selected;
        else _endTime = selected;
      });
    }
  }

  Future<void> _saveEvent() async {
    if (_formKey.currentState!.validate()) {
      final now = DateTime.now();
      final event = Event(
        id: widget.event?.id ?? '', // пустой для создания
        title: _titleController.text,
        description: _descriptionController.text,
        category: widget.categoryId,
        date: now,
        startTime: _startTime,
        endTime: _endTime,
      );

      final eventId = await _eventService.createEvent(widget.categoryId, event);
      if (mounted) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Neues Ereignis')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Titel'),
                validator: (value) => value?.isEmpty ?? true ? 'Titel erforderlich' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Beschreibung'),
                maxLines: 3,
              ),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _selectTime(true),
                      child: Text('Start: ${_startTime.format(context)}'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _selectTime(false),
                      child: Text('Ende: ${_endTime.format(context)}'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveEvent,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text('Speichern', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

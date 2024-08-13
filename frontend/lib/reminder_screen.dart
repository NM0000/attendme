import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddReminderScreen extends StatefulWidget {
  final Function? onReminderAdded; 

  const AddReminderScreen({super.key, this.onReminderAdded});

  @override
  _AddReminderScreenState createState() => _AddReminderScreenState();
}

class _AddReminderScreenState extends State<AddReminderScreen> {
  final TextEditingController _controller = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  Future<void> _saveReminder() async {
    final prefs = await SharedPreferences.getInstance();
    final savedReminders = prefs.getStringList('reminders') ?? [];
    
    final dateStr = DateFormat.yMd().format(_selectedDate);
    final reminder = '$dateStr: ${_controller.text}';

    savedReminders.add(reminder);
    await prefs.setStringList('reminders', savedReminders);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Reminder saved!'),
    ));

    // Notify the main screen to reload reminders
    if (widget.onReminderAdded != null) {
      widget.onReminderAdded!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Reminder'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(labelText: 'Enter Reminder'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                ).then((date) {
                  if (date != null) {
                    setState(() {
                      _selectedDate = date;
                    });
                  }
                });
              },
              child: const Text('Select Date'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _saveReminder();
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Save Reminder'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddReminderScreen extends StatefulWidget {
  const AddReminderScreen({super.key});

  @override
  _AddReminderScreenState createState() => _AddReminderScreenState();
}

class _AddReminderScreenState extends State<AddReminderScreen> {
  TextEditingController _reminderController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Reminder'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _reminderController,
              decoration: const InputDecoration(
                labelText: 'Reminder',
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  'Date: ${DateFormat.yMd().format(_selectedDate)}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null && pickedDate != _selectedDate) {
                      setState(() {
                        _selectedDate = pickedDate;
                      });
                    }
                  },
                  child: const Text('Pick Date'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveReminder,
              child: const Text('Save Reminder'),
            ),
          ],
        ),
      ),
    );
  }

  void _saveReminder() async {
    final prefs = await SharedPreferences.getInstance();
    final existingReminders = prefs.getStringList('reminders') ?? [];

    final formattedDate = DateFormat.yMd().format(_selectedDate);
    final newReminder = '$formattedDate: ${_reminderController.text}';
    existingReminders.add(newReminder);

    
    await prefs.setStringList('reminders', existingReminders);
    
    print('Saved reminders: $existingReminders');

    Navigator.pop(context);
  }
}
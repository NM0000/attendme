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
    final reminderText = _controller.text.trim(); // Trim any extra whitespace
    if (reminderText.isEmpty) {
      // Show an error message if the reminder text is empty
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reminder cannot be empty!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final savedReminders = prefs.getStringList('reminders') ?? [];
    
    final dateStr = DateFormat.yMd().format(_selectedDate);
    final reminder = '$dateStr: $reminderText';

    savedReminders.add(reminder);
    await prefs.setStringList('reminders', savedReminders);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Reminder saved!'),
    ));

    // Notify the main screen to reload reminders
    if (widget.onReminderAdded != null) {
      widget.onReminderAdded!();
    }

    // Pop the screen after saving the reminder
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.brown[300],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Add Reminder',
        style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Colors.white
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: double.infinity, // Full width
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  labelText: 'Enter Reminder',
                  border: OutlineInputBorder(), // Adds border to the TextField
                ),
                maxLines: 1, // Single line
                style: const TextStyle(fontSize: 18.0), // Increase font size
              ),
            ),
            const SizedBox(height: 16),
            Text(
              DateFormat.yMd().format(_selectedDate), // Show selected date
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18.0, // Size of the text
              ),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal[300], // Change this color to your preference
                foregroundColor: Colors.white, // Text color
              ),
              child: const Text('Select Date'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveReminder,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal[300], // Change this color to your preference
                foregroundColor: Colors.white, // Text color
              ),
              child: const Text('Save Reminder'),
            ),
          ],
        ),
      ),
    );
  }
}

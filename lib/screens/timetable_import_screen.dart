import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/timetable_entry.dart';
import '../providers/user_provider.dart';

class TimetableImportScreen extends StatefulWidget {
  const TimetableImportScreen({super.key});

  @override
  State<TimetableImportScreen> createState() => _TimetableImportScreenState();
}

class _TimetableImportScreenState extends State<TimetableImportScreen> {
  final Map<int, TimeOfDay> _selectedStarts = {};

  @override
  void initState() {
    super.initState();
    for (final entry in context.read<UserProvider>().timetable) {
      _selectedStarts[entry.weekday] = TimeOfDay(
        hour: entry.hour,
        minute: entry.minute,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final timetable = context.watch<UserProvider>().timetable;

    return Scaffold(
      appBar: AppBar(title: const Text('Timetable Setup')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Weekly commute start times',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Select the weekdays you start at campus and set the time for each day.',
            ),
            const SizedBox(height: 16),
            ...List.generate(
              TimetableEntry.weekdayNames.length,
              (index) => _WeekdayStartCard(
                weekdayName: TimetableEntry.weekdayNames[index],
                selectedTime: _selectedStarts[DateTime.monday + index],
                onSelectionChanged: (selected) {
                  setState(() {
                    final weekday = DateTime.monday + index;
                    if (selected) {
                      _selectedStarts[weekday] ??= const TimeOfDay(hour: 8, minute: 0);
                    } else {
                      _selectedStarts.remove(weekday);
                    }
                  });
                },
                onPickTime: () => _pickTime(DateTime.monday + index),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _selectedStarts.isEmpty ? null : _saveTimetable,
              icon: const Icon(Icons.save_outlined),
              label: const Text('Save Timetable'),
            ),
            const Divider(height: 36),
            const Text(
              'Saved Starts',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (timetable.isEmpty)
              const Text('No weekly timetable starts saved yet.')
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: timetable
                    .map((entry) => Chip(label: Text(entry.label)))
                    .toList(growable: false),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickTime(int weekday) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedStarts[weekday] ?? const TimeOfDay(hour: 8, minute: 0),
    );
    if (picked == null || !mounted) return;
    setState(() => _selectedStarts[weekday] = picked);
  }

  Future<void> _saveTimetable() async {
    final entries = _selectedStarts.entries
        .map(
          (entry) => TimetableEntry(
            weekday: entry.key,
            hour: entry.value.hour,
            minute: entry.value.minute,
          ),
        )
        .toList()
      ..sort((first, second) => first.weekday.compareTo(second.weekday));

    await context.read<UserProvider>().saveTimetable(entries);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Timetable saved.')),
    );
  }
}

class _WeekdayStartCard extends StatelessWidget {
  const _WeekdayStartCard({
    required this.weekdayName,
    required this.selectedTime,
    required this.onSelectionChanged,
    required this.onPickTime,
  });

  final String weekdayName;
  final TimeOfDay? selectedTime;
  final ValueChanged<bool> onSelectionChanged;
  final VoidCallback onPickTime;

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedTime != null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            Checkbox(
              value: isSelected,
              onChanged: (value) => onSelectionChanged(value ?? false),
            ),
            Expanded(
              child: Text(
                weekdayName,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            OutlinedButton.icon(
              onPressed: isSelected ? onPickTime : null,
              icon: const Icon(Icons.access_time, size: 18),
              label: Text(
                selectedTime?.format(context) ?? 'Time',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

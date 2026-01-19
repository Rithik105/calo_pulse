import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/calorie_entry.dart';
import '../provider/calorie_provider.dart';
import 'add_edit_entry_ui.dart';

class DayViewScreen extends StatelessWidget {
  final DateTime day;

  const DayViewScreen({super.key, required this.day});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CalorieProvider>();
    final entries = provider.entriesForDay(day);

    return Scaffold(
      appBar: AppBar(
        title: Text('Entries for ${day.day}/${day.month}/${day.year}'),
      ),
      body: entries.isEmpty
          ? const Center(child: Text('No entries for this day.'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: entries.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final entry = entries[index];
                return ListTile(
                  title: Text('${entry.calories} kcal'),
                  subtitle: Text(
                    '${entry.mealType ?? 'No meal type'} - ${entry.note ?? ''}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _confirmDelete(context, provider, entry),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddEditEntryScreen(entry: entry),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    CalorieProvider provider,
    CalorieEntry entry,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await provider.deleteEntry(entry);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

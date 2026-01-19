import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/custom_widgets/error_dialog.dart';
import '../provider/calorie_provider.dart';
import '../model/calorie_entry.dart';

class AddEditEntryScreen extends StatefulWidget {
  final CalorieEntry? entry;

  const AddEditEntryScreen({super.key, this.entry});

  @override
  State<AddEditEntryScreen> createState() => _AddEditEntryScreenState();
}

class _AddEditEntryScreenState extends State<AddEditEntryScreen> {
  late DateTime _date;
  late TextEditingController _caloriesController;
  String? _mealType;
  String? _note;

  @override
  void initState() {
    super.initState();

    _date = widget.entry?.date ?? DateTime.now();
    _caloriesController = TextEditingController(
      text: widget.entry?.calories.toString() ?? '',
    );
    _mealType = widget.entry?.mealType;
    _note = widget.entry?.note;
  }

  @override
  void dispose() {
    _caloriesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  Future<void> _save() async {
    final calories = int.tryParse(_caloriesController.text);

    if (calories == null || calories <= 0) {
      showErrorDialog(context, 'Please enter valid calories');
      return;
    }

    final provider = context.read<CalorieProvider>();

    if (widget.entry == null) {
      await provider.addEntry(
        date: _date,
        calories: calories,
        mealType: _mealType,
        note: _note,
      );
    } else {
      final updated = widget.entry!.copyWith(
        date: _date,
        calories: calories,
        mealType: _mealType,
        note: _note,
      );

      await provider.updateEntry(updated);
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.entry != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Entry' : 'Add Entry')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Date
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Date'),
              subtitle: Text('${_date.day}/${_date.month}/${_date.year}'),
              trailing: IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: _pickDate,
              ),
            ),

            // Calories
            TextField(
              controller: _caloriesController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Calories'),
            ),

            const SizedBox(height: 12),

            // Meal Type
            DropdownButtonFormField<String>(
              initialValue: _mealType,
              decoration: const InputDecoration(labelText: 'Meal type'),
              items: CalorieEntry.MEALTYPES.map((type) {
                return DropdownMenuItem(value: type, child: Text(type));
              }).toList(),
              onChanged: (value) {
                setState(() => _mealType = value);
              },
            ),

            const SizedBox(height: 12),

            // Notes
            TextField(
              decoration: const InputDecoration(labelText: 'Notes (optional)'),
              onChanged: (v) => _note = v,
              controller: TextEditingController(text: _note),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

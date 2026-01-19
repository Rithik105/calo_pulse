import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/helper.dart';
import '../model/day_summary.dart';
import '../provider/calorie_provider.dart';
import 'add_edit_entry_ui.dart';
import 'day_view_ui.dart';
import 'drawer_ui.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CalorieProvider>();

    return Scaffold(
      appBar: AppBar(
        title: provider.searchMode
            ? TextField(
                decoration: InputDecoration(
                  hintText: 'Search meals, notes, calories',
                  prefixIcon: Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: provider.clearSearch,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) =>
                    context.read<CalorieProvider>().updateSearch(value),
              )
            : const Text('CaloriePulse'),
        actions: [
          if (!provider.searchMode)
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: provider.toggleSearchMode,
            ),
          if (!provider.searchMode)
            Consumer<CalorieProvider>(
              builder: (_, provider, __) {
                if (provider.fromDate == null) return const SizedBox();

                return TextButton.icon(
                  onPressed: provider.clearDateRange,
                  icon: const Icon(Icons.clear),
                  label: const Text("Clear filter"),
                );
              },
            ),
          if (!provider.searchMode)
            IconButton(
              icon: const Icon(Icons.filter_alt),
              onPressed: () async {
                final result = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                  initialDateRange:
                      context.read<CalorieProvider>().fromDate != null
                      ? DateTimeRange(
                          start: context.read<CalorieProvider>().fromDate!,
                          end: context.read<CalorieProvider>().toDate!,
                        )
                      : null,
                );

                if (result != null) {
                  context.read<CalorieProvider>().setDateRange(
                    result.start,
                    result.end,
                  );
                }
              },
            ),
        ],
      ),
      drawer: const AppDrawer(),
      body: provider.isLoading || provider.daySummaries.isEmpty
          ? const _EmptyState()
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: provider.daySummaries.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _DayCard(summary: provider.daySummaries[index]);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditEntryScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _DayCard extends StatelessWidget {
  final DaySummary summary;

  const _DayCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DayViewScreen(day: summary.date)),
        );
      },
      child: Card(
        elevation: 1.5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formatDate(summary.date),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${summary.totalCalories} kcal',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.local_fire_department, size: 64),
            const SizedBox(height: 16),
            Text(
              'No entries yet',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap + to start tracking your daily calories.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

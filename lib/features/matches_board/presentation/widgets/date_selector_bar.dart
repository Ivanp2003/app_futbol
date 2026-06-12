import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/world_cup_colors.dart';

class DateSelectorBar extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;

  const DateSelectorBar({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final DateTime worldCupStart = DateTime(2026, 6, 11);
    final DateTime worldCupEnd = DateTime(2026, 7, 19);

    // Generate dates around the selected date, bounded by World Cup start and end
    final List<DateTime> dates = [];
    for (int i = -3; i <= 3; i++) {
      final date = selectedDate.add(Duration(days: i));
      if (date.isAfter(worldCupStart.subtract(const Duration(days: 1))) &&
          date.isBefore(worldCupEnd.add(const Duration(days: 1)))) {
        dates.add(date);
      }
    }

    return Container(
      height: 80,
      color: WorldCupColors.cardBackground,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        itemBuilder: (context, index) {
          final date = dates[index];
          final isSelected = date.day == selectedDate.day &&
              date.month == selectedDate.month &&
              date.year == selectedDate.year;

          final dayName = DateFormat('EEE', 'es').format(date).substring(0, 1).toUpperCase();
          final dayNumber = date.day.toString();

          return GestureDetector(
            onTap: () => onDateSelected(date),
            child: Container(
              width: 55,
              margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected 
                    ? WorldCupColors.primaryBlue 
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected 
                      ? Colors.transparent 
                      : Colors.grey.shade300,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dayName,
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? Colors.white : WorldCupColors.textMuted,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dayNumber,
                    style: TextStyle(
                      fontSize: 16,
                      color: isSelected ? Colors.white : WorldCupColors.textDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

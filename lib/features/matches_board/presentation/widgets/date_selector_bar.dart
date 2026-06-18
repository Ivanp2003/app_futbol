import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/world_cup_dates.dart';
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
    // Días visibles acotados al rango oficial del Mundial
    final List<DateTime> dates = [];
    for (int i = -3; i <= 3; i++) {
      final date = selectedDate.add(Duration(days: i));
      if (date.isAfter(WorldCupDates.start.subtract(const Duration(days: 1))) &&
          date.isBefore(WorldCupDates.end.add(const Duration(days: 1)))) {
        dates.add(date);
      }
    }

    return Container(
      height: 85,
      color: WorldCupColors.bg,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        itemBuilder: (context, index) {
          final date = dates[index];
          final isSelected = date.day == selectedDate.day &&
              date.month == selectedDate.month &&
              date.year == selectedDate.year;

          final dayName = DateFormat('EEE', 'es').format(date).toUpperCase();
          final dayNumber = date.day.toString();

          return GestureDetector(
            onTap: () => onDateSelected(date),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 58,
              margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected 
                    ? WorldCupColors.accent 
                    : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dayName.substring(0, 3),
                    style: TextStyle(
                      fontSize: 10,
                      color: isSelected ? Colors.white : WorldCupColors.gray,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dayNumber,
                    style: TextStyle(
                      fontSize: 18,
                      color: isSelected ? Colors.white : WorldCupColors.dark,
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

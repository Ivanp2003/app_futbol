import 'package:flutter/material.dart';
import '../../../../core/theme/world_cup_colors.dart';

class FilterScreen extends StatefulWidget {
  final String currentStatusFilter;
  final String currentStageFilter;

  const FilterScreen({
    super.key,
    required this.currentStatusFilter,
    required this.currentStageFilter,
  });

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  late String _statusFilter;
  late String _stageFilter;

  final List<String> _statuses = ['Todos', 'En Vivo', 'Finalizados', 'Programados'];
  final List<String> _stages = ['Todos', 'Copa del Mundo FIFA', 'Major League Soccer'];

  @override
  void initState() {
    super.initState();
    _statusFilter = widget.currentStatusFilter;
    _stageFilter = widget.currentStageFilter;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WorldCupColors.bg,
      appBar: AppBar(
        title: const Text('Filtrar Partidos', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: WorldCupColors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Estado del Partido',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: WorldCupColors.dark,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: _statuses.map((status) {
                final isSelected = _statusFilter == status;
                return ChoiceChip(
                  label: Text(status),
                  selected: isSelected,
                  selectedColor: WorldCupColors.accent,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : WorldCupColors.dark,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _statusFilter = status;
                      });
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            const Text(
              'Competición',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: WorldCupColors.dark,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: _stages.map((stage) {
                final isSelected = _stageFilter == stage;
                return ChoiceChip(
                  label: Text(stage),
                  selected: isSelected,
                  selectedColor: WorldCupColors.accent,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : WorldCupColors.dark,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _stageFilter = stage;
                      });
                    }
                  },
                );
              }).toList(),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: WorldCupColors.accent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 2,
                ),
                onPressed: () {
                  Navigator.pop(context, {
                    'status': _statusFilter,
                    'stage': _stageFilter,
                  });
                },
                child: const Text(
                  'Aplicar Filtros',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

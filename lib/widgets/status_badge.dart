import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final config = _config(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: config['bg'] as Color,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Text(
        config['label'] as String,
        style: TextStyle(
          color: config['color'] as Color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Map<String, dynamic> _config(String status) {
    switch (status) {
      case 'in_progress':
        return {
          'label': 'In Progress',
          'bg': const Color(0xFFE3F2FD),
          'color': const Color(0xFF0D47A1),
        };
      case 'resolved':
        return {
          'label': 'Resolved',
          'bg': const Color(0xFFE8F5E9),
          'color': const Color(0xFF1B5E20),
        };
      default:
        return {
          'label': 'Pending',
          'bg': const Color(0xFFFFF3E0),
          'color': const Color(0xFFE65100),
        };
    }
  }
}

import 'package:flutter/material.dart';
import '../../core/theme.dart';

class StepAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onBack;
  final String title;

  const StepAppBar({super.key, required this.onBack, required this.title});

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.green.shade100),
          ),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 16,
            color: Color(0xFF1A3A1A),
          ),
        ),
        onPressed: onBack,
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1A3A1A),
        ),
      ),
      centerTitle: true,
    );
  }
}

class ReportStepper extends StatelessWidget {
  final int current; // 0, 1, or 2

  const ReportStepper({super.key, required this.current});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Row(
        children: [
          StepCircle(number: 1, state: _state(0)),
          StepLine(done: current > 0),
          StepCircle(number: 2, state: _state(1)),
          StepLine(done: current > 1),
          StepCircle(number: 3, state: _state(2)),
        ],
      ),
    );
  }

  StepState _state(int index) {
    if (index < current) return StepState.done;
    if (index == current) return StepState.active;
    return StepState.pending;
  }
}

enum StepState { done, active, pending }

class StepCircle extends StatelessWidget {
  final int number;
  final StepState state;

  const StepCircle({super.key, required this.number, required this.state});

  @override
  Widget build(BuildContext context) {
    final isActive = state == StepState.active;
    final isDone = state == StepState.done;

    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: isDone
                ? AppTheme.primaryLight
                : isActive
                ? AppTheme.primary
                : Colors.grey.shade100,
            shape: BoxShape.circle,
            border: Border.all(
              color: isDone
                  ? AppTheme.primary
                  : isActive
                  ? AppTheme.primary
                  : Colors.grey.shade300,
              width: 1.5,
            ),
          ),
          child: Center(
            child: isDone
                ? const Icon(
                    Icons.check_rounded,
                    color: AppTheme.primary,
                    size: 14,
                  )
                : Text(
                    '$number',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isActive ? Colors.white : Colors.grey.shade400,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          ['Photo', 'Details', 'Review'][number - 1],
          style: TextStyle(
            fontSize: 10,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            color: isActive ? AppTheme.primary : Colors.grey.shade400,
          ),
        ),
      ],
    );
  }
}

class StepLine extends StatelessWidget {
  final bool done;
  const StepLine({super.key, required this.done});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 1.5,
        margin: const EdgeInsets.only(bottom: 16),
        color: done ? AppTheme.primary : Colors.grey.shade200,
      ),
    );
  }
}

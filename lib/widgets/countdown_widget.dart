import 'dart:async';
import 'package:flutter/material.dart';

class CountdownWidget extends StatefulWidget {
  final Duration duration;
  final TextStyle? textStyle;
  final bool showDays;
  final VoidCallback? onCountdownFinished;

  const CountdownWidget({
    super.key,
    required this.duration,
    this.textStyle,
    this.showDays = false,
    this.onCountdownFinished,
  });

  @override
  State<CountdownWidget> createState() => _CountdownWidgetState();
}

class _CountdownWidgetState extends State<CountdownWidget> {
  late Timer _timer;
  late Duration _remainingTime;

  @override
  void initState() {
    super.initState();
    _remainingTime = widget.duration;
    _startTimer();
  }

  @override
  void didUpdateWidget(CountdownWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _remainingTime = widget.duration;
      _timer.cancel();
      _startTimer();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime.inSeconds <= 0) {
        timer.cancel();
        widget.onCountdownFinished?.call();
        return;
      }

      setState(() {
        _remainingTime = Duration(seconds: _remainingTime.inSeconds - 1);
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    if (duration.isNegative) return '00:00:00';

    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (widget.showDays && duration.inDays > 0) {
      final days = duration.inDays;
      return '${days}d ${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }

    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _formatDuration(_remainingTime),
      style: widget.textStyle ?? Theme.of(context).textTheme.bodyLarge,
    );
  }
}

class LevelCountdownWidget extends StatelessWidget {
  final Duration levelRemaining;
  final String levelText;
  final bool isBreak;

  const LevelCountdownWidget({
    super.key,
    required this.levelRemaining,
    required this.levelText,
    this.isBreak = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isBreak
            ? theme.colorScheme.secondary.withOpacity(0.1)
            : theme.colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isBreak
              ? theme.colorScheme.secondary.withOpacity(0.3)
              : theme.colorScheme.primary.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Text(
            isBreak ? 'Break Time' : 'Current Level',
            style: theme.textTheme.titleSmall?.copyWith(
              color: isBreak
                  ? theme.colorScheme.secondary
                  : theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            levelText,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.timer_outlined,
                size: 20,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              CountdownWidget(
                duration: levelRemaining,
                textStyle: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

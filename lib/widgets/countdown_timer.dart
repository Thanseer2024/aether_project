import 'dart:async';
import 'package:flutter/material.dart';

class CountdownTimer extends StatefulWidget {
  const CountdownTimer({super.key});

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  late Timer _timer;
  final ValueNotifier<Duration> _remainingNotifier = ValueNotifier<Duration>(const Duration(minutes: 5));
  final Duration _totalDuration = const Duration(minutes: 5);

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    _remainingNotifier.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(milliseconds: 100), (Timer t) {
      if (_remainingNotifier.value.inMilliseconds <= 0) {
        t.cancel();
        return;
      }
      _remainingNotifier.value -= const Duration(milliseconds: 100);
    });
  }

  String _formatDuration(Duration d) {
    final int minutes = d.inMinutes.remainder(60);
    final int seconds = d.inSeconds.remainder(60);
    final int tenths = d.inMilliseconds.remainder(1000) ~/ 100;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}.$tenths';
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Duration>(
      valueListenable: _remainingNotifier,
      builder: (BuildContext context, Duration remaining, Widget? child) {
        final bool isUrgent = remaining.inSeconds < 30;
        final bool isExpired = remaining.inMilliseconds <= 0;
        final Color glowColor = isExpired ? Colors.red : (isUrgent ? Colors.orange : Colors.deepPurple);

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF10102A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: glowColor, width: 2),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: glowColor.withValues(alpha: 0.4),
                blurRadius: 16,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            children: <Widget>[
              const Text(
                'WORLD BOSS SPAWNS IN',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                  letterSpacing: 4,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                isExpired ? '⚠️  BOSS IS HERE!' : _formatDuration(remaining),
                style: TextStyle(
                  color: isExpired ? Colors.redAccent : (isUrgent ? Colors.orange : Colors.white),
                  fontSize: 54,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 6,
                ),
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: remaining.inMilliseconds / _totalDuration.inMilliseconds,
                  backgroundColor: Colors.white12,
                  color: glowColor,
                  minHeight: 6,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/colors.dart';
import '../../../core/typography.dart';
import '../../../utils/audio_manager.dart';
import '../../../utils/haptic.dart';

class DiceWidget extends StatefulWidget {
  final bool enabled;
  final Future<void> Function(int value) onRolled;
  final int? lockedValue;
  final String? labelOverride;

  const DiceWidget({
    super.key,
    required this.enabled,
    required this.onRolled,
    this.lockedValue,
    this.labelOverride,
  });

  @override
  State<DiceWidget> createState() => _DiceWidgetState();
}

class _DiceWidgetState extends State<DiceWidget>
    with SingleTickerProviderStateMixin {
  int _face = 1;
  bool _rolling = false;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _controller.addListener(() {
      if (_rolling) {
        setState(() => _face = Random().nextInt(6) + 1);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _roll() async {
    if (_rolling || !widget.enabled) return;
    setState(() => _rolling = true);
    Haptic.medium();
    AudioManager.instance.playSfx('dice_roll');
    await _controller.forward(from: 0);
    final value = widget.lockedValue ?? Random().nextInt(6) + 1;
    setState(() {
      _face = value;
      _rolling = false;
    });
    AudioManager.instance.playSfx('dice_stop');
    await widget.onRolled(value);
  }

  @override
  Widget build(BuildContext context) {
    final disabled = !widget.enabled || _rolling;
    return GestureDetector(
      onTap: disabled ? null : _roll,
      child: AnimatedOpacity(
        opacity: disabled ? 0.6 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          width: 86,
          height: 86,
          decoration: BoxDecoration(
            color: AppColors.bgSecondary,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: AnimatedRotation(
              turns: _rolling ? 1 : 0,
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeOutBack,
              child: Text(
                widget.labelOverride ?? '$_face',
                style: AppText.header28.copyWith(
                  fontSize: 38,
                  fontWeight: FontWeight.w900,
                  color: AppColors.brand,
                ),
              ),
            ),
          ),
        )
            .animate(target: _rolling ? 1 : 0)
            .scaleXY(end: 1.06, duration: 200.ms)
            .then()
            .scaleXY(begin: 1.06, end: 1.0, duration: 200.ms),
      ),
    );
  }
}

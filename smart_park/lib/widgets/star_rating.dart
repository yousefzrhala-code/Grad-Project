import 'package:flutter/material.dart';
class StarRatingDisplay extends StatelessWidget {
  final double value;
  final double size;
  final Color color;

  const StarRatingDisplay({
    super.key,
    required this.value,
    this.size = 18,
    this.color = const Color(0xFFFFC107),
  });

  @override
  Widget build(BuildContext context) {
    final full = value.floor();
    final half = (value - full) >= 0.5;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        IconData icon;
        if (i < full) {
          icon = Icons.star_rounded;
        } else if (i == full && half) {
          icon = Icons.star_half_rounded;
        } else {
          icon = Icons.star_outline_rounded;
        }
        return Icon(icon, color: color, size: size);
      }),
    );
  }
}

class StarRatingPicker extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  final double size;
  final Color color;

  const StarRatingPicker({
    super.key,
    required this.value,
    required this.onChanged,
    this.size = 32,
    this.color = const Color(0xFFFFC107),
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (i) {
        final filled = i < value;
        return IconButton(
          onPressed: () => onChanged(i + 1),
          icon: Icon(
            filled ? Icons.star_rounded : Icons.star_outline_rounded,
            color: color,
            size: size,
          ),
        );
      }),
    );
  }
}

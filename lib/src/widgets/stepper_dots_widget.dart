import 'package:flutter/material.dart';

const _activeColor = Colors.black;
const _inactiveColor = Color(0xffd9d9e4);

class StepperDotsWidget extends StatelessWidget {
  final int dotsCount;
  final int activeIndex;
  final activeColor;
  final inactiveColor;
  final Function(int index)? onTap;
  const StepperDotsWidget({
    super.key,
    required this.dotsCount,
    required this.activeIndex,
    this.activeColor = _activeColor,
    this.inactiveColor = _inactiveColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: Iterable.generate(dotsCount).map((e) {
        return InkWell(
          onTap: () => onTap?.call(e as int),
          child: Icon(
            Icons.fiber_manual_record,
            color: e == activeIndex ? activeColor : inactiveColor,
          ),
        );
      }).toList(),
    );
  }
}

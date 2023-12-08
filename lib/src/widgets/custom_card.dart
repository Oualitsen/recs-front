import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class CustomCard extends StatelessWidget {
  final Widget? title;
  final List<Widget>? topActions;
  final Widget? bottom;
  final Widget? content;
  final double? elevation;

  CustomCard({
    this.elevation,
    this.title,
    this.topActions,
    this.bottom,
    this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: elevation ?? null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Wrap(
              children: [
                if (title != null) title!,
                if (topActions != null)
                  ...topActions!.map(
                    (e) => Row(
                      children: [Gap(10), e],
                    ),
                  ),
              ],
            ),
            if (content != null) content!,
            if (bottom != null) ...[Gap(16), bottom!]
          ],
        ),
      ),
    );
  }
}

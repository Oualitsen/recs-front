import 'package:flutter/material.dart';

class FutureTailLabel extends StatelessWidget {
  final String text;
  final TextStyle? style;
  const FutureTailLabel(
    this.text, {
    super.key,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return SelectableText(
      text,
      style: style,
    );
  }
}

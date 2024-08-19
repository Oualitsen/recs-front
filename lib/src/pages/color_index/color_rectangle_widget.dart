import 'package:flutter/material.dart';

class ColorRectangle extends StatelessWidget {
  final String hexCode;
  const ColorRectangle({
    super.key,
    required this.hexCode,
  });

  @override
  Widget build(BuildContext context) {
    int color = int.tryParse("0xFF${hexCode.substring(1)}") ?? -1;
    return Tooltip(
      message: hexCode,
      child: SizedBox(
        width: 75,
        height: 25,
        child: color > 0
            ? Container(
                color: Color(color),
              )
            : Placeholder(),
      ),
    );
  }
}

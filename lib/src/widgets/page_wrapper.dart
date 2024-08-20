import 'package:flutter/material.dart';
import 'package:recs_front/src/utils/widget_utils.dart';

class PageWrapper extends StatelessWidget {
  final String title;
  final Widget child;
  const PageWrapper({
    super.key,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return WidgetUtils.wrapRoute((context, type) => Scaffold(
          appBar: AppBar(title: Text(title)),
          body: child,
        ));
  }
}

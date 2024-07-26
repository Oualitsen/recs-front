import 'package:flutter/material.dart';
import 'package:recs_front/src/utils/lang.dart';

class FullPageProgress extends StatelessWidget {
  const FullPageProgress({super.key});

  @override
  Widget build(BuildContext context) {
    var lang = getLang(context);
    return Scaffold(
      appBar: AppBar(title: Text(lang.loading)),
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

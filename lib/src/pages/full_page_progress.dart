import 'package:flutter/material.dart';
import 'package:recs_front/src/utils/lang.dart';

class FullPageProgress extends StatelessWidget {
  final bool noAppBar;
  const FullPageProgress({super.key, this.noAppBar = false});

  @override
  Widget build(BuildContext context) {
    var lang = getLang(context);
    return Scaffold(
      appBar: noAppBar ? null : AppBar(title: Text(lang.loading)),
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

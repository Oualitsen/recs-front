import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:recs_ymal/src/utils/lang.dart';

class NotFoundPage extends StatelessWidget with StatelessLangMixin {
  const NotFoundPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var lang = getLang(context);
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Text(
              "404",
              style: Theme.of(context).textTheme.displayLarge,
            ),
            const Gap(36),
            Text(lang.notFound),
          ],
        ),
      ),
    );
  }
}

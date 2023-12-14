import 'package:flutter/material.dart';
import 'package:html_editor_enhanced/utils/shims/dart_ui_real.dart';
import 'package:recs_ymal/generated/types.gq.dart';
import 'package:recs_ymal/src/utils/lang.dart';

class ReorderableQueueList extends StatelessWidget {
  final List<IndexedProduct> queueItems;
  final Function(int oldIndex, int newIndex) onReorder;
  const ReorderableQueueList({super.key, required this.queueItems, required this.onReorder});

  @override
  Widget build(BuildContext context) {
    var lang = getLang(context);
    return ReorderableListView(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      proxyDecorator: proxyDecorator,
      onReorder: onReorder,
      children: queueItems
          .map(
            (e) => Card(
              key: Key(e.index.toString()),
              color: Colors.blueGrey[50],
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 30),
                height: 80,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SelectableText(e.product.name),
                        SelectableText("${lang.id} : ${e.product.id}"),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget proxyDecorator(Widget child, int index, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        final double animValue = Curves.easeInOut.transform(animation.value);
        final double scale = lerpDouble(1, 1.02, animValue)!;
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: child,
    );
  }
}

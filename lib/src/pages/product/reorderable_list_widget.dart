import 'package:flutter/material.dart';
import 'package:html_editor_enhanced/utils/shims/dart_ui_real.dart';
import 'package:recs_front/generated/types.gq.dart';
import 'package:recs_front/src/utils/lang.dart';

class ReorderableListWidget extends StatelessWidget {
  final double width;
  final double height;
  final Sku originalProduct;
  final List<Sku> queueItems;
  final Function(int oldIndex, int newIndex) onReorder;
  const ReorderableListWidget({
    super.key,
    required this.originalProduct,
    required this.queueItems,
    required this.onReorder,
    this.width = 200,
    this.height = 300,
  });

  @override
  Widget build(BuildContext context) {
    var lang = getLang(context);
    return Row(
      children: [
        Card(
          color: Colors.blueGrey[50],
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 15),
            width: width,
            height: height,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              children: [
                SelectableText(originalProduct.product.name),
                SizedBox(
                  width: width,
                  height: 200,
                  child: Image.network(
                    originalProduct.imageUrl,
                    width: width,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Text(
                          "${lang.errors} : ${originalProduct.imageUrl}");
                    },
                  ),
                ),
                SelectableText("${lang.id} : ${originalProduct.id}"),
              ],
            ),
          ),
        ),
        VerticalDivider(color: Colors.grey, thickness: 1),
        Expanded(
          child: ReorderableListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            proxyDecorator: proxyDecorator,
            onReorder: onReorder,
            children: queueItems
                .map(
                  (e) => Card(
                    key: Key(queueItems.indexOf(e).toString()),
                    color: Colors.blueGrey[50],
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      width: width,
                      height: height,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SelectableText(e.product.name),
                          Image.network(
                            e.imageUrl,
                            width: width,
                            height: 200,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Text("${lang.errors} : ${e.imageUrl}");
                            },
                          ),
                          SelectableText("${lang.id} : ${e.product.id}"),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
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

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:recs_front/generated/types.gq.dart';
import 'package:recs_front/src/utils/lang.dart';

class SkuSimilarityWidget extends StatelessWidget {
  final Sku sku;
  final bool showScore;
  const SkuSimilarityWidget({super.key, required this.sku, required this.showScore});

  @override
  Widget build(BuildContext context) {
    var lang = getLang(context);
    return SizedBox(
      height: 450,
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(16),
          ),
          border: Border.all(
            color: Colors.blueGrey,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              child: Text(
                sku.name,
                softWrap: true,
              ),
              width: 180,
              height: 70,
            ),
            Gap(5),
            SizedBox(
                height: 250,
                width: 200,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    sku.imageUrl,
                    fit: BoxFit.fill,
                  ),
                )),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SelectableText("${lang.productId}: ${sku.id}"),
                SelectableText("${lang.price}: ${sku.price}"),
                SelectableText("${lang.category}: ${sku.category.name} (${sku.category.id})"),
                SelectableText("${lang.brand}: ${sku.brand}"),
                if (showScore) SelectableText("${lang.score}: ${sku.score}"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

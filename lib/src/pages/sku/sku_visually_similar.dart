import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get_it/get_it.dart';
import 'package:recs_front/generated/client.gq.dart';
import 'package:recs_front/generated/types.gq.dart';
import 'package:recs_front/src/utils/widget_utils.dart';
import 'package:recs_front/src/widgets/basic_state.dart';
import 'package:recs_front/src/widgets/widget_utils_mixin.dart';
import 'package:rxdart/rxdart.dart';

class VisuallySimillarSkus extends StatefulWidget {
  final Sku sku;
  const VisuallySimillarSkus({super.key, required this.sku});

  @override
  State<VisuallySimillarSkus> createState() => _VisuallySimillarSkusState();
}

class _VisuallySimillarSkusState extends BasicState<VisuallySimillarSkus>
    with WidgetUtilsMixin {
  final service = GetIt.instance.get<GQClient>();
  final imagesStream = BehaviorSubject.seeded(<Sku>[]);
  @override
  void initState() {
    getImages(skuId: widget.sku.id);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WidgetUtils.wrapRoute(
      (context, type) => Scaffold(
        appBar: AppBar(
          title: Text(lang.similarities),
        ),
        body: Row(
          children: [
            SizedBox(
              height: 450,
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(16),
                  ),
                  border: Border.all(
                    color: Colors.blueGrey,
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      child: Text(
                        widget.sku.product.name,
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
                            widget.sku.imageUrl,
                            fit: BoxFit.fill,
                          ),
                        )),
                    SizedBox(
                      width: 200,
                      height: 40,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Gap(16),
                          SelectableText(
                              "${lang.productId} : ${widget.sku.id}"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Gap(5),
            SizedBox(
              height: 500,
              child: VerticalDivider(
                thickness: 2,
                color: Colors.black,
              ),
            ),
            Gap(5),
            Expanded(
              child: StreamBuilder<List<Sku>>(
                stream: imagesStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        lang.errors,
                        style: TextStyle(color: Colors.red),
                      ),
                    );
                  }
                  if (!snapshot.hasData) {
                    return CircularProgressIndicator();
                  }

                  var data = snapshot.data!;
                  return SizedBox(
                    height: 500,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: data
                          .map(
                            (e) => Padding(
                              padding: const EdgeInsets.all(15),
                              child: Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(16),
                                  ),
                                  border: Border.all(
                                    color:
                                        Colors.blueGrey[300] ?? Colors.blueGrey,
                                    width: 1.5,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      child: Text(
                                        e.product.name,
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
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          child: Image.network(
                                            e.imageUrl,
                                            fit: BoxFit.fill,
                                          ),
                                        )),
                                    SizedBox(
                                      width: 200,
                                      height: 80,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Gap(16),
                                          SelectableText(
                                              "${lang.productId} : ${e.id}"),
                                          Gap(5),
                                          Text("${lang.score} : ${e.score}"),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future getImages({required String skuId}) async {
    var res = <Sku>[];
    res = await service.queries
        .imageSearch(skuId: skuId)
        .asStream()
        .map((event) => event.imageSearch)
        .first;

    imagesStream.add(res);
  }
}

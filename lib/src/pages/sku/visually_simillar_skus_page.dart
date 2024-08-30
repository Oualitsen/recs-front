import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get_it/get_it.dart';
import 'package:recs_front/generated/client.gq.dart';
import 'package:recs_front/generated/types.gq.dart';
import 'package:recs_front/src/pages/full_page_progress.dart';
import 'package:recs_front/src/utils/widget_utils.dart';
import 'package:recs_front/src/widgets/basic_state.dart';
import 'package:recs_front/src/widgets/widget_utils_mixin.dart';
import 'package:rxdart/rxdart.dart';

class VisuallySimillarSkusPage extends StatefulWidget {
  final String skuId;
  const VisuallySimillarSkusPage({super.key, required this.skuId});

  @override
  State<VisuallySimillarSkusPage> createState() => _VisuallySimillarSkusPageState();
}

class _VisuallySimillarSkusPageState extends BasicState<VisuallySimillarSkusPage> with WidgetUtilsMixin {
  final service = GetIt.instance.get<GQClient>();
  final imagesStream = BehaviorSubject.seeded(<Sku>[]);
  final skuSubject = BehaviorSubject<Sku>();
  @override
  void initState() {
    getImages(skuId: widget.skuId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WidgetUtils.wrapRoute(
      (context, type) => FutureBuilder<Sku?>(
          future: loadSku(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              //@TODO handle this
            }
            if (!snapshot.hasData) {
              return FullPageProgress();
            }
            var sku = snapshot.data!;
            return Scaffold(
              appBar: AppBar(
                title: Text("${sku.name}: ${lang.similarities}"),
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
                          SizedBox(
                            width: 200,
                            height: 40,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Gap(16),
                                SelectableText("${lang.productId} : ${sku.id}"),
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
                                          color: Colors.blueGrey[300] ?? Colors.blueGrey,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            child: Text(
                                              e.name,
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
                                                  e.imageUrl,
                                                  fit: BoxFit.fill,
                                                ),
                                              )),
                                          SizedBox(
                                            width: 200,
                                            height: 80,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Gap(16),
                                                SelectableText("${lang.productId} : ${e.id}"),
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
            );
          }),
    );
  }

  Future<Sku?> loadSku() {
    if (skuSubject.hasValue && skuSubject.value.id == widget.skuId) {
      return Future.value(skuSubject.value);
    }
    return service.queries.getSkuById(id: widget.skuId).asStream().map((event) => event.getSkuById).first;
  }

  Future getImages({required String skuId}) async {
    var res = <Sku>[];
    res = await service.queries.imageSearch(skuId: skuId).asStream().map((event) => event.imageSearch).first;

    imagesStream.add(res);
  }
}

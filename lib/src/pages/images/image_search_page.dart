import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get_it/get_it.dart';
import 'package:recs_front/generated/client.gq.dart';
import 'package:recs_front/generated/types.gq.dart';
import 'package:recs_front/src/widgets/basic_state.dart';
import 'package:recs_front/src/widgets/widget_utils_mixin.dart';
import 'package:rxdart/rxdart.dart';

class ImageSearchPage extends StatefulWidget {
  const ImageSearchPage({super.key});

  @override
  State<ImageSearchPage> createState() => _ImageSearchPageState();
}

class _ImageSearchPageState extends BasicState<ImageSearchPage> with WidgetUtilsMixin {
  final service = GetIt.instance.get<GQClient>();
  final imagesStream = BehaviorSubject.seeded(<Sku>[]);
  final inputStream = BehaviorSubject.seeded("");
  final _selectedOption = BehaviorSubject.seeded(true);
  final _waitingOption = BehaviorSubject.seeded(false);
  final inputCtrl = TextEditingController();
  @override
  void initState() {
    inputStream.debounceTime(Duration(milliseconds: 500)).listen((event) {
      if (event.isNotEmpty) {
        _waitingOption.add(true);
        getImages(data: event, isProductId: _selectedOption.value).then((value) => _waitingOption.add(false));
      } else {
        reset();
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<bool>(
          stream: _selectedOption,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return CircularProgressIndicator();
            }
            var isProductId = snapshot.data!;
            return Column(
              children: [
                Row(
                  children: [
                    SizedBox(
                      height: 50,
                      width: 200,
                      child: RadioListTile<bool>(
                        title: Text(lang.productId),
                        value: true,
                        groupValue: isProductId,
                        onChanged: _handleRadioValueChange,
                      ),
                    ),
                    SizedBox(
                      height: 50,
                      width: 200,
                      child: RadioListTile<bool>(
                        title: Text(lang.textSearch),
                        value: false,
                        groupValue: isProductId,
                        onChanged: _handleRadioValueChange,
                      ),
                    ),
                  ],
                ),
                Card(
                  margin: const EdgeInsets.all(15),
                  child: Container(
                    margin: EdgeInsets.all(5),
                    padding: EdgeInsets.all(5),
                    child: SizedBox(
                      height: 50,
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              decoration: InputDecoration(
                                hintText: isProductId ? lang.productId : lang.textSearch,
                                prefixIcon: Icon(Icons.search),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                ),
                              ),
                              controller: inputCtrl,
                              onFieldSubmitted: (value) {
                                inputStream.add(value);
                              },
                              onChanged: (value) {
                                inputStream.add(value);
                              },
                            ),
                          ),
                          Gap(10),
                          IconButton(
                            onPressed: reset,
                            icon: Icon(Icons.cancel, size: 30),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                StreamBuilder<bool>(
                  initialData: _waitingOption.value,
                  stream: _waitingOption,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return CircularProgressIndicator();
                    }
                    bool waitingOption = snapshot.data!;
                    return waitingOption
                        ? Center(
                            child: SizedBox(
                              child: CircularProgressIndicator(),
                              height: 50,
                              width: 50,
                            ),
                          )
                        : StreamBuilder<List<Sku>>(
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
                                height: 450,
                                child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  children: data
                                      .map(
                                        (e) => Card(
                                          color: Colors.blueGrey[50],
                                          child: Padding(
                                            padding: const EdgeInsets.all(15),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text("${lang.name} : ${e.product.name}"),
                                                Gap(5),
                                                Text("${lang.score} : ${e.score}"),
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
                                                Gap(16),
                                                SizedBox(
                                                  child: SelectableText("${lang.productId} : ${e.id}"),
                                                  height: 70,
                                                  width: 200,
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
                          );
                  },
                ),
              ],
            );
          }),
    );
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];

  Future getImages({required String data, required bool isProductId}) async {
    var res = null;

    if (isProductId) {
      print("#########");
      res = await service.queries
          .imageSearch(productId: data)
          .asStream()
          .map((event) => event.imageSearch)
          .first;
    } else {
      res = await service.queries
          .imageSearchByText(data: data)
          .asStream()
          .map((event) => event.imageSearchByText)
          .first;
    }
    if (res != null) {
      imagesStream.add(res);
    } else {
      imagesStream.addError("error");
      _waitingOption.add(false);
    }
  }

  void _handleRadioValueChange(bool? value) {
    if (value != null) {
      _selectedOption.add(value);
      reset();
    }
  }

  void reset() {
    imagesStream.add([]);
    inputStream.add("");
    inputCtrl.text = "";
    _waitingOption.add(false);
  }
}

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:get_it/get_it.dart';
import 'package:recs_front/generated/client.gq.dart';
import 'package:recs_front/generated/types.gq.dart';
import 'package:recs_front/src/data_mapping/collection_mapping_input_widget.dart';
import 'package:recs_front/src/pages/full_page_progress.dart';
import 'package:recs_front/src/utils/lang.dart';
import 'package:rxdart/rxdart.dart';

class DataMappingWidget extends StatefulWidget {
  const DataMappingWidget({super.key});

  @override
  State<DataMappingWidget> createState() => _DataMappingWidgetState();
}

class _DataMappingWidgetState extends State<DataMappingWidget> {
  final mappingSubject = BehaviorSubject<List<CollectionMapping>>();

  final client = GetIt.instance.get<GQClient>();

  @override
  void initState() {
    mappingSubject.listen((mappings) {
      mappings.sort((a, b) => a.collectionLabel.toLowerCase().compareTo(b.collectionLabel.toLowerCase()));
    });
    client.queries.collectionMappins().then((value) => mappingSubject.add(value.collectionMappings));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<CollectionMapping>>(
        stream: mappingSubject,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return FullPageProgress();
          }
          var mappings = snapshot.data!;
          return DefaultTabController(
            length: mappings.length,
            child: Column(
              children: [
                TabBar(
                  isScrollable: true,
                  tabs: mappings
                      .map(
                        (e) => Tab(
                          child: SizedBox(
                            width: 150,
                            child: Row(
                              children: [
                                Text(
                                  e.collectionLabel,
                                  style: TextStyle(color: getStatusColor(e)),
                                ),
                                Spacer(),
                                getStatusIcon(e),
                                Gap(16)
                              ],
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                Expanded(
                  child: TabBarView(
                    children: mappings
                        .map((e) => CollectionMappingInputWidget(
                              collectionMapping: e,
                              onChange: (tm) {
                                int index = mappings
                                    .indexWhere((element) => element.collectionName == tm.collectionName);
                                if (index != -1) {
                                  setState(() {
                                    mappings[index] = tm;
                                  });
                                }
                              },
                            ))
                        .toList(),
                  ),
                ),
              ],
            ),
          );
        });
  }

  Color? getStatusColor(CollectionMapping mapping) {
    var pos = getPositioveValue(mapping);
    if (pos) {
      return Theme.of(context).tabBarTheme.labelStyle?.color;
    }
    return Theme.of(context).colorScheme.error;
  }

  bool getPositioveValue(CollectionMapping mapping) {
    try {
      mapping.fields.firstWhere((col) => col.required && col.csvFieldValue == null);
      return false;
    } catch (error) {
      return true;
    }
  }

  Widget getStatusIcon(CollectionMapping mapping) {
    return TabStatusIcon(getPositioveValue(mapping));
  }
}

class TabStatusIcon extends StatelessWidget with StatelessLangMixin {
  final bool positive;
  final iconSize = 16.0;

  const TabStatusIcon(this.positive, {super.key});

  @override
  Widget build(BuildContext context) {
    var lang = getLang(context);
    if (positive) {
      return Tooltip(
        child: Icon(
          FontAwesomeIcons.circleCheck,
          size: iconSize,
        ),
        message: lang.tabStatusPos,
      );
    } else {
      return Tooltip(
        child: Icon(
          FontAwesomeIcons.circleXmark,
          color: Theme.of(context).colorScheme.error,
          size: iconSize,
        ),
        message: lang.tabStatusNeg,
      );
    }
  }
}

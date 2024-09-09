import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get_it/get_it.dart';
import 'package:recs_front/generated/client.gq.dart';
import 'package:recs_front/generated/enums.gq.dart';
import 'package:recs_front/generated/inputs.gq.dart';
import 'package:recs_front/generated/types.gq.dart';
import 'package:recs_front/src/pages/category/select_category_widget.dart';
import 'package:recs_front/src/utils/ui_utils.dart';
import 'package:recs_front/src/utils/validation_utils.dart';
import 'package:recs_front/src/widgets/basic_state.dart';
import 'package:recs_front/src/widgets/widget_utils_mixin.dart';
import 'package:rxdart/rxdart.dart';

class AdjacencyInputForm extends StatefulWidget {
  final AdjacencyType adjacencyType;
  const AdjacencyInputForm({
    super.key,
    required this.adjacencyType,
  });

  @override
  State<AdjacencyInputForm> createState() => AdjacencyInputFormState();
}

class AdjacencyInputFormState extends BasicState<AdjacencyInputForm> with WidgetUtilsMixin {
  final client = GetIt.instance.get<GQClient>();
  final formKey = GlobalKey<FormState>();
  final firstEntryStream = BehaviorSubject<String>();
  final secondEntryStream = BehaviorSubject<String>();

  final firstEntryStreamCat = BehaviorSubject<Category>();
  final secondEntryStreamCat = BehaviorSubject<Category>();
  final allEntriesStream = BehaviorSubject.seeded(<String>[]);
  final entry1Ctrl = TextEditingController();
  final entry2Ctrl = TextEditingController();
  final distanceCtrl = TextEditingController();
  @override
  void initState() {
    getEntries();
    firstEntryStream.listen((value) {
      entry1Ctrl.text = value;
    });
    secondEntryStream.listen((value) {
      entry2Ctrl.text = value;
    });
    firstEntryStreamCat.listen((value) {
      firstEntryStream.add("${value.name} (${value.id})");
    });
    secondEntryStreamCat.listen((value) {
      secondEntryStream.add("${value.name} (${value.id})");
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Form(
        key: formKey,
        child: Column(
          children: [
            wrapInIgnorePointer(
              onTap: () => selectEntry(true),
              child: TextFormField(
                  textInputAction: TextInputAction.next,
                  controller: entry1Ctrl,
                  validator: (text) {
                    return ValidationUtils.requiredField(text, context);
                  },
                  decoration: getDecoration(lang.entry1, true)),
            ),
            Gap(16),
            wrapInIgnorePointer(
              onTap: () => selectEntry(false),
              child: TextFormField(
                  textInputAction: TextInputAction.next,
                  controller: entry2Ctrl,
                  validator: (text) {
                    return ValidationUtils.requiredField(text, context);
                  },
                  decoration: getDecoration(lang.entry2, true)),
            ),
            Gap(16),
            TextFormField(
              controller: distanceCtrl,
              decoration: getDecoration(lang.distance, true),
              validator: (text) => ValidationUtils.doubleValidator(
                text,
                context,
                required: true,
                minValue: 0,
                maxValue: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future selectEntry(bool isFirst) async {
    if (widget.adjacencyType == AdjacencyType.CATEGORY) {
      var category = await selectCategories();
      if (category != null) {
        if (isFirst) {
          firstEntryStreamCat.add(category);
        } else {
          secondEntryStreamCat.add(category);
        }
      }
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              lang.dataType,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.black87),
            ),
            content: SizedBox(
              height: 400,
              width: 500,
              child: streamBuilder(
                stream: allEntriesStream,
                onDataChanged: (entries) {
                  return ListView(
                    children: entries
                        .map(
                          (e) => ListTile(
                            title: Text(e),
                            onTap: () {
                              if (isFirst) {
                                firstEntryStream.add(e);
                              } else {
                                secondEntryStream.add(e);
                              }
                              Navigator.of(context).pop();
                            },
                          ),
                        )
                        .toList(),
                  );
                },
              ),
            ),
          );
        },
      );
    }
  }

  Future<Category?> selectCategories() async {
    return showDialog<Category?>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            lang.categories,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.black87),
          ),
          content: SizedBox(
            height: 400,
            width: 500,
            child: SelectCategoryWidget(
                selectedCategory: (category) {
                  if (category.isNotEmpty) {
                    Navigator.of(context).pop(category.first);
                  } else {
                    Navigator.of(context).pop(null);
                  }
                },
                initialElements: []),
          ),
        );
      },
    );
  }

  Future getEntries() async {
    if (widget.adjacencyType != AdjacencyType.CATEGORY) {
      progressSubject.add(true);
      try {
        var res = await client.queries
            .getAdjecencyEntries(type: widget.adjacencyType)
            .asStream()
            .map((event) => event.getAdjecencyEntries)
            .first;
        allEntriesStream.add(res);
      } catch (error, stacktrace) {
        print(stacktrace);
        showServerError2(context, error: error);
      } finally {
        progressSubject.add(false);
      }
    }
  }

  AdjacencyInput? read() {
    if ((formKey.currentState?.validate() ?? false) &&
        firstEntryStream.valueOrNull != null &&
        secondEntryStream.valueOrNull != null) {
      if (widget.adjacencyType == AdjacencyType.CATEGORY) {
        return AdjacencyInput(
          entryId1: firstEntryStreamCat.value.id,
          entryId2: secondEntryStreamCat.value.id,
          distance: double.tryParse(distanceCtrl.text) ?? -1,
          type: widget.adjacencyType,
          manual: true,
        );
      } else {
        return AdjacencyInput(
          entryId1: firstEntryStream.value,
          entryId2: secondEntryStream.value,
          distance: double.tryParse(distanceCtrl.text) ?? -1,
          type: widget.adjacencyType,
          manual: true,
        );
      }
    }
    return null;
  }
}

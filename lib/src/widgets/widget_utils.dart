import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:recs_front/generated/client.gq.dart';
import 'package:recs_front/generated/types.gq.dart';
import 'package:recs_front/src/pages/category/select_category_tree_widget.dart';
import 'package:recs_front/src/utils/lang.dart';
import 'package:recs_front/src/widgets/item_select_widget.dart';

Future<Season> openSelectOneSeason(BuildContext context) async {
  var lang = getLang(context);
  var selected = await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(lang.seasons),
      content: SizedBox(
        width: 600,
        height: 400,
        child: ItemSelectWidget<Season>(
          onSelected: (items) {
            print("Selected items = ${items.length}");
          },
          multiple: false,
          displayItem: (s) {
            return ListTile(
              title: Text(s.code),
            );
          },
          getItems: (i, _) {
            if (i == 0) {
              var client = GetIt.instance.get<GQClient>();
              return client.queries.getSeasons().asStream().map((event) => event.getSeasons).first;
            }
            return Future.value([]);
          },
        ),
      ),
    ),
  );
  return selected;
}

class MySeason extends Season {
  MySeason({required super.code, required super.endDate, required super.startDate});

  @override
  bool operator ==(other) {
    if (other is Season) {
      return code == other.code;
    }
    return false;
  }

  static MySeason of(Season s) => MySeason(code: s.code, endDate: s.endDate, startDate: s.startDate);
}

Future<List<Season>?> openSelectMultiSeason(BuildContext context, List<Season> preselected) async {
  var lang = getLang(context);
  var key = GlobalKey<ItemSelectWidgetState>();
  var selected = await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(lang.seasons),
      content: SizedBox(
        width: 600,
        height: 400,
        child: ItemSelectWidget<MySeason>(
          key: key,
          preselectedValues: preselected.map((e) => MySeason.of(e)).toList(),
          onSelected: (items) {
            Navigator.of(context).pop(items);
          },
          multiple: true,
          displayItem: (s) {
            return ListTile(
              title: Text(s.code),
            );
          },
          getItems: (i, _) {
            if (i == 0) {
              var client = GetIt.instance.get<GQClient>();
              return client.queries
                  .getSeasons()
                  .asStream()
                  .map((data) => data.getSeasons.map((e) => MySeason.of(e)).toList())
                  .first;
            }
            return Future.value([]);
          },
        ),
      ),
      actions: [
        TextButton(onPressed: Navigator.of(context).pop, child: Text(lang.cancel)),
        TextButton(
            onPressed: () {
              Navigator.of(context).pop(key.currentState!.getSelectedItems());
            },
            child: Text(lang.ok)),
      ],
    ),
  );

  return selected;
}

Future<List<Category>> openSelectCategyTree(
  BuildContext context,
  List<String> preselected,
) async {
  var lang = getLang(context);
  var key = GlobalKey<SelectCategoryTreeWidgetState>();
  var selected = await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(lang.seasons),
      content: SizedBox(
        width: 600,
        height: 400,
        child: SelectCategoryTreeWidget(
          key: key,
          preselectedValues: preselected,
        ),
      ),
      actions: [
        TextButton(onPressed: Navigator.of(context).pop, child: Text(lang.cancel)),
        TextButton(
            onPressed: () {
              Navigator.of(context).pop(key.currentState!.getSelectedItems());
            },
            child: Text(lang.ok)),
      ],
    ),
  );
  return selected ?? [];
}

Future<List<String>> openSelectMultiTexts(
  BuildContext context,
  Future<List<String>> Function() loadData,
  List<String> preselected,
) async {
  var lang = getLang(context);
  var key = GlobalKey<ItemSelectWidgetState>();
  var selected = await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(lang.seasons),
      content: SizedBox(
        width: 600,
        height: 400,
        child: ItemSelectWidget<String>(
          key: key,
          preselectedValues: preselected,
          onSelected: (items) {
            Navigator.of(context).pop(items);
          },
          multiple: true,
          displayItem: (s) {
            return ListTile(
              title: Text(s),
            );
          },
          getItems: (i, _) {
            if (i == 0) {
              return loadData();
            }
            return Future.value([]);
          },
        ),
      ),
      actions: [
        TextButton(onPressed: Navigator.of(context).pop, child: Text(lang.cancel)),
        TextButton(
            onPressed: () {
              Navigator.of(context).pop(key.currentState!.getSelectedItems());
            },
            child: Text(lang.ok)),
      ],
    ),
  );
  return selected ?? [];
}

Future<List<String>> openSelectBrands(BuildContext context, List<String> preselected) {
  var client = GetIt.instance.get<GQClient>();
  return openSelectMultiTexts(
      context, () => client.queries.getAllBrands().asStream().map((event) => event.data).first, preselected);
}

Future<List<String>> openSelectDesigners(BuildContext context, List<String> preselected) {
  var client = GetIt.instance.get<GQClient>();
  return openSelectMultiTexts(context,
      () => client.queries.getAllDesigners().asStream().map((event) => event.data).first, preselected);
}

Future<List<String>> openSelectGenders(BuildContext context, List<String> preselected) {
  var client = GetIt.instance.get<GQClient>();
  return openSelectMultiTexts(
      context, () => client.queries.getAllGenders().asStream().map((event) => event.data).first, preselected);
}

Future<List<String>> openSelectColorLabels(BuildContext context, List<String> preselected) {
  var client = GetIt.instance.get<GQClient>();
  return openSelectMultiTexts(context,
      () => client.queries.getAllColorLabels().asStream().map((event) => event.data).first, preselected);
}

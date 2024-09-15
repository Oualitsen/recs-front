import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:recs_front/generated/client.gq.dart';
import 'package:recs_front/generated/enums.gq.dart';
import 'package:recs_front/generated/inputs.gq.dart';
import 'package:recs_front/generated/types.gq.dart';
import 'package:recs_front/src/pages/category/select_category_tree_widget.dart';
import 'package:recs_front/src/pages/product/product_table.dart';
import 'package:recs_front/src/pages/product/sku_table.dart';
import 'package:recs_front/src/utils/lang.dart';
import 'package:recs_front/src/utils/utils.dart';
import 'package:recs_front/src/widgets/item_select_widget.dart';
import 'package:recs_front/src/widgets/selection_type.dart';

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

class MyProduct extends Product {
  MyProduct(
      {required super.brand,
      required super.category,
      required super.creationDate,
      required super.designer,
      required super.firstImageUrl,
      required super.forKids,
      required super.gender,
      required super.id,
      required super.lastUpdate,
      required super.longDescription,
      required super.name,
      required super.oldPrice,
      required super.price,
      required super.score,
      required super.shortDescription,
      required super.skuCount,
      required super.skuList});
  @override
  bool operator ==(other) {
    if (other is Product) {
      return id == other.id;
    }
    return false;
  }

  static MyProduct of(Product s) => MyProduct(
      brand: s.brand,
      category: s.category,
      creationDate: s.creationDate,
      designer: s.designer,
      firstImageUrl: s.firstImageUrl,
      forKids: s.forKids,
      gender: s.gender,
      id: s.id,
      lastUpdate: s.lastUpdate,
      longDescription: s.longDescription,
      name: s.name,
      oldPrice: s.oldPrice,
      price: s.price,
      score: s.score,
      shortDescription: s.shortDescription,
      skuCount: s.skuCount,
      skuList: s.skuList);

  static MyProduct ofProductDetails(ProductDetails s) => MyProduct(
      brand: s.brand,
      category: s.category,
      creationDate: s.creationDate,
      designer: s.designer,
      firstImageUrl: s.firstImageUrl,
      forKids: s.forKids,
      gender: s.gender,
      id: s.id,
      lastUpdate: s.lastUpdate,
      longDescription: s.longDescription,
      name: s.name,
      oldPrice: s.oldPrice,
      price: s.price,
      score: s.score,
      shortDescription: s.shortDescription,
      skuCount: s.skuCount,
      skuList: []);
}

class MySku extends Sku {
  MySku({
    required super.brand,
    required super.category,
    required super.colorLabel,
    required super.creationDate,
    required super.shortDescription,
    required super.longDescription,
    required super.designer,
    required super.forKids,
    required super.gender,
    required super.gtin,
    required super.id,
    required super.imageUrl,
    required super.inventories,
    required super.lastUpdate,
    required super.oldPrice,
    required super.price,
    required super.score,
    required super.totalInventory,
    required super.name,
    required super.colorPercentages,
  });
  @override
  bool operator ==(other) {
    if (other is Sku) {
      return id == other.id;
    }
    return false;
  }

  static MySku of(Sku s) => MySku(
      brand: s.brand,
      category: s.category,
      colorLabel: s.colorLabel,
      creationDate: s.creationDate,
      shortDescription: s.shortDescription,
      longDescription: s.longDescription,
      designer: s.designer,
      forKids: s.forKids,
      gender: s.gender,
      gtin: s.gtin,
      id: s.id,
      imageUrl: s.imageUrl,
      inventories: s.inventories,
      lastUpdate: s.lastUpdate,
      oldPrice: s.oldPrice,
      price: s.price,
      score: s.score,
      totalInventory: s.totalInventory,
      name: s.name,
      colorPercentages: s.colorPercentages);
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

Future<List<Product>?> openSelectMultiProducts(BuildContext context, List<Product> preselected) async {
  var lang = getLang(context);
  var key = GlobalKey<ProductTableWidgetState>();
  var selected = await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(lang.products),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 800,
          height: 800,
          child: ProductTableWidget(
            key: key,
            selectionType: SelectionType.MULTIPLE,
            preselected: preselected
                .map((e) => ProductDetails(
                    brand: e.brand,
                    category: e.category,
                    creationDate: e.creationDate,
                    designer: e.designer,
                    firstImageUrl: e.firstImageUrl,
                    forKids: e.forKids,
                    gender: e.gender,
                    id: e.id,
                    lastUpdate: e.lastUpdate,
                    longDescription: e.longDescription,
                    name: e.name,
                    oldPrice: e.oldPrice,
                    price: e.price,
                    score: e.score,
                    shortDescription: e.shortDescription,
                    skuCount: 0))
                .toList(),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: Navigator.of(context).pop, child: Text(lang.cancel)),
        TextButton(
            onPressed: () {
              var selectedProducts = key.currentState!.getSelectedItems();
              if (selectedProducts.isNotEmpty) {
                Navigator.of(context)
                    .pop(selectedProducts.map((e) => MyProduct.ofProductDetails(e)).toList());
              } else {
                showAlertDialog(
                  context: context,
                  title: lang.warning,
                  message: lang.selectAtLeastOneProduct,
                );
              }
            },
            child: Text(lang.ok)),
      ],
    ),
  );

  return selected;
}

Future<List<Sku>?> openSelectMultiSkus(BuildContext context, List<Sku> preselected) async {
  var lang = getLang(context);
  var key = GlobalKey<SkuTableWidgetState>();
  var selected = await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(lang.products),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 800,
          height: 800,
          child: SkuTableWidget(
            key: key,
            selectionType: SelectionType.MULTIPLE,
            preselected: preselected.map((e) => Sku.fromJson(e.toJson())).toList(),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: Navigator.of(context).pop, child: Text(lang.cancel)),
        TextButton(
            onPressed: () {
              var selectedProducts = key.currentState!.getSelectedItems();
              if (selectedProducts.isNotEmpty) {
                Navigator.of(context).pop(selectedProducts.map((e) => MySku.of(e)).toList());
              } else {
                showAlertDialog(
                  context: context,
                  title: lang.warning,
                  message: lang.selectAtLeastOneProduct,
                );
              }
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
  Future<List<String>> Function(int pageIndex) loadData,
  List<String> preselected,
  String title,
) async {
  var lang = getLang(context);
  var key = GlobalKey<ItemSelectWidgetState>();
  var selected = await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
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
            return loadData(i);
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
      context,
      (index) => client.queries
          .findUniqueValuesByType(
              pageInfo: PageInfo(page: index, size: 10), search: null, type: UniqueValueType.BRAND)
          .asStream()
          .map((event) => event.data)
          .first,
      preselected,
      getLang(context).brands);
}

Future<List<String>> openSelectDesigners(BuildContext context, List<String> preselected) {
  var client = GetIt.instance.get<GQClient>();
  return openSelectMultiTexts(
      context,
      (index) => client.queries
          .findUniqueValuesByType(
              pageInfo: PageInfo(page: index, size: 10), search: null, type: UniqueValueType.DESIGNER)
          .asStream()
          .map((event) => event.data)
          .first,
      preselected,
      getLang(context).designers);
}

Future<List<String>> openSelectGenders(BuildContext context, List<String> preselected) {
  var client = GetIt.instance.get<GQClient>();
  return openSelectMultiTexts(
      context,
      (index) => client.queries
          .findUniqueValuesByType(
              pageInfo: PageInfo(page: index, size: 10), search: null, type: UniqueValueType.GENDER)
          .asStream()
          .map((event) => event.data)
          .first,
      preselected,
      getLang(context).genders);
}

Future<List<String>> openSelectColorLabels(BuildContext context, List<String> preselected) {
  var client = GetIt.instance.get<GQClient>();
  return openSelectMultiTexts(
      context,
      (index) => client.queries
          .findUniqueValuesByType(
              pageInfo: PageInfo(page: index, size: 10), search: null, type: UniqueValueType.COLOR_LABEL)
          .asStream()
          .map((event) => event.data)
          .first,
      preselected,
      getLang(context).colorLabels);
}

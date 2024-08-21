import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get_it/get_it.dart';
import 'package:infinite_scroll_list_view_2/infinite_scroll_list_view.dart';
import 'package:recs_front/generated/inputs.gq.dart';
import 'package:recs_front/generated/types.gq.dart';
import 'package:recs_front/src/pages/color_index/color_adjacency_table.dart';
import 'package:recs_front/src/pages/color_index/color_rectangle_widget.dart';
import 'package:recs_front/src/utils/validation_utils.dart';
import 'package:recs_front/src/widgets/basic_state.dart';
import 'package:recs_front/src/widgets/custom_text_input_widget.dart';
import 'package:recs_front/src/widgets/widget_utils_mixin.dart';
import 'package:rxdart/rxdart.dart';
import 'package:recs_front/generated/client.gq.dart';

class ColorAdjacencyFilter extends StatefulWidget {
  final String colorHex;
  final Function(String newDistance) onDistanceUpdate;
  const ColorAdjacencyFilter({
    super.key,
    required this.colorHex,
    required this.onDistanceUpdate,
  });

  @override
  State<ColorAdjacencyFilter> createState() => ColorAdjacencyFilterState();
}

class ColorAdjacencyFilterState extends BasicState<ColorAdjacencyFilter>
    with WidgetUtilsMixin {
  final client = GetIt.instance.get<GQClient>();
  final editStream = BehaviorSubject<ColorIndex?>();
  final listKey = GlobalKey<InfiniteScrollListViewState>();
  final distanceInputKey = GlobalKey<CustomTextInputWidgetState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InfiniteScrollListView<ColorIndex>(
        key: listKey,
        elementBuilder: (context, element, index, animation) {
          ColorInfo color1 = element.color1 == widget.colorHex
              ? ColorInfo(colorHex: element.color1, name: element.name1)
              : ColorInfo(colorHex: element.color2, name: element.name2);
          ColorInfo color2 = element.color1 == widget.colorHex
              ? ColorInfo(colorHex: element.color2, name: element.name2)
              : ColorInfo(colorHex: element.color1, name: element.name1);
          return ListTile(
            title: Row(
              children: [
                Gap(10),
                Text(color1.name),
                Gap(5),
                ColorRectangle(
                  hexCode: color1.colorHex,
                ),
                Gap(25),
                ColorRectangle(
                  hexCode: color2.colorHex,
                ),
                Gap(5),
                SizedBox(
                  width: 150,
                  child: Text(color2.name),
                ),
                Gap(25),
                StreamBuilder<ColorIndex?>(
                  stream: editStream,
                  builder: (context, snapshot) {
                    var currentEdit = snapshot.data;
                    if (currentEdit == null) {
                      return Row(
                        children: [
                          SizedBox(
                            width: 75,
                            child: Text(element.distance != null
                                ? element.distance!.toStringAsFixed(4)
                                : lang.na),
                          ),
                          Gap(5),
                          IconButton(
                              onPressed: () {
                                editStream.add(element);
                              },
                              icon: Icon(Icons.edit))
                        ],
                      );
                    }
                    if (currentEdit.id != element.id) {
                      return SizedBox(
                        width: 75,
                        child: Text(element.distance != null
                            ? element.distance!.toStringAsFixed(4)
                            : lang.na),
                      );
                    }
                    return Row(
                      children: [
                        CustomTextInputWidget(
                          key: distanceInputKey,
                          showPrefixIcon: false,
                          initValue: element.distance?.toStringAsFixed(4),
                          validator: (p0) {
                            return ValidationUtils.doubleValidator(p0, context,
                                required: true, minValue: 0);
                          },
                          onFieldSubmitted: (_) => update(),
                        ),
                        Gap(5),
                        IconButton(onPressed: update, icon: Icon(Icons.check)),
                        IconButton(
                            onPressed: () => editStream.add(null),
                            icon: Icon(Icons.cancel)),
                      ],
                    );
                  },
                ),
              ],
            ),
          );
        },
        pageLoader: pageLoader);
  }

  Future<List<ColorIndex>?> pageLoader(int index) {
    return client.queries
        .getColorIndexByColorHex(
            color: widget.colorHex, pageInfo: PageInfo(page: index, size: 10))
        .asStream()
        .map((event) => event.findColorIndexByColorHex)
        .first;
  }

  update() {
    var value = distanceInputKey.currentState?.getValue();
    if (value != null) {
      widget.onDistanceUpdate(value);
    }
  }
}

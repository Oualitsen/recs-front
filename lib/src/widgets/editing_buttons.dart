import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:get_it/get_it.dart';
import 'package:recs_ymal/generated/client.gq.dart';
import 'package:recs_ymal/src/widgets/basic_state.dart';
import 'package:recs_ymal/src/widgets/widget_utils_mixin.dart';
import 'package:rxdart/rxdart.dart';

class EditingButtons extends StatefulWidget {
  final VoidCallback onSave;
  const EditingButtons({super.key, required this.onSave});

  @override
  State<EditingButtons> createState() => _EditingButtonsState();
}

class _EditingButtonsState extends BasicState<EditingButtons> with WidgetUtilsMixin {
  final service = GetIt.instance.get<GQClient>();
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton(
          onPressed: () {},
          child: Icon(
            FontAwesomeIcons.arrowsRotate,
            size: 18,
          ),
        ),
        Gap(16),
        ElevatedButton(
          onPressed: () {},
          child: Icon(
            Icons.undo,
            size: 18,
          ),
        ),
        Gap(16),
        ElevatedButton(
          onPressed: () {},
          child: Icon(
            Icons.redo,
            size: 18,
          ),
        ),
        Gap(16),
        getButtons(skipCancel: true, saveLabel: lang.save, onSave: widget.onSave),
        Gap(16),
      ],
    );
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];
}

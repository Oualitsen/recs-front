import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:get_it/get_it.dart';
import 'package:recs_front/generated/client.gq.dart';
import 'package:recs_front/src/widgets/basic_state.dart';
import 'package:recs_front/src/widgets/widget_utils_mixin.dart';
import 'package:rxdart/rxdart.dart';
import 'package:undo/undo.dart';

class EditingButtons<T> extends StatefulWidget {
  final VoidCallback onSave;
  final VoidCallback onAdd;
  final VoidCallback onRefresh;
  final T initValue;
  final Function(T) onUpdate;
  const EditingButtons({
    super.key,
    required this.onSave,
    required this.onUpdate,
    required this.initValue,
    required this.onRefresh,
    required this.onAdd,
  });

  @override
  State<EditingButtons<T>> createState() => EditingButtonsState<T>();
}

class EditingButtonsState<T> extends BasicState<EditingButtons<T>> with WidgetUtilsMixin {
  final service = GetIt.instance.get<GQClient>();
  late SimpleStack<T> _controller;
  final controllerStream = BehaviorSubject.seeded(_DoState());

  @override
  void initState() {
    _controller = SimpleStack<T>(
      widget.initValue,
      onUpdate: (val) {
        if (mounted) {
          widget.onUpdate(val);
        }
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<_DoState>(
        stream: controllerStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          }
          var data = snapshot.data!;
          return Row(
            children: [
              getButtons(skipCancel: true, saveLabel: lang.add, onSave: widget.onAdd),
              Spacer(),
              ElevatedButton(
                onPressed: () {
                  widget.onRefresh();
                  refresh();
                },
                child: Icon(
                  FontAwesomeIcons.arrowsRotate,
                  size: 18,
                ),
              ),
              Gap(16),
              ElevatedButton(
                onPressed: !data.canUndo ? null : undo,
                child: Icon(
                  Icons.undo,
                  size: 18,
                ),
              ),
              Gap(16),
              ElevatedButton(
                onPressed: !controllerStream.value.canRedo ? null : redo,
                child: Icon(
                  Icons.redo,
                  size: 18,
                ),
              ),
              Gap(16),
              getButtons(
                  skipCancel: true,
                  saveLabel: lang.save,
                  onSave: () {
                    widget.onSave();
                    refresh();
                  }),
              Gap(16),
            ],
          );
        });
  }

  updateStack(T value) {
    _controller.modify(value);
    updateSubject();
  }

  void undo() {
    if (mounted) {
      _controller.undo();
      updateSubject();
    }
  }

  void redo() {
    if (mounted) {
      _controller.redo();
      updateSubject();
    }
  }

  void updateSubject() {
    var current = controllerStream.value;
    current.canRedo = _controller.canRedo;
    current.canUndo = _controller.canUndo;
    controllerStream.add(current);
  }

  void refresh() {
    if (mounted) {
      _controller.clearHistory();
      updateSubject();
    }
  }

  @override
  List<ChangeNotifier> get notifiers => [];

  @override
  List<Subject> get subjects => [];
}

class _DoState {
  bool canRedo = false;
  bool canUndo = false;
}

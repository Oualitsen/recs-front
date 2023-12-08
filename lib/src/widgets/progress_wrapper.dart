import 'package:flutter/material.dart';

class ProgressWrapper extends StatelessWidget {
  final Stream<bool> progressStream;
  final Widget child;
  final Widget progressChild;
  const ProgressWrapper(
      {Key? key,
      required this.progressStream,
      required this.child,
      this.progressChild = const Text("...")})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return snapshot.data! ? progressChild : child;
        }
        return const SizedBox.shrink();
      },
      stream: progressStream,
    );
  }
}

import 'package:flutter/material.dart';

class CustomPageRoute<T> extends PageRouteBuilder<T> {
  CustomPageRoute({
    super.settings,
    super.fullscreenDialog,
    required super.pageBuilder,
  });

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    final view = super.pageBuilder(context, animation, secondaryAnimation);

    if (super.fullscreenDialog) {
      return SafeArea(
        child: Container(
          padding: const EdgeInsets.all(8.0),
          color: Colors.black.withOpacity(.6),
          child: view,
        ),
      );
    }

    //return FadeTransition(opacity: animation, child: view);

    return view;
  }

  @override
  bool get opaque => !super.fullscreenDialog;

  @override
  String get debugLabel => '${super.debugLabel}(${settings.name})';

  @override
  Duration get transitionDuration => const Duration(milliseconds: 0);
}

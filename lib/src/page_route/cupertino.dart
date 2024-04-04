import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomCupertinoRoute<T> extends PageRoute<T> with CupertinoRouteTransitionMixin<T> {
  CustomCupertinoRoute({
    required this.builder,
    super.settings,
    super.fullscreenDialog,
    this.maintainState = true,
  });

  final WidgetBuilder builder;

  @override
  Widget buildContent(BuildContext context) {
    final view = builder(context);

    if (super.fullscreenDialog) {
      return SafeArea(
        child: Container(
          padding: const EdgeInsets.all(8.0),
          color: Colors.black.withOpacity(.6),
          child: view,
        ),
      );
    }

    return view;
  }

  @override
  bool get opaque => !super.fullscreenDialog;

  @override
  final bool maintainState;

  @override
  String get debugLabel => '${super.debugLabel}(${settings.name})';

  @override
  String? get title => '';
}
import 'package:flutter/widgets.dart';

class ModuleRoute {
  ModuleRoute({
    required this.path,
    required this.builder,
    this.allowAnonymous = false,
  });

  final String path;
  final Widget Function(dynamic args) builder;
  final bool allowAnonymous;
}
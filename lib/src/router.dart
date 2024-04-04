import 'dart:io' show Platform;

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'exception.dart';
import 'model/module.dart';
import 'model/route.dart';
import 'page_route/cupertino.dart';
import 'page_route/default.dart';
import 'page_route/material.dart';
import 'views/unauthorized_route.dart';
import 'views/unknown_route.dart';

mixin ModuleRouterMixin {
  List<RouterModule> get modules;
  bool get enableAuthorize => false;
  bool get authorized => false;
  String get unauthorizedRedirectRoute => '';

  //void listener(RouterModule module) {}

  Route onGenerateRoute(RouteSettings routeSettings) {
    if (routeSettings.name?.isNotEmpty != true) {
      throw Exception('ModuleRouter: Provide a path');
    }

    return _router(routeSettings);
  }

  Route _router(RouteSettings routeSettings) {
    try {
      final module = _module(routeSettings.name!, this.modules);
      final route = _route(routeSettings, module);

      if (this.enableAuthorize && !(this.authorized || module.allowAnonymous || route.allowAnonymous)) {
        throw UnauthorizedRouteException();
      }

      //listener(module);

      //final view = route.builder(routeSettings.arguments);

      final pageRoute = _pageRouter(route, routeSettings);

      return pageRoute;
    } on UnknownRouteException catch (_) {
      return _unknownPageRoute(routeSettings);
    } on UnauthorizedRouteException catch (_) {
      if (this.unauthorizedRedirectRoute.isNotEmpty) {
        routeSettings = RouteSettings(
          name: this.unauthorizedRedirectRoute,
        );

        return _router(routeSettings);
      }

      return _unauthorizedPageRoute();
    }
  }

  RouterModule _module(String path, List<RouterModule> modules) {
    final splitedPath = path.split("/");
    splitedPath.removeWhere((value) => value == '');

    final module = modules.firstWhereOrNull(
      (module) => module.path == splitedPath.first,
    );

    if (module == null) {
      throw UnknownRouteException();
    }

    if (module.modules.isEmpty == true) {
      return module;
    }

    splitedPath.removeAt(0);

    if (module.routes.any((route) => route.path == splitedPath.first)) {
      return module;
    }

    final nextPath = splitedPath.join('/');
    return _module(nextPath, module.modules);
  }

  ModuleRoute _route(RouteSettings routeSettings, RouterModule module) {
    String path = routeSettings.name!;
    final splitedPath = path.split("/");
    splitedPath.removeWhere((value) => value == '');

    if (path.characters.last == '/') {
      splitedPath.add('/');
    }

    final route = module.routes.firstWhereOrNull(
      (route) => route.path == splitedPath.last,
    );

    if (route == null) {
      throw UnknownRouteException();
    }

    return route;
  }

  PageRoute _pageRouter(ModuleRoute route, RouteSettings? routeSettings) {
    final view = route.builder(routeSettings?.arguments);

    if (Platform.isAndroid) {
      return CustomMaterialRoute(
        fullscreenDialog: route.isFullscreenDialog,
        settings: routeSettings,
        builder: (BuildContext context) => view,
      );
    }

    if (Platform.isIOS) {
      return CustomCupertinoRoute(
        fullscreenDialog: route.isFullscreenDialog,
        settings: routeSettings,
        builder: (BuildContext context) => view,
      );
    }

    return CustomPageRoute(
      settings: routeSettings,
      fullscreenDialog: route.isFullscreenDialog,
      pageBuilder: (BuildContext context, a1, a2) => view,
    );
  }

  PageRoute _unauthorizedPageRoute() {
    const view = UnauthorizedRoute();
    final unauthorizedRouteSettings = RouteSettings(name: this.unauthorizedRedirectRoute);
    final route = ModuleRoute(builder: (args) => view, path: '');

    return _pageRouter(route, unauthorizedRouteSettings);
  }

  PageRoute _unknownPageRoute(RouteSettings routeSettings) {
    final view = UnknownRoute(routeName: routeSettings.name);
    final route = ModuleRoute(builder: (args) => view, path: '');

    return _pageRouter(route, null);
  }
}

abstract class ModuleRouter with ModuleRouterMixin {}
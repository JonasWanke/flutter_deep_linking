import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

import 'route_selectors.dart';

typedef RouteBuilder = Widget Function(BuildContext context, Params params);

class Params {
  // TODO
}

@immutable
abstract class Route {
  const Route._(this.selector, this.builder, this.routes)
      : assert(selector != null),
        assert(routes != null);

  Route.scheme(
    String scheme, {
    RouteBuilder builder,
    List<Route> routes,
  }) : this._(SchemeRouteSelector(scheme), builder, routes);

  Route.path(
    String path, {
    RouteBuilder builder,
    List<Route> routes,
  }) : this._(PathRouteSelector(path), builder, routes);

  final RouteSelector selector;
  final RouteBuilder builder;
  final List<Route> routes;
}

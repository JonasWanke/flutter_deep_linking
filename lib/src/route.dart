import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_deep_linking/flutter_deep_linking.dart';
import 'package:meta/meta.dart';

import 'partial_uri.dart';
import 'route_result.dart';
import 'route_selectors.dart';

typedef RouteBuilder = Widget Function(
    BuildContext context, RouteResult result);

@immutable
class Route {
  const Route._(this.selector, this.builder, this.routes)
      : assert(selector != null),
        assert(routes != null);

  Route.scheme(
    String scheme, {
    RouteBuilder builder,
    List<Route> routes = const [],
  }) : this._(SchemeRouteSelector([scheme]), builder, routes);
  Route.schemes(
    List<String> schemes, {
    RouteBuilder builder,
    List<Route> routes = const [],
  }) : this._(SchemeRouteSelector(schemes), builder, routes);
  Route.host(
    String host, {
    RouteBuilder builder,
    List<Route> routes = const [],
  }) : this._(HostRouteSelector(host), builder, routes);

  Route.path(
    String path, {
    RouteBuilder builder,
    List<Route> routes = const [],
  }) : this._(PathRouteSelector(path), builder, routes);

  Route.any({
    RouteBuilder builder,
    List<Route> routes = const [],
  }) : this._(AnyRouteSelector(), builder, routes);

  final RouteSelector selector;
  final RouteBuilder builder;
  final List<Route> routes;

  RouteResult evaluate(RouteResult parentResult) {
    final evaluation = selector.evaluate(parentResult.remainingUri);
    if (!evaluation.isMatch) {
      return parentResult.withNoNestedMatch();
    }

    final result = parentResult.withNestedMatch(
      evaluation,
      (_, __) {
        assert(false, 'This result is temporary and should not be returned');
        return null;
      },
    );

    for (final route in routes) {
      final childResult = route.evaluate(result);
      if (childResult.isMatch) {
        return childResult;
      }
    }

    if (builder == null) {
      return parentResult.withNoNestedMatch();
    }
    return parentResult.withNestedMatch(evaluation, builder);
  }
}

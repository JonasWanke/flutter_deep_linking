import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart' as flutter show Route;
import 'package:meta/meta.dart';

import 'matchers.dart';
import 'route_result.dart';

typedef RouteBuilder = flutter.Route<dynamic> Function(RouteResult result);
typedef MaterialPageRouteBuilder = Widget Function(
    RouteResult result, BuildContext context);

@immutable
class Route {
  Route({
    Matcher matcher,
    RouteBuilder builder,
    MaterialPageRouteBuilder materialPageRouteBuilder,
    List<Route> routes = const [],
  }) : this._(matcher, builder, materialPageRouteBuilder, routes);

  Route._(
    this.matcher,
    RouteBuilder builder,
    MaterialPageRouteBuilder materialPageRouteBuilder,
    this.routes,
  )   : assert(matcher != null),
        assert(
            [builder, materialPageRouteBuilder]
                    .where((b) => b != null)
                    .length <=
                1,
            'At most one builder may be provided'),
        builder = builder ??
            ((result) => MaterialPageRoute(
                builder: (context) => materialPageRouteBuilder(result, context),
                settings: result.settings)),
        assert(routes != null);

  final Matcher matcher;
  final RouteBuilder builder;
  final List<Route> routes;

  RouteResult evaluate(RouteResult parentResult) {
    final evaluation = matcher.evaluate(parentResult.remainingUri);
    if (!evaluation.isMatch) {
      return parentResult.withNoNestedMatch();
    }

    final result = parentResult.withNestedMatch(
      evaluation,
      (_) {
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

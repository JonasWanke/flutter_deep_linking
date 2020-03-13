import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart' as flutter show Route;
import 'package:meta/meta.dart';

import 'matchers.dart';
import 'route_result.dart';

typedef RouteBuilder = flutter.Route<dynamic> Function(RouteResult result);
typedef materialBuilder = Widget Function(
    BuildContext context, RouteResult result);

@immutable
class Route {
  Route({
    this.matcher = const Matcher.any(),
    RouteBuilder builder,
    materialBuilder materialBuilder,
    this.routes = const [],
  })  : assert(matcher != null),
        assert([builder, materialBuilder].where((b) => b != null).length <= 1,
            'At most one builder may be provided'),
        builder = {
          builder: builder,
          materialBuilder: (result) => MaterialPageRoute(
              builder: (context) => materialBuilder(context, result),
              settings: result.settings),
        }
            .entries
            .firstWhere((e) => e.key != null,
                orElse: () => MapEntry(null, null))
            .value,
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

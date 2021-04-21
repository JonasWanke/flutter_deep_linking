import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart' as flutter show Route;

import 'matchers.dart';
import 'route_result.dart';

typedef RouteBuilder = flutter.Route<dynamic> Function(RouteResult result);
typedef MaterialBuilder = Widget Function(
  BuildContext context,
  RouteResult result,
);
typedef CupertinoBuilder = Widget Function(
  BuildContext context,
  RouteResult result,
);

@immutable
class Route {
  Route({
    this.matcher = const Matcher.any(),
    RouteBuilder? builder,
    MaterialBuilder? materialBuilder,
    CupertinoBuilder? cupertinoBuilder,
    this.routes = const [],
  })  : assert(
          [builder, materialBuilder, cupertinoBuilder].whereNotNull().length <=
              1,
          'At most one builder may be provided',
        ),
        builder = <RouteBuilder?>[
          builder,
          if (materialBuilder != null)
            (result) {
              return MaterialPageRoute<dynamic>(
                builder: (context) => materialBuilder(context, result),
                settings: result.settings,
              );
            },
          if (cupertinoBuilder != null)
            (result) {
              return CupertinoPageRoute<dynamic>(
                builder: (context) => cupertinoBuilder(context, result),
                settings: result.settings,
              );
            },
        ].whereNotNull().firstOrNull;

  final Matcher matcher;
  final RouteBuilder? builder;
  final List<Route> routes;

  RouteResult evaluate(RouteResult parentResult) {
    final evaluation = matcher.evaluate(parentResult.remainingUri!);
    if (!evaluation.isMatch) return parentResult.withNoNestedMatch();

    final result = parentResult.withNestedMatch(
      evaluation,
      (_) {
        throw StateError('This result is temporary and should not be returned');
      },
    );

    for (final route in routes) {
      final childResult = route.evaluate(result);
      if (childResult.isMatch) return childResult;
    }

    if (builder == null) return parentResult.withNoNestedMatch();
    return parentResult.withNestedMatch(evaluation, builder!);
  }
}

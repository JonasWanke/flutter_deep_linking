import 'package:flutter/widgets.dart' hide Route;
import 'package:flutter/widgets.dart' as flutter show Route;
import 'package:meta/meta.dart';

import 'route.dart';
import 'route_result.dart';

@immutable
class Router {
  const Router({@required this.routes}) : assert(routes != null);

  final List<Route> routes;

  flutter.Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final result = evaluate(settings);
    if (!result.isMatch) {
      return null;
    }

    return result.build();
  }

  RouteResult evaluate(RouteSettings settings) {
    assert(settings.name != null);
    final rootResult = RouteResult.root(settings);

    for (final route in routes) {
      final result = route.evaluate(rootResult);
      if (result.isMatch) {
        return result;
      }
    }
    return rootResult.withNoNestedMatch();
  }
}

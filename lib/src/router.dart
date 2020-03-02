import 'package:meta/meta.dart';

import 'route.dart';
import 'route_result.dart';

@immutable
class Router {
  const Router({@required this.routes}) : assert(routes != null);

  final List<Route> routes;

  RouteResult evaluate(Uri uri) {
    final rootResult = RouteResult.root(uri);
    for (final route in routes) {
      final result = route.evaluate(rootResult);
      if (result.isMatch) {
        return result;
      }
    }
    return rootResult.withNoNestedMatch();
  }
}

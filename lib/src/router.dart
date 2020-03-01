import 'package:meta/meta.dart';

import 'route.dart';

@immutable
class Router {
  const Router({@required this.routes}) : assert(routes != null);

  final List<Route> routes;
}

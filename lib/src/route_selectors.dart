import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

import 'partial_uri.dart';
import 'utils.dart';

@immutable
abstract class RouteSelector {
  const RouteSelector();

  RouteSelectorEvaluation evaluate(PartialUri uri);

  @override
  String toString();
}

@immutable
class RouteSelectorEvaluation {
  const RouteSelectorEvaluation.noMatch()
      : isMatch = false,
        remainingUri = null,
        parameters = const {};
  const RouteSelectorEvaluation.match({
    @required this.remainingUri,
    this.parameters = const {},
  })  : isMatch = true,
        assert(remainingUri != null),
        assert(parameters != null);

  final bool isMatch;
  final PartialUri remainingUri;
  final Map<String, String> parameters;

  @override
  String toString() {
    if (!isMatch) {
      return 'no match';
    }

    return 'match: $parameters, remaining: $remainingUri';
  }

  @override
  bool operator ==(Object other) =>
      other is RouteSelectorEvaluation &&
      isMatch == other.isMatch &&
      remainingUri == other.remainingUri &&
      mapEquals(parameters, other.parameters);
  @override
  int get hashCode => hashList([isMatch, remainingUri, parameters]);
}

class SchemeRouteSelector extends RouteSelector {
  SchemeRouteSelector(List<String> schemes)
      : assert(schemes != null),
        schemes = schemes.map((s) => s.toLowerCase()).toList();

  final List<String> schemes;

  @override
  RouteSelectorEvaluation evaluate(PartialUri uri) {
    if (!schemes.contains(uri.scheme)) {
      return RouteSelectorEvaluation.noMatch();
    }

    return RouteSelectorEvaluation.match(
      remainingUri: uri.copyWith(removeScheme: true),
    );
  }

  @override
  String toString() => 'Schemes: ${schemes.join(',')}';
}

class HostRouteSelector extends RouteSelector {
  HostRouteSelector(this.hosts)
      : assert(hosts != null),
        assert(hosts.every((h) => h != null));

  final List<String> hosts;

  @override
  RouteSelectorEvaluation evaluate(PartialUri uri) {
    if (!hosts.contains(uri.host)) {
      return RouteSelectorEvaluation.noMatch();
    }

    return RouteSelectorEvaluation.match(
      remainingUri: uri.copyWith(removeHost: true),
    );
  }

  @override
  String toString() => 'Host: ${hosts.join(',')}';
}

class PathRouteSelector extends RouteSelector {
  PathRouteSelector(String path)
      : assert(path != null),
        assert(path.isNotEmpty),
        pathSegments = path.split('/');

  final List<String> pathSegments;

  @override
  RouteSelectorEvaluation evaluate(PartialUri uri) {
    if (pathSegments.length > uri.pathSegments.length) {
      return RouteSelectorEvaluation.noMatch();
    }

    final params = <String, String>{};
    for (var i = 0; i < pathSegments.length; i++) {
      final segment = pathSegments[i];
      final toMatch = uri.pathSegments[i];

      if (segment.startsWith('{') && segment.endsWith('}')) {
        params[segment.substring(1, segment.length - 1)] = toMatch;
      } else if (segment == toMatch) {
        continue;
      } else {
        return RouteSelectorEvaluation.noMatch();
      }
    }

    return RouteSelectorEvaluation.match(
      remainingUri: uri.copyWith(removeFirstPathSegments: pathSegments.length),
      parameters: params,
    );
  }

  @override
  String toString() => 'Path: ${pathSegments.join('/')}';
}

class AnyRouteSelector extends RouteSelector {
  const AnyRouteSelector();

  @override
  RouteSelectorEvaluation evaluate(PartialUri uri) =>
      RouteSelectorEvaluation.match(remainingUri: uri);

  @override
  String toString() => 'Any';
}

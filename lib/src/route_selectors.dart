import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

import 'partial_uri.dart';
import 'utils.dart';

@immutable
abstract class RouteSelector {
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
  SchemeRouteSelector(String scheme)
      : assert(scheme != null),
        scheme = scheme.toLowerCase();

  final String scheme;

  @override
  RouteSelectorEvaluation evaluate(PartialUri uri) {
    if (uri.scheme != scheme) {
      return RouteSelectorEvaluation.noMatch();
    }

    return RouteSelectorEvaluation.match(
      remainingUri: uri.copyWith(removeScheme: true),
    );
  }

  @override
  String toString() => 'Scheme: $scheme';
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

    for (var i = 0; i < pathSegments.length; i++) {
      if (pathSegments[0] != uri.pathSegments[i]) {
        return RouteSelectorEvaluation.noMatch();
      }
    }

    return RouteSelectorEvaluation.match(
      remainingUri: uri.copyWith(removeFirstPathSegments: pathSegments.length),
    );
  }

  @override
  String toString() => 'Path: ${pathSegments.join('/')}';
}

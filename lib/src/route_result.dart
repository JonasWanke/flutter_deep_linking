import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import 'partial_uri.dart';
import 'route.dart';
import 'route_selectors.dart';
import 'utils.dart';

@immutable
class RouteResult {
  const RouteResult.noMatch(this.uri)
      : assert(uri != null),
        isMatch = false,
        remainingUri = null,
        parameters = const {},
        builder = null;

  const RouteResult.match(
    this.uri, {
    @required this.remainingUri,
    this.parameters = const {},
    @required this.builder,
  })  : assert(uri != null),
        isMatch = true,
        assert(remainingUri != null),
        assert(parameters != null),
        assert(builder != null);

  RouteResult.root(this.uri)
      : assert(uri != null),
        isMatch = true,
        remainingUri = PartialUri.fromUri(uri),
        parameters = {},
        builder = null;

  final Uri uri;
  final bool isMatch;
  final PartialUri remainingUri;
  final Map<String, String> parameters;
  final RouteBuilder builder;

  RouteResult withNestedMatch(
    RouteSelectorEvaluation evaluation,
    RouteBuilder builder,
  ) {
    assert(evaluation != null);
    assert(builder != null);

    return RouteResult.match(
      uri,
      builder: builder,
      remainingUri: evaluation.remainingUri,
      parameters: {...parameters, ...evaluation.parameters},
    );
  }

  RouteResult withNoNestedMatch() => RouteResult.noMatch(uri);

  String operator [](String key) => parameters[key];
  Widget build(BuildContext context) {
    assert(isMatch);
    assert(context != null);

    return builder(context, this);
  }

  @override
  String toString() {
    if (!isMatch) {
      return 'no match';
    }

    return 'match: $parameters, remaining: $remainingUri';
  }

  @override
  bool operator ==(Object other) {
    return other is RouteResult &&
        uri == other.uri &&
        isMatch == other.isMatch &&
        remainingUri == other.remainingUri &&
        mapEquals(parameters, other.parameters);
  }

  @override
  int get hashCode => hashList([isMatch, remainingUri, parameters]);
}

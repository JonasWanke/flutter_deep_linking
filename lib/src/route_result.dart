import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' hide Route;
import 'package:flutter/widgets.dart' as flutter show Route;

import 'matchers.dart';
import 'partial_uri.dart';
import 'route.dart';
import 'utils.dart';

@immutable
class RouteResult {
  const RouteResult.noMatch(this.settings)
      : assert(settings != null),
        isMatch = false,
        remainingUri = null,
        parameters = const {},
        builder = null;

  const RouteResult.match(
    this.settings, {
    @required this.remainingUri,
    this.parameters = const {},
    @required this.builder,
  })  : assert(settings != null),
        isMatch = true,
        assert(remainingUri != null),
        assert(parameters != null),
        assert(builder != null);

  RouteResult.root(this.settings)
      : assert(settings != null),
        assert(uri != null),
        isMatch = true,
        remainingUri = PartialUri.parse(settings.name),
        parameters = {},
        builder = null;

  final RouteSettings settings;
  Uri get uri => Uri.parse(settings.name);
  final bool isMatch;
  final PartialUri remainingUri;
  final Map<String, String> parameters;
  final RouteBuilder builder;

  RouteResult withNestedMatch(
    MatcherEvaluation evaluation,
    RouteBuilder builder,
  ) {
    assert(evaluation != null);
    assert(builder != null);

    return RouteResult.match(
      settings,
      builder: builder,
      remainingUri: evaluation.remainingUri,
      parameters: {...parameters, ...evaluation.parameters},
    );
  }

  RouteResult withNoNestedMatch() => RouteResult.noMatch(settings);

  String operator [](String key) => parameters[key];
  flutter.Route<dynamic> build() {
    assert(isMatch);

    return builder(this);
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

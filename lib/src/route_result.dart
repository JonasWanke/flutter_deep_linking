import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' hide Route, RouteBuilder;
import 'package:flutter/widgets.dart' as flutter show Route;

import 'matchers.dart';
import 'partial_uri.dart';
import 'route.dart';
import 'utils.dart';

@immutable
class RouteResult {
  const RouteResult.noMatch(this.settings)
      : isMatch = false,
        remainingUri = null,
        parameters = const {},
        builder = null;

  const RouteResult.match(
    this.settings, {
    required PartialUri this.remainingUri,
    this.parameters = const {},
    required RouteBuilder builder,
  })   : isMatch = true,
        // ignore: prefer_initializing_formals
        builder = builder;

  RouteResult.root(this.settings)
      : isMatch = true,
        remainingUri = PartialUri.parse(settings.name!),
        parameters = {},
        builder = null;

  /// The [RouteSettings] given by a [Navigator] for use in the [flutter.Route]
  /// generated by [builder].
  final RouteSettings settings;

  /// The original [Uri] that was requested.
  Uri get uri => Uri.parse(settings.name!);

  /// `true` if the [uri] was matched, `false` otherwise.
  final bool isMatch;

  /// Parts of the original [uri] that are left after matching.
  final PartialUri? remainingUri;

  /// Parameters, e.g. from path segments.
  final Map<String, String> parameters;

  /// The [RouteBuilder] to construct a [flutter.Route] for this match.
  final RouteBuilder? builder;

  RouteResult withNestedMatch(
    MatcherEvaluation evaluation,
    RouteBuilder builder,
  ) {
    return RouteResult.match(
      settings,
      builder: builder,
      remainingUri: evaluation.remainingUri!,
      parameters: {...parameters, ...evaluation.parameters},
    );
  }

  RouteResult withNoNestedMatch() => RouteResult.noMatch(settings);

  String? operator [](String key) => parameters[key];
  flutter.Route<dynamic> build() {
    assert(isMatch);

    return builder!(this);
  }

  @override
  String toString() {
    if (!isMatch) return 'no match';
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

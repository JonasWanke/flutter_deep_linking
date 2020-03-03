import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

import 'partial_uri.dart';
import 'utils.dart';

@immutable
abstract class Matcher {
  const Matcher();

  factory Matcher.scheme(Pattern scheme, {bool isOptional = false}) =>
      SchemeMatcher(scheme, isOptional: isOptional);
  factory Matcher.webScheme({bool isOptional = false}) =>
      Matcher.scheme('http', isOptional: isOptional) |
      Matcher.scheme('https', isOptional: isOptional);

  factory Matcher.host(Pattern host, {bool isOptional = false}) =>
      HostMatcher(host, isOptional: isOptional);
  factory Matcher.webHost(Pattern host, {bool isOptional = false}) =>
      Matcher.webScheme(isOptional: isOptional) &
      HostMatcher(host, isOptional: isOptional);

  factory Matcher.path(String path) = PathMatcher;

  const factory Matcher.any() = AnyMatcher;

  MatcherEvaluation evaluate(PartialUri uri);

  @override
  String toString();

  SequenceMatcher operator &(Matcher second) => SequenceMatcher([this, second]);
  ChoiceMatcher operator |(Matcher second) => ChoiceMatcher([this, second]);
}

class SequenceMatcher extends Matcher {
  SequenceMatcher(this.selectors)
      : assert(selectors != null),
        assert(selectors.every((s) => s != null));

  final List<Matcher> selectors;

  @override
  MatcherEvaluation evaluate(PartialUri uri) {
    var evaluation = MatcherEvaluation.match(remainingUri: uri);
    for (final selector in selectors) {
      final newEvaluation = selector.evaluate(uri);
      if (!newEvaluation.isMatch) {
        return MatcherEvaluation.noMatcher();
      }

      evaluation = MatcherEvaluation.match(
        remainingUri: evaluation.remainingUri,
        parameters: {...evaluation.parameters, ...newEvaluation.parameters},
      );
    }

    return evaluation;
  }

  @override
  String toString() => selectors.join(' & ');
}

class ChoiceMatcher extends Matcher {
  ChoiceMatcher(this.selectors)
      : assert(selectors != null),
        assert(selectors.every((s) => s != null));

  final List<Matcher> selectors;

  @override
  MatcherEvaluation evaluate(PartialUri uri) {
    return selectors.map((s) => s.evaluate(uri)).firstWhere(
          (e) => e.isMatch,
          orElse: () => MatcherEvaluation.noMatcher(),
        );
  }

  @override
  String toString() => selectors.join(' | ');
}

@immutable
class MatcherEvaluation {
  const MatcherEvaluation.noMatcher()
      : isMatch = false,
        remainingUri = null,
        parameters = const {};
  const MatcherEvaluation.match({
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
      other is MatcherEvaluation &&
      isMatch == other.isMatch &&
      remainingUri == other.remainingUri &&
      mapEquals(parameters, other.parameters);
  @override
  int get hashCode => hashList([isMatch, remainingUri, parameters]);
}

// TODO(JonasWanke): optional selectors
// TODO(JonasWanke): optional path
class SchemeMatcher extends Matcher {
  const SchemeMatcher(
    this.scheme, {
    this.isOptional = false,
  })  : assert(scheme != null),
        assert(isOptional != null);

  final bool isOptional;
  final Pattern scheme;

  @override
  MatcherEvaluation evaluate(PartialUri uri) {
    if (isOptional && uri.scheme.isEmpty) {
      return MatcherEvaluation.match(remainingUri: uri);
    }

    final match = scheme.matchAsPrefix(uri.scheme);
    if (match == null || match.end != uri.scheme.length) {
      return MatcherEvaluation.noMatcher();
    }

    return MatcherEvaluation.match(
      remainingUri: uri.copyWith(removeScheme: true),
    );
  }

  @override
  String toString() => 'scheme($scheme)';
}

class HostMatcher extends Matcher {
  const HostMatcher(
    this.host, {
    this.isOptional = false,
  })  : assert(host != null),
        assert(isOptional != null);

  final bool isOptional;
  final Pattern host;

  @override
  MatcherEvaluation evaluate(PartialUri uri) {
    if (isOptional && uri.host.isEmpty) {
      return MatcherEvaluation.match(remainingUri: uri);
    }

    final match = host.matchAsPrefix(uri.host);
    if (match == null || match.end != uri.host.length) {
      return MatcherEvaluation.noMatcher();
    }

    return MatcherEvaluation.match(
      remainingUri: uri.copyWith(removeHost: true),
    );
  }

  @override
  String toString() => 'host($host)';
}

class PathMatcher extends Matcher {
  PathMatcher(String path)
      : assert(path != null),
        assert(path.isNotEmpty),
        pathSegments = path.split('/');

  final List<String> pathSegments;

  @override
  MatcherEvaluation evaluate(PartialUri uri) {
    var uriSegments = uri.pathSegments;
    // filter out a trailing '/'
    if (uriSegments.isNotEmpty && uriSegments.last.isEmpty) {
      uriSegments = uriSegments.sublist(0, uriSegments.length - 1).toList();
    }

    if (pathSegments.length > uriSegments.length) {
      return MatcherEvaluation.noMatcher();
    }

    final params = <String, String>{};
    for (var i = 0; i < pathSegments.length; i++) {
      final segment = pathSegments[i];
      final toMatcher = uriSegments[i];

      if (segment.startsWith('{') && segment.endsWith('}')) {
        params[segment.substring(1, segment.length - 1)] = toMatcher;
      } else if (segment == toMatcher) {
        continue;
      } else {
        return MatcherEvaluation.noMatcher();
      }
    }

    return MatcherEvaluation.match(
      remainingUri: uri.copyWith(removeFirstPathSegments: pathSegments.length),
      parameters: params,
    );
  }

  @override
  String toString() => 'Path: ${pathSegments.join('/')}';
}

class AnyMatcher extends Matcher {
  const AnyMatcher();

  @override
  MatcherEvaluation evaluate(PartialUri uri) =>
      MatcherEvaluation.match(remainingUri: uri);

  @override
  String toString() => 'any';
}

import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

import 'utils.dart';

@immutable
class PartialUri {
  const PartialUri({
    this.scheme = '',
    this.host = '',
    this.pathSegments = const [],
    this.queryParameters = const {},
    this.fragment = '',
  })  : assert(scheme != null),
        assert(host != null),
        assert(pathSegments != null),
        assert(queryParameters != null),
        assert(fragment != null);

  PartialUri.fromUri(Uri uri)
      : this(
          scheme: uri.scheme,
          host: uri.host,
          pathSegments: uri.pathSegments,
          queryParameters: uri.queryParameters,
          fragment: uri.fragment,
        );
  PartialUri.parse(String uri) : this.fromUri(Uri.parse(uri));

  final String scheme;
  final String host;
  final List<String> pathSegments;
  final Map<String, String> queryParameters;
  final String fragment;

  PartialUri copyWith({
    bool removeScheme = false,
    int removeFirstPathSegments = 0,
  }) {
    return PartialUri(
      scheme: removeScheme ? '' : scheme,
      host: host,
      pathSegments: pathSegments.skip(removeFirstPathSegments).toList(),
      queryParameters: queryParameters,
      fragment: fragment,
    );
  }

  @override
  String toString() {
    return [
      if (scheme.isNotEmpty) '$scheme://',
      if (host.isNotEmpty) host,
      if (pathSegments.isNotEmpty) '/${pathSegments.join('/')}',
      if (queryParameters.isNotEmpty)
        '?${queryParameters.entries.map((e) => '${e.key}=${e.value}').join('&')}',
      if (fragment.isNotEmpty) '#$fragment',
    ].join();
  }

  @override
  bool operator ==(Object other) {
    return other is PartialUri &&
        scheme == other.scheme &&
        host == other.host &&
        listEquals(pathSegments, other.pathSegments) &&
        mapEquals(queryParameters, other.queryParameters) &&
        fragment == other.fragment;
  }

  @override
  int get hashCode =>
      hashList([scheme, host, pathSegments, queryParameters, fragment]);
}

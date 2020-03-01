import 'package:flutter_deep_linking/flutter_deep_linking.dart';
import 'package:flutter_deep_linking/src/route_selectors.dart';
import 'package:test/test.dart';

void main() {
  group('Match', () {
    group('scheme', () {
      final urisWithoutScheme = [
        Uri.parse('github.com'),
        Uri.parse('github.com/JonasWanke'),
        Uri.parse('github.com/JonasWanke/flutter_deep_linking/'),
      ];
      final httpUris = [
        Uri.parse('http://github.com'),
        Uri.parse('http://github.com/JonasWanke'),
        Uri.parse('http://github.com/JonasWanke/flutter_deep_linking/'),
      ];
      final httpsUris = [
        Uri.parse('https://github.com'),
        Uri.parse('https://github.com/JonasWanke'),
        Uri.parse('https://github.com/JonasWanke/flutter_deep_linking/'),
      ];

      group('empty', () {
        for (final uri in urisWithoutScheme) {
          test(
            uri.toString(),
            () => expect(
              SchemeRouteSelector('').evaluate(uri),
              equals(RouteSelectorEvaluation.match(remainingUri: uri)),
            ),
          );
        }
        for (final uri in httpUris + httpsUris) {
          test(
            uri.toString(),
            () => expect(
              SchemeRouteSelector('').evaluate(uri),
              equals(RouteSelectorEvaluation.noMatch()),
            ),
          );
        }
      });
      group('https', () {
        for (final uri in httpsUris) {
          test(
            uri.toString(),
            () => expect(
              SchemeRouteSelector('https').evaluate(uri),
              equals(RouteSelectorEvaluation.match(
                remainingUri: urisWithoutScheme[httpsUris.indexOf(uri)],
              )),
            ),
          );
        }
        for (final uri in urisWithoutScheme + httpUris) {
          test(
            uri.toString(),
            () => expect(
              SchemeRouteSelector('https').evaluate(uri),
              equals(RouteSelectorEvaluation.noMatch()),
            ),
          );
        }
      });
    });
  });
}

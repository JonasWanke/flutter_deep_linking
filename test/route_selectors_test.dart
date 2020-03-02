import 'package:flutter_deep_linking/src/partial_uri.dart';
import 'package:flutter_deep_linking/src/route_selectors.dart';
import 'package:test/test.dart';

void main() {
  group('Match', () {
    group('scheme', () {
      final urisWithoutScheme = [
        PartialUri.parse('//github.com'),
        PartialUri.parse('//github.com/JonasWanke'),
        PartialUri.parse('//github.com/JonasWanke/flutter_deep_linking/'),
      ];
      final httpUris = [
        PartialUri.parse('http://github.com'),
        PartialUri.parse('http://github.com/JonasWanke'),
        PartialUri.parse('http://github.com/JonasWanke/flutter_deep_linking/'),
      ];
      final httpsUris = [
        PartialUri.parse('https://github.com'),
        PartialUri.parse('https://github.com/JonasWanke'),
        PartialUri.parse('https://github.com/JonasWanke/flutter_deep_linking/'),
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

    group('path', () {
      group('single segment', () {
        group('plain', () {
          final singleSegment = PartialUri.parse('//github.com/JonasWanke');
          test(singleSegment.toString(), () {
            expect(
              PathRouteSelector('JonasWanke').evaluate(singleSegment),
              equals(RouteSelectorEvaluation.match(
                  remainingUri: PartialUri.parse('//github.com'))),
            );
          });

          final emptyPath = PartialUri.parse('//github.com/');
          test(emptyPath.toString(), () {
            expect(
              PathRouteSelector('JonasWanke').evaluate(emptyPath),
              equals(RouteSelectorEvaluation.noMatch()),
            );
          });

          final wrongPath = PartialUri.parse('//github.com/actions');
          test(wrongPath.toString(), () {
            expect(
              PathRouteSelector('JonasWanke').evaluate(wrongPath),
              equals(RouteSelectorEvaluation.noMatch()),
            );
          });

          final longerPath =
              PartialUri.parse('//github.com/JonasWanke/flutter_deep_linking/');
          test(longerPath.toString(), () {
            expect(
              PathRouteSelector('JonasWanke').evaluate(longerPath),
              equals(RouteSelectorEvaluation.match(
                remainingUri:
                    PartialUri.parse('//github.com/flutter_deep_linking/'),
              )),
            );
          });
        });
      });
    });
  });
}

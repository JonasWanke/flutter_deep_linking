import 'package:flutter_deep_linking/src/partial_uri.dart';
import 'package:flutter_deep_linking/src/route_selectors.dart';
import 'package:test/test.dart';

void main() {
  group('Match', () {
    RouteSelector selector;

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
        setUp(() => selector = SchemeRouteSelector(''));

        for (final uri in urisWithoutScheme) {
          test(
            uri.toString(),
            () => expect(
              selector.evaluate(uri),
              equals(RouteSelectorEvaluation.match(remainingUri: uri)),
            ),
          );
        }
        for (final uri in httpUris + httpsUris) {
          test(
            uri.toString(),
            () => expect(
              selector.evaluate(uri),
              equals(RouteSelectorEvaluation.noMatch()),
            ),
          );
        }
      });
      group('https', () {
        setUp(() => selector = SchemeRouteSelector('https'));

        for (final uri in httpsUris) {
          test(
            uri.toString(),
            () => expect(
              selector.evaluate(uri),
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
              selector.evaluate(uri),
              equals(RouteSelectorEvaluation.noMatch()),
            ),
          );
        }
      });
    });

    group('path', () {
      group('single segment', () {
        group('plain', () {
          setUp(() => selector = PathRouteSelector('JonasWanke'));

          final singleSegment = PartialUri.parse('//github.com/JonasWanke');
          test(singleSegment.toString(), () {
            expect(
              selector.evaluate(singleSegment),
              equals(RouteSelectorEvaluation.match(
                  remainingUri: PartialUri.parse('//github.com'))),
            );
          });

          final emptyPath = PartialUri.parse('//github.com/');
          test(emptyPath.toString(), () {
            expect(
              selector.evaluate(emptyPath),
              equals(RouteSelectorEvaluation.noMatch()),
            );
          });

          final wrongPath = PartialUri.parse('//github.com/actions');
          test(wrongPath.toString(), () {
            expect(
              selector.evaluate(wrongPath),
              equals(RouteSelectorEvaluation.noMatch()),
            );
          });

          final longerPath =
              PartialUri.parse('//github.com/JonasWanke/flutter_deep_linking/');
          test(longerPath.toString(), () {
            expect(
              selector.evaluate(longerPath),
              equals(RouteSelectorEvaluation.match(
                remainingUri:
                    PartialUri.parse('//github.com/flutter_deep_linking/'),
              )),
            );
          });
        });

        group('parameter', () {
          final singleSegment1 = PartialUri.parse('//github.com/JonasWanke');
          test(singleSegment1.toString(), () {
            expect(
              PathRouteSelector('{userName}').evaluate(singleSegment1),
              equals(RouteSelectorEvaluation.match(
                remainingUri: PartialUri.parse('//github.com'),
                parameters: {'userName': 'JonasWanke'},
              )),
            );
          });

          final singleSegment2 = PartialUri.parse('//github.com/actions');
          test(singleSegment2.toString(), () {
            expect(
              PathRouteSelector('{userName}').evaluate(singleSegment2),
              equals(RouteSelectorEvaluation.match(
                remainingUri: PartialUri.parse('//github.com'),
                parameters: {'userName': 'actions'},
              )),
            );
          });

          final emptyPath = PartialUri.parse('//github.com');
          test(emptyPath.toString(), () {
            expect(
              PathRouteSelector('{userName}').evaluate(emptyPath),
              equals(RouteSelectorEvaluation.noMatch()),
            );
          });

          final longerPath =
              PartialUri.parse('//github.com/JonasWanke/flutter_deep_linking/');
          test(longerPath.toString(), () {
            expect(
              PathRouteSelector('{userName}').evaluate(longerPath),
              equals(RouteSelectorEvaluation.match(
                remainingUri:
                    PartialUri.parse('//github.com/flutter_deep_linking/'),
                parameters: {'userName': 'JonasWanke'},
              )),
            );
          });
        });
      });
      group('multiple segments', () {
        setUp(() =>
            selector = PathRouteSelector('JonasWanke/flutter_deep_linking'));

        final exactMatch =
            PartialUri.parse('//github.com/JonasWanke/flutter_deep_linking');
        test(exactMatch.toString(), () {
          expect(
            selector.evaluate(exactMatch),
            equals(RouteSelectorEvaluation.match(
              remainingUri: PartialUri.parse('//github.com'),
            )),
          );
        });

        final wrongPath = PartialUri.parse('//github.com/JonasWanke/Unicorn');
        test(wrongPath.toString(), () {
          expect(
            selector.evaluate(wrongPath),
            equals(RouteSelectorEvaluation.noMatch()),
          );
        });

        final shorterPath = PartialUri.parse('//github.com/JonasWanke');
        test(shorterPath.toString(), () {
          expect(
            selector.evaluate(shorterPath),
            equals(RouteSelectorEvaluation.noMatch()),
          );
        });
      });
    });
  });
}

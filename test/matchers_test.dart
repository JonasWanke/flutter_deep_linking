import 'package:flutter_deep_linking/flutter_deep_linking.dart';
import 'package:test/test.dart' hide Matcher;

void main() {
  late Matcher matcher;

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
      setUp(() => matcher = SchemeMatcher(''));

      for (final uri in urisWithoutScheme) {
        test(
          uri.toString(),
          () => expect(
            matcher.evaluate(uri),
            equals(MatcherEvaluation.match(remainingUri: uri)),
          ),
        );
      }
      for (final uri in httpUris + httpsUris) {
        test(
          uri.toString(),
          () => expect(
            matcher.evaluate(uri),
            equals(MatcherEvaluation.noMatcher()),
          ),
        );
      }
    });
    group('https', () {
      setUp(() => matcher = SchemeMatcher('https'));

      for (final uri in httpsUris) {
        test(
          uri.toString(),
          () => expect(
            matcher.evaluate(uri),
            equals(MatcherEvaluation.match(
              remainingUri: urisWithoutScheme[httpsUris.indexOf(uri)],
            )),
          ),
        );
      }
      for (final uri in urisWithoutScheme + httpUris) {
        test(
          uri.toString(),
          () => expect(
            matcher.evaluate(uri),
            equals(MatcherEvaluation.noMatcher()),
          ),
        );
      }
    });
  });

  group('path', () {
    group('single segment', () {
      group('plain', () {
        setUp(() => matcher = Matcher.path('JonasWanke'));

        final singleSegment = PartialUri.parse('//github.com/JonasWanke');
        test(singleSegment.toString(), () {
          expect(
            matcher.evaluate(singleSegment),
            equals(MatcherEvaluation.match(
                remainingUri: PartialUri.parse('//github.com'))),
          );
        });

        final emptyPath = PartialUri.parse('//github.com/');
        test(emptyPath.toString(), () {
          expect(
            matcher.evaluate(emptyPath),
            equals(MatcherEvaluation.noMatcher()),
          );
        });

        final wrongPath = PartialUri.parse('//github.com/actions');
        test(wrongPath.toString(), () {
          expect(
            matcher.evaluate(wrongPath),
            equals(MatcherEvaluation.noMatcher()),
          );
        });

        final longerPath =
            PartialUri.parse('//github.com/JonasWanke/flutter_deep_linking/');
        test(longerPath.toString(), () {
          expect(
            matcher.evaluate(longerPath),
            equals(MatcherEvaluation.match(
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
            PathMatcher('{userName}').evaluate(singleSegment1),
            equals(MatcherEvaluation.match(
              remainingUri: PartialUri.parse('//github.com'),
              parameters: {'userName': 'JonasWanke'},
            )),
          );
        });

        final singleSegment2 = PartialUri.parse('//github.com/actions');
        test(singleSegment2.toString(), () {
          expect(
            PathMatcher('{userName}').evaluate(singleSegment2),
            equals(MatcherEvaluation.match(
              remainingUri: PartialUri.parse('//github.com'),
              parameters: {'userName': 'actions'},
            )),
          );
        });

        final emptyPath = PartialUri.parse('//github.com');
        test(emptyPath.toString(), () {
          expect(
            PathMatcher('{userName}').evaluate(emptyPath),
            equals(MatcherEvaluation.noMatcher()),
          );
        });

        final longerPath =
            PartialUri.parse('//github.com/JonasWanke/flutter_deep_linking/');
        test(longerPath.toString(), () {
          expect(
            PathMatcher('{userName}').evaluate(longerPath),
            equals(MatcherEvaluation.match(
              remainingUri:
                  PartialUri.parse('//github.com/flutter_deep_linking/'),
              parameters: {'userName': 'JonasWanke'},
            )),
          );
        });
      });
    });
    group('multiple segments', () {
      setUp(() => matcher = PathMatcher('JonasWanke/flutter_deep_linking'));

      final exactMatcher =
          PartialUri.parse('//github.com/JonasWanke/flutter_deep_linking');
      test(exactMatcher.toString(), () {
        expect(
          matcher.evaluate(exactMatcher),
          equals(MatcherEvaluation.match(
            remainingUri: PartialUri.parse('//github.com'),
          )),
        );
      });

      final wrongPath = PartialUri.parse('//github.com/JonasWanke/Unicorn');
      test(wrongPath.toString(), () {
        expect(
          matcher.evaluate(wrongPath),
          equals(MatcherEvaluation.noMatcher()),
        );
      });

      final shorterPath = PartialUri.parse('//github.com/JonasWanke');
      test(shorterPath.toString(), () {
        expect(
          matcher.evaluate(shorterPath),
          equals(MatcherEvaluation.noMatcher()),
        );
      });
    });
  });
}

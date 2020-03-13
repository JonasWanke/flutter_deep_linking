import 'package:flutter/material.dart' hide Route;
import 'package:flutter/material.dart' as flutter show Route;
import 'package:flutter_deep_linking/flutter_deep_linking.dart';
import 'package:test/test.dart' hide Matcher;

void main() {
  group('evaluate', () {
    final route = Route(
      matcher: Matcher.host('github.com'),
      routes: [
        Route(
          matcher: Matcher.path('JonasWanke'),
          materialBuilder: (_, __) => Text('User: JonasWanke'),
          routes: [
            Route(
              matcher: Matcher.path('{repoName}'),
              materialBuilder: (_, result) =>
                  Text('Repository: ${result['repoName']}'),
            ),
          ],
        ),
        Route(
          matcher: Matcher.any(),
          materialBuilder: (_, __) => Text('Not found'),
        )
      ],
    );

    RouteResult evaluate(Uri uri) {
      final settings = RouteSettings(name: uri.toString());
      return route.evaluate(RouteResult.root(settings));
    }

    final wrongDomain = Uri.parse('//dart.dev');
    test(wrongDomain, () {
      final result = evaluate(wrongDomain);
      expect(result.isMatch, isFalse);
    });

    final domain = Uri.parse('//github.com');
    test(domain, () {
      final result = evaluate(domain);
      expect(result.isMatch, isTrue);
      final text = _extractText(result.build());
      expect(text, equals('Not found'));
    });

    final wrongPath = Uri.parse('//github.com/actions');
    test(wrongPath, () {
      final result = evaluate(wrongPath);
      expect(result.isMatch, isTrue);
      final text = _extractText(result.build());
      expect(text, equals('Not found'));
    });

    final user = Uri.parse('//github.com/JonasWanke');
    test(user, () {
      final result = evaluate(user);
      expect(result.isMatch, isTrue);
      final text = _extractText(result.build());
      expect(text, equals('User: JonasWanke'));
    });

    final repo = Uri.parse('//github.com/JonasWanke/flutter_deep_linking');
    test(repo, () {
      final result = evaluate(repo);
      expect(result.isMatch, isTrue);
      expect(result.parameters, equals({'repoName': 'flutter_deep_linking'}));
      final text = _extractText(result.build());
      expect(text, equals('Repository: flutter_deep_linking'));
    });
  });
}

String _extractText(flutter.Route<dynamic> route) {
  final materialPageRoute = route as MaterialPageRoute;
  final semantics = materialPageRoute.buildPage(null, null, null) as Semantics;
  final text = semantics.child as Text;
  return text.data;
}

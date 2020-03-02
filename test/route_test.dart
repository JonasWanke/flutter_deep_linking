import 'package:flutter/widgets.dart' hide Route;
import 'package:flutter_deep_linking/flutter_deep_linking.dart';
import 'package:test/test.dart';

void main() {
  group('evaluate', () {
    final route = Route.host(
      'github.com',
      routes: [
        Route.path(
          'JonasWanke',
          builder: (_, params) => Text('User: JonasWanke'),
          routes: [
            Route.path(
              '{repoName}',
              builder: (_, result) => Text('Repository: ${result['repoName']}'),
            ),
          ],
        ),
        Route.any(
          builder: (_, __) => Text('Not found'),
        )
      ],
    );

    final wrongDomain = Uri.parse('//dart.dev');
    test(wrongDomain, () {
      final result = route.evaluate(RouteResult.root(wrongDomain));
      expect(result.isMatch, isFalse);
    });

    final domain = Uri.parse('//github.com');
    test(domain, () {
      final result = route.evaluate(RouteResult.root(domain));
      expect(result.isMatch, isTrue);
      final widget = result.builder(null, result) as Text;
      expect(widget.data, equals('Not found'));
    });

    final wrongPath = Uri.parse('//github.com/actions');
    test(wrongPath, () {
      final result = route.evaluate(RouteResult.root(wrongPath));
      expect(result.isMatch, isTrue);
      final widget = result.builder(null, result) as Text;
      expect(widget.data, equals('Not found'));
    });

    final user = Uri.parse('//github.com/JonasWanke');
    test(user, () {
      final result = route.evaluate(RouteResult.root(user));
      expect(result.isMatch, isTrue);
      final widget = result.builder(null, result) as Text;
      expect(widget.data, equals('User: JonasWanke'));
    });

    final repo = Uri.parse('//github.com/JonasWanke/flutter_deep_linking');
    test(repo, () {
      final result = route.evaluate(RouteResult.root(repo));
      expect(result.isMatch, isTrue);
      expect(result.parameters, equals({'repoName': 'flutter_deep_linking'}));
      final widget = result.builder(null, result) as Text;
      expect(widget.data, equals('Repository: flutter_deep_linking'));
    });
  });
}

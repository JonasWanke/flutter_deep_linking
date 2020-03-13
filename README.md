🧭 Handle all your routing with proper deep links and handle them declaratively!


## Getting started

### 1. 📦 Add this package to your dependencies:

```yaml
dependencies:
  flutter_deep_linking: ^0.1.0
```


### 2. 🧭 Create a [`Router`] containing all your routes:

```dart
final router = Router(
  routes: [
    Route(
      // This matches any HTTP or HTTPS URI pointing to schul-cloud.org.
      // Due to `isOptional`, this also matches URIs without a scheme or domain,
      // but not other domains.
      matcher: Matcher.webHost('schul-cloud.org', isOptional: true),
      // These nested routes are evaluated only if the above condition matches.
      routes: [
        Route(
          matcher: Matcher.path('courses'),
          materialBuilder: (_, __) => CoursesPage(),
          routes: [
            // If this route matches, it is used. Otherwise, we fall back to the
            // outer courses-route.
            Route(
              // {courseId} is a parameter matches a single path segment.
              matcher: Matcher.path('{courseId}'),
              materialBuilder: (_, RouteResult result) {
                // You can access the matched parameters using `result[<name>]`.
                return CourseDetailPage(result['courseId']);
              },
            ),
          ],
        ),
        Route(
          // Matcher.path can also match nested paths.
          matcher: Matcher.path('user/settings'),
          materialBuilder: (_, __) => SettingsPage(),
        ),
      ],
    ),
    // This route doesn't specify a matcher and hence matches any route.
    Route(
      materialBuilder: (_, RouteResult result) => NotFoundPage(result.uri),
    ),
  ],
);
```

> **Note:** Flutter also defines a class called `Route` which can lead to some confusion. If you import `package:flutter/widgets.dart` in the same file as `flutter_deep_linking`, you can ignore Flutter's `Route` with `import 'package:flutter/widgets.dart' hide Route;`.

[`Router`] accepts a list of [`Route`]s which are searched top to bottom, depth first. Using [`Matcher`]s you can match parts of the URI. Inner [`Matcher`]s can't access parts of the URI that have already been matched by an outer [`Matcher`].

To build the actual page, you can either specify either of:
- [`Route.builder`]: Takes a [`RouteResult`] and returns an instance of Flutter's [`Route`][widgets.Route].
- [`Route.materialBuilder`] (Convenience property): Takes a [`BuildContext`] and a [`RouteResult`] and returns a widget, which is then wrapped in [`MaterialPageRoute`].


### 3. Let your [`Router`] take care of resolving URIs in `MaterialApp` (or `CupertinoApp` or a custom `Navigator`):

```dart
MaterialApp(
  onGenerateRoute: router.onGenerateRoute,
  // ...
)
```


### 4. Use your new routes!

When navigating, use `navigator.pushNamed(uriString)` instead of calling `navigator.push(builder)` and benefit from loose coupling!

And if you build an app in addition to a website, you can use a package like [uni_links] to receive incoming links and directly forward them to `flutter_deep_linking`.


## More information

### [`Matcher`]s

Available [`Matcher`]s:
- `Matcher.scheme`: Matches a URI scheme like `https`.
- `Matcher.webScheme`: Conveniently matches `http` or `httos`.
- `Matcher.host`: Matches a URI host like `schul-cloud.org`.
- `Matcher.webHost`: Conveniently matches a `webScheme` (see above) and a URI host.
- `Matcher.path`: Matches a single or multiple URI path segments like `courses/{courseId}`, whereas `courseId` is a placeholder and will match exactly one segment.

You can also combine [`Matcher`]s within a single [`Route`]:
- `matcher1 & matcher2` matches both [`Matcher`]s in sequence.
- `matcher1 | matcher2` evaluates both [`Matcher`]s in sequence and returns the first match.


### [`RouteResult`]

[`RouteResult`] most importantly contains:
- `uri`: The initial URI (which can be used e.g. to access query parameters).
- `parameters`: A `Map<String, String>` of matched parameters, also accessible via `result[<name>]`.
- `settings`: The `RouteSettings` that should be forwarded to the generated (Flutter) `Route`.


[uni_links]: https://pub.dev/packages/uni_links
<!-- Flutter -->
[`MaterialPageRoute`]: https://api.flutter.dev/flutter/material/MaterialPageRoute-class.html
[widgets.Route]: https://api.flutter.dev/flutter/widgets/Route-class.html
<!-- flutter_deep_linking -->
[`Matcher`]: https://pub.dev/documentation/flutter_deep_linking/latest/flutter_deep_linking/Matcher-class.html
[`Route`]: https://pub.dev/documentation/flutter_deep_linking/latest/flutter_deep_linking/Route-class.html
[`Route.builder`]: https://pub.dev/documentation/flutter_deep_linking/latest/flutter_deep_linking/Route/builder.html
[`Route.materialBuilder`]: https://pub.dev/documentation/flutter_deep_linking/latest/flutter_deep_linking/Route/materialBuilder.html
[`RouteResult`]: https://pub.dev/documentation/flutter_deep_linking/latest/flutter_deep_linking/RouteResult-class.html
[`Router`]: https://pub.dev/documentation/flutter_deep_linking/latest/flutter_deep_linking/Router-class.html

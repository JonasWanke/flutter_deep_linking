🧭 Handle all your routing with proper deep links and handle them declaratively!

### What this package is about

This package takes declaratively defined [`Route`]s and receives a URI during navigation, evaluates those and then returns a [`PageRoute`] for the correct page. This means, you can now benefit from loose coupling and navigate using:

```dart
Navigator.of(context).pushNamed('/articles/$id')
```

instead of hardcoding the corresponding widget everytime:

```dart
Navigator.of(context)
  .push(MaterialPageRoute(builder: (_) => ArticlePage(id)));
```


### What this package is not about

This package doesn't catch incoming deep links from other apps. For this, I recommend [<kbd>uni_links</kbd>](https://pub.dev/packages/uni_links).

You can, however, combine both packages. Just forward any received deep links to your `Navigator` and `flutter_deep_linking` takes care of resolving them. This also works with the initial deep link:

```dart
String initialLink = await getInitialLink(); // from uni_links
return MaterialApp(
  initialRoute: initialLink,
  onGenerateRoute: router.onGenerateRoute,   // from flutter_deep_linking
  // ...
);
```


## Getting started

### 1. 🧭 Create a [`Router`] containing all your routes:

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

> **Note:** Flutter also defines classes called `Route` & `RouteBuilder` which can lead to some confusion. If you import `package:flutter/widgets.dart` in the same file as `flutter_deep_linking`, you can ignore Flutter's `Route` & `RouteBuilder` with `import 'package:flutter/widgets.dart' hide Route, RouteBuilder;`.

[`Router`] accepts a list of [`Route`]s which are searched top to bottom, depth first. Using [`Matcher`]s you can match parts of the URI. Inner [`Matcher`]s can't access parts of the URI that have already been matched by an outer [`Matcher`].

To build the actual page, you can specify either of:

- [`Route.builder`]: Takes a [`RouteResult`] and returns an instance of Flutter's [`Route`][widgets.Route].
- [`Route.materialBuilder`] (Convenience property): Takes a [`BuildContext`] and a [`RouteResult`] and returns a widget, which is then wrapped in [`MaterialPageRoute`].


### 2. 🎯 Let your [`Router`] take care of resolving URIs in `MaterialApp` (or `CupertinoApp` or a custom `Navigator`):

```dart
MaterialApp(
  onGenerateRoute: router.onGenerateRoute,
  // ...
)
```


### 3. 🚀 Use your new routes!

When navigating, use `navigator.pushNamed(uriString)` instead of calling `navigator.push(builder)` and benefit from loose coupling!

And if you build an app in addition to a website, you can use a package like [uni_links] to receive incoming links and directly forward them to `flutter_deep_linking`.


## More information

### [`Matcher`]s

Available [`Matcher`]s:

- `Matcher.scheme`: Matches a URI scheme like `https`.
- `Matcher.webScheme`: Conveniently matches `http` or `https`.
- `Matcher.host`: Matches a URI host like `schul-cloud.org`.
- `Matcher.webHost`: Conveniently matches a `webScheme` (see above) and a URI host.
- `Matcher.path`: Matches a single or multiple URI path segments like `courses/{courseId}`, whereas `courseId` is a placeholder and will match exactly one segment.

You can also combine [`Matcher`]s within a single [`Route`]:

- `matcher1 & matcher2` matches both [`Matcher`]s in sequence.
- `matcher1 | matcher2` evaluates both [`Matcher`]s in sequence and returns the first match.


### [`RouteResult`]

[`RouteResult`] most importantly contains:

- `uri`: The initial URI (which can be used, e.g., to access query parameters).
- `parameters`: A `Map<String, String>` of matched parameters, also accessible via `result[<name>]`.
- `settings`: The `RouteSettings` that should be forwarded to the generated (Flutter) `Route`.


[uni_links]: https://pub.dev/packages/uni_links
<!-- Flutter -->
[`MaterialPageRoute`]: https://api.flutter.dev/flutter/material/MaterialPageRoute-class.html
[`PageRoute`]: https://api.flutter.dev/flutter/widgets/PageRoute-class.html
[widgets.Route]: https://api.flutter.dev/flutter/widgets/Route-class.html
<!-- flutter_deep_linking -->
[`Matcher`]: https://pub.dev/documentation/flutter_deep_linking/latest/flutter_deep_linking/Matcher-class.html
[`Route`]: https://pub.dev/documentation/flutter_deep_linking/latest/flutter_deep_linking/Route-class.html
[`Route.builder`]: https://pub.dev/documentation/flutter_deep_linking/latest/flutter_deep_linking/Route/builder.html
[`Route.materialBuilder`]: https://pub.dev/documentation/flutter_deep_linking/latest/flutter_deep_linking/Route/materialBuilder.html
[`RouteResult`]: https://pub.dev/documentation/flutter_deep_linking/latest/flutter_deep_linking/RouteResult-class.html
[`Router`]: https://pub.dev/documentation/flutter_deep_linking/latest/flutter_deep_linking/Router-class.html

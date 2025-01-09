<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages).
-->

# flutter_service_provider

[![pub package](https://img.shields.io/pub/v/flutter_service_provider?logo=dart&logoColor=00b9fc)](https://pub.dev/packages/flutter_service_provider)
[![CI](https://img.shields.io/github/actions/workflow/status/codelovercc/flutter_service_provider/flutter.yml?branch=main&logo=github-actions&logoColor=white)](https://github.com/codelovercc/flutter_service_provider/actions)
[![Last Commits](https://img.shields.io/github/last-commit/codelovercc/flutter_service_provider?logo=git&logoColor=white)](https://github.com/codelovercc/flutter_service_provider/commits/main)
[![Pull Requests](https://img.shields.io/github/issues-pr/codelovercc/flutter_service_provider?logo=github&logoColor=white)](https://github.com/codelovercc/flutter_service_provider/pulls)
[![Code size](https://img.shields.io/github/languages/code-size/codelovercc/flutter_service_provider?logo=github&logoColor=white)](https://github.com/codelovercc/flutter_service_provider)
[![License](https://img.shields.io/github/license/codelovercc/flutter_service_provider?logo=open-source-initiative&logoColor=green)](https://github.com/codelovercc/flutter_service_provider/blob/main/LICENSE)

Useful widgets for [dart_service_provider](https://pub.dev/packages/dart_service_provider) package.

## Features

Widgets:

1. `Services<T>` build service provider.
2. `ScopedServices<T>` create a service scope.
3. `ServiceConsumer<T>` pass the service provider to your widget builder.
4. `ServiceInheritedWidget<T>` shares `IServiceProvider` instance to its child widgets.

Get the `IServiceProvider` instance:

1. `Services.of<T>(context)`  
   Get the `IServiceProvider` instance from the nearest `ServiceInheritedWidget<T>`, notes
   that `Services<T>` and `ScopedServices<T>` will create `ServiceInheritedWidget<T>`.
2. `ServiceConsumer<T>(builder: (context, provider){})`  
   The `IServiceProvider` instance from the nearest `ServiceInheritedWidget<T>` will pass into the
   `builder` argument.
3. Routes and scoped services
   If you want to get the scoped `IServiceProvider` that created by other route, use the
   `ServiceInheritedWidget<T>` to wrap the widgets of the new route.

### Single root service provider

This is recommended and it's easy to use. Most application should only use a single root service
provider.

Do not specify the generic type `T` or use the same `T` when you use the widgets above.

```dart
Services();

ScopedServices();

ServiceConsumer();
```

### Multiple root service providers

Very few applications require more than one root service provider.  
Use the generic type parameter 'T' to distinguish between different root service providers.

Each root service provider is independent of the others, and if your application needs to use
multiple isolated root service providers, specify a different generic type parameter 'T' for each
root service provider.  
The generic type parameter 'T' is used to distinguish between different root service providers.

Example:

1. RootServiceProvider1  
   When your use `RootServiceProvider1` as the `T`, It will be resolve services from
   `Services<RootServiceProvider1>` or its service scope.
   ```dart
   class RootServiceProvider1 {}
   
   Services<RootServiceProvider1>();
   
   ScopedServices<RootServiceProvider1>();
   
   ServiceConsumer<RootServiceProvider1>();
   ```
   Use `RootServiceProvider1` as `T` to get the `IServiceProvider` instance:
   ```dart
   final serviceProvider = Services.of<RootServiceProvider1>(context);
   ```

2. RootServiceProvider2
   When your use `RootServiceProvider2` as the `T`, It will be resolve services from
   `Services<RootServiceProvider2>` or its service scope.
   ```dart
   class RootServiceProvider2 {}
   
   Services<RootServiceProvider2>();
   
   ScopedServices<RootServiceProvider2>();
   
   ServiceConsumer<RootServiceProvider2>();
   ```
   Use `RootServiceProvider2` as `T` to get the `IServiceProvider` instance:
   ```dart
   final serviceProvider = Services.of<RootServiceProvider2>(context);
   ```

## Getting started

You can use `Services.of<T>` static method to get `IServiceProvider` once you use the widgets above
to wrap
your widgets.

1. Single root service provider in your application.

   ```dart
   class MyWidget extends StatelessWidget {
     @override
     Widget build(BuildContext context) {
       /// Get the IServiceProvider instance.
       final IServiceProvider serviceProvider = Services.of(context);
   
       /// ...
       return Text(serviceProvider
           .getRequiredService<MyService>()
           .applicationName);
     }
   }
   ```
2. Multiple root service providers in your application.

   ```dart
   class MyWidget extends StatelessWidget {
     @override
     Widget build(BuildContext context) {
       /// Get the IServiceProvider from the type of Root1
       final IServiceProvider serviceProvider = Services.of<Root1>(context);
       /// Get the IServiceProvider from the type of Root2
       final IServiceProvider serviceProvider2 = Services.of<Root2>(context);
   
       /// ...
       return Text(serviceProvider
           .getRequiredService<MyService>()
           .applicationName);
     }
   }
   ```

## Usage

Here's a short example. For a full example, check out [example](example).

```dart
void main() {
  runApp(

    /// Use Services<T> as root
    Services(
      serviceConfig: (services) => services.addApplicationServices(),
      builder: (context, _) => const MyApp(),
    ),
  );
}

extension MyAppServiceCollectionExtensions on IServiceCollection {
  void addApplicationServices() {
    this
      ..addLogging(config: (b) => b.useLogger())
      ..addEnvironment(Environment(name: Environments.development));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final logger = Services.of(context).getRequiredLogger<MyApp>();
    logger.info("$MyApp is building");
    return MaterialApp(
      title: 'Flutter service Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyHomePage(title: "Flutter service example"),
    );
  }
}
```

## Additional information

If you have any issues or suggests please redirect
to [repo](https://github.com/codelovercc/flutter_service_provider)
or [send an email](mailto:codelovercc@gmail.com) to me.

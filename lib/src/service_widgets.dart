import 'package:dart_service_provider/dart_service_provider.dart';
import 'package:flutter/widgets.dart';

/// Share the [IServiceProvider] for child widgets.
class ServiceInheritedWidget<T> extends InheritedWidget {
  /// The [IServiceProvider]
  final IServiceProvider provider;

  const ServiceInheritedWidget({
    super.key,
    required this.provider,
    required super.child,
  });

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;
}

/// A widget builder
///
/// - The first parameter is the [BuildContext]
/// - The second parameter is the [IServiceProvider] that holds by the first [ServiceInheritedWidget] in ancestor widget,
/// it may be the root [IServiceProvider] or not.
typedef ProviderWidgetBuilder = Widget Function(BuildContext context, IServiceProvider p);

/// Build service provider and shared the root [IServiceProvider] via [ServiceInheritedWidget].
///
/// - [T] Optional, A type that helps find the correct [IServiceProvider] in the widget tree.
/// Find a state that shared by [InheritedWidget] relies the type of subclass of [InheritedWidget],
/// if there are more than one [Services] in the widget tree, you can specify [T] that makes [Services] as a different type to others [Services] in the widget tree,
/// then you can use [of] method to find them easily with the same type of [T].
///
/// [T] rarely used in most applications, most applications only use a single [Services] widget at the top, in this case, there is no need to specify [T].
class Services<T> extends StatefulWidget {
  /// Config the [ServiceCollection]
  final void Function(ServiceCollection services)? _servicesConfig;

  /// Child widget builder with [IServiceProvider]
  final ProviderWidgetBuilder _builder;

  final ServiceProvider? _provider;

  const Services._({
    super.key,
    void Function(ServiceCollection services)? serviceConfig,
    required ProviderWidgetBuilder builder,
    ServiceProvider? provider,
  })  : _builder = builder,
        _servicesConfig = serviceConfig,
        _provider = provider;

  /// Construct from [serviceConfig]
  ///
  /// - [builder] Child widget builder with [IServiceProvider]
  const Services({
    Key? key,
    required void Function(ServiceCollection services) serviceConfig,
    required ProviderWidgetBuilder builder,
  }) : this._(key: key, serviceConfig: serviceConfig, builder: builder);

  /// Construct from an existing [ServiceProvider]
  ///
  /// - [builder] Child widget builder with [IServiceProvider]
  ///
  /// Note that you need to make sure that [provider] is disposed when it's no longer needed,
  /// this widget will not dispose the external incoming [provider] when it is destroyed.
  ///
  /// This is useful while you want to do something asynchronous after the [ServiceProvider] has been built.
  const Services.fromServiceProvider({
    Key? key,
    required ServiceProvider provider,
    required ProviderWidgetBuilder builder,
  }) : this._(key: key, builder: builder, provider: provider);

  @override
  State<Services<T>> createState() => _ServicesState<T>();

  // This is internal comments.
  // If you want to get the root of IServiceProvider,
  // you can create a `_ServiceRoot<T>` inherited widget to save the root `IServiceProvider`.
  // To get the scoped IServiceProvider, you can create a `_ServiceScope<T>` inherited widget to save the scoped `IServiceProvider`.
  // Then you need to change the `build` method in `_ServicesState<T>` and
  // `_ScopedServicesState<T>` to use the inherited widgets mentioned above.

  /// Document on the [of] method.
  static IServiceProvider? maybeOf<T>(BuildContext context) =>
      context.getInheritedWidgetOfExactType<ServiceInheritedWidget<T>>()?.provider;

  /// Get the service provider in the parent widget tree that holds by the first [ServiceInheritedWidget]
  ///
  /// - [T] Optional, A type that helps find the [IServiceProvider] exactly if there are more than one [ScopedServices] or [Services] in the widget tree.
  /// [T] rarely used in most applications, most applications only use a single [Services] widget at the top and
  /// only care about the nearest [ScopedServices] where the services live, in this case, there is no need to specify [T].
  /// Because scopes are independent of each other, and there is no hierarchical relationship between them,
  /// it generally doesn't make sense to get the other [ScopedServices] state in the ancestor component.
  ///
  /// If you want to get the scoped service provider exactly then [ScopedServices.of] is recommended.
  static IServiceProvider of<T>(BuildContext context) {
    final p = maybeOf<T>(context);
    assert(p != null,
        "No $IServiceProvider found in context, Use $Services to create one and use $ScopedServices to create a scope if need, or use $ServiceInheritedWidget.");
    return p!;
  }
}

/// [State] for [Services] widget.
class _ServicesState<T> extends State<Services<T>> {
  late final ServiceProvider rootProvider;

  @override
  void initState() {
    super.initState();
    if (widget._provider == null) {
      final services = ServiceCollection();
      widget._servicesConfig!(services);
      rootProvider = services.buildServiceProvider();
    } else {
      rootProvider = widget._provider!;
    }
  }

  @override
  void dispose() {
    if (widget._provider == null) {
      rootProvider.disposeAsync();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ServiceInheritedWidget<T>(
        provider: rootProvider,
        child: widget._builder(context, rootProvider),
      );
}

/// Create a scoped and share the scoped [IServiceProvider] with its child widgets via [ServiceInheritedWidget].
///
/// - [T] Optional, A type that helps find the correct [IServiceProvider] in the widget tree.
/// Find a state that shared by [InheritedWidget] relies the type of subclass of [InheritedWidget],
/// if there are more than one [ScopedServices] in the widget tree, you can specify [T] that makes [ScopedServices] as a different type to others [ScopedServices] in the widget tree,
/// then you can use [of] method to find them easily with the same type of [T].
/// Because scopes are independent of each other, and there is no hierarchical relationship between them,
/// it generally doesn't make sense to get the other [ScopedServices] state in the ancestor widget.
///
/// [T] rarely used in most applications, most applications only use a single [Services] widget at the top and
/// only care about the nearest [IServiceProvider] that holds by [ServiceInheritedWidget], in this case, there is no need to specify [T].
class ScopedServices<T> extends StatefulWidget {
  /// Child widget builder with [IServiceProvider]
  final ProviderWidgetBuilder _builder;

  const ScopedServices({super.key, required ProviderWidgetBuilder builder}) : _builder = builder;

  @override
  State<ScopedServices<T>> createState() => _ScopedServicesState<T>();
}

class _ScopedServicesState<T> extends State<ScopedServices<T>> {
  late final IServiceScope scope;

  @override
  void initState() {
    // Call `of` method will call BuildContext.getInheritedWidgetOfExactType
    // Since BuildContext.getInheritedWidgetOfExactType will not subscribe
    // and the ServiceRoot and ServiceScoped will never change and notify changes, so it's safe to call `of` method here.
    final p = Services.of<T>(context);
    scope = p.createScope();
    super.initState();
  }

  @override
  void dispose() {
    scope.disposeAsync();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ServiceInheritedWidget<T>(
        provider: scope.serviceProvider,
        child: widget._builder(context, scope.serviceProvider),
      );
}

/// A widget that consumes services
///
/// - [T] Optional, A type that helps find the correct [IServiceProvider] in the widget tree.
/// [T] rarely used in most applications, most applications only use a single [Services] widget at the top and
/// only care about the nearest [IServiceProvider] that holds by [ServiceInheritedWidget], in this case, there is no need to specify [T].
final class ServiceConsumer<T> extends StatefulWidget {
  /// Child widget builder with [IServiceProvider]
  final ProviderWidgetBuilder builder;

  /// Create a service consumer widget
  ///
  /// - [key] The widget key.
  /// - [builder] The widget builder.
  const ServiceConsumer({super.key, required this.builder});

  @override
  State<ServiceConsumer<T>> createState() => _ServiceConsumerState<T>();
}

final class _ServiceConsumerState<T> extends State<ServiceConsumer<T>> {
  late final IServiceProvider serviceProvider;

  @override
  void initState() {
    serviceProvider = Services.of<T>(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, serviceProvider);
}

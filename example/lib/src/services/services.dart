library;

import 'package:dart_service_provider/dart_service_provider.dart';
import 'services.dart';

export 'singleton_hello_service.dart';
export 'scope_hello_service.dart';
export 'transient_hello_service.dart';

extension AppServiceCollectionExtensions on IServiceCollection {
  void addHelloServices() {
    this
      ..addSingleton<SingletonHelloService, SingletonHelloService>(
        (p) {
          final logger = p.getRequiredLoggerFactory().createLogger<SingletonHelloService>();
          return SingletonHelloService(logger: logger);
        },
      )
      ..addScoped<ScopeHelloService, ScopeHelloService>(
        (p) {
          final logger = p.getRequiredLoggerFactory().createLogger<ScopeHelloService>();
          return ScopeHelloService(logger: logger);
        },
      )
      ..addTransient<TransientHelloService, TransientHelloService>(
        (p) {
          final logger = p.getRequiredLoggerFactory().createLogger<ScopeHelloService>();
          return TransientHelloService(logger: logger);
        },
      );
  }
}

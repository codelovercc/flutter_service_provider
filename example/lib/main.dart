import 'package:dart_service_logger/dart_service_logger.dart';
import 'package:dart_service_provider/dart_service_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_service_provider/flutter_service_provider.dart';

import 'src/services/services.dart';

void main() {
  runApp(
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
      ..addEnvironment(Environment(name: Environments.development))
      ..addHelloServices();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Flutter service Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: MyHomePage(title: "Flutter service example"),
      );
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final String greetingMsg;
  late final String greetingMsg2;

  @override
  void initState() {
    final serviceProvider = Services.of(context);
    final helloService = serviceProvider.getRequiredService<SingletonHelloService>();
    final transientHelloService = serviceProvider.getRequiredService<TransientHelloService>();
    greetingMsg = helloService.greeting("Singleton");
    greetingMsg2 = transientHelloService.greeting("Transient");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(greetingMsg),
            Text(greetingMsg2),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ScopedServices(
                      builder: (context, _) => const ScopeFeatureWidget(),
                    ),
                  ),
                );
              },
              child: Text("Scoped Feature"),
            ),
          ],
        ),
      ),
    );
  }
}

class ScopeFeatureWidget extends StatelessWidget {
  const ScopeFeatureWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final serviceProvider = Services.of(context);
    final service1 = serviceProvider.getRequiredService<ScopeHelloService>();
    final transientHelloService = serviceProvider.getRequiredService<TransientHelloService>();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("$ScopeFeatureWidget"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(service1.greeting("Scope")),
            Text(transientHelloService.greeting("Transient")),
            ServiceConsumer(
              builder: (context, p) {
                final service2 = p.getRequiredService<ScopeHelloService>();
                assert(identical(service1, service2),
                    "ServiceConsumer in ScopedServices widget should use the same IServiceProvider as ScopedServices");
                return Text(service2.greeting("Consumer"));
              },
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return ServiceInheritedWidget(
                        provider: serviceProvider,
                        child: RouteAndScopedServicesWidget(),
                      );
                    },
                  ),
                );
              },
              child: Text("Same scope in new route"),
            ),
          ],
        ),
      ),
    );
  }
}

class RouteAndScopedServicesWidget extends StatelessWidget {
  const RouteAndScopedServicesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final p = Services.of(context);
    final service = p.getRequiredService<ScopeHelloService>();
    return Scaffold(
      appBar: AppBar(
        title: Text("Scoped services in new route"),
      ),
      body: Center(
        child: Text(service.greeting("New Route")),
      ),
    );
  }
}

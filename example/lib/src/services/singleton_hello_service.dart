import 'package:dart_logging_abstraction/dart_logging_abstraction.dart';

class SingletonHelloService {
  final ILogger _logger;

  const SingletonHelloService({required ILogger logger}) : _logger = logger;

  String greeting(String name) {
    final message = "Greetings, $name. From $SingletonHelloService";
    _logger.info(message);
    return message;
  }
}

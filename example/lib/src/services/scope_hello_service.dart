import 'package:dart_logging_abstraction/dart_logging_abstraction.dart';

class ScopeHelloService {
  final ILogger _logger;

  const ScopeHelloService({required ILogger logger}) : _logger = logger;

  String greeting(String name) {
    final message = "Greetings, $name. From $ScopeHelloService";
    _logger.info(message);
    return message;
  }
}

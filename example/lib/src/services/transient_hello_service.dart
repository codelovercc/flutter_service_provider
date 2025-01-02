import 'package:dart_logging_abstraction/dart_logging_abstraction.dart';

class TransientHelloService {
  final ILogger _logger;

  const TransientHelloService({required ILogger logger}) : _logger = logger;

  String greeting(String name) {
    final message = "Greetings, $name. From $TransientHelloService";
    _logger.info(message);
    return message;
  }
}

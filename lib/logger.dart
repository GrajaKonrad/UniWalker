import 'dart:developer' as dev;

abstract class Logger {
  static void critical(dynamic message) =>
      dev.log('\u001b[37;41m$message\u001b[0m');

  static void error(dynamic message) => dev.log('\u001b[31m$message\u001b[0m');

  static void warning(dynamic message) =>
      dev.log('\u001b[33m$message\u001b[0m');

  static void info(dynamic message) => dev.log('\u001b[34m$message\u001b[0m');

  static void success(dynamic message) =>
      dev.log('\u001b[32m$message\u001b[0m');

  static void trace(dynamic message) => dev.log('\u001b[37m$message\u001b[0m');
}

class Message {
  Message() : _message = '';

  String _message;

  void log() => dev.log(_message);

  void critical(dynamic message) =>
      _message += '\u001b[37;41m$message\u001b[0m';

  void error(dynamic message) => _message += '\u001b[31m$message\u001b[0m';

  void warning(dynamic message) => _message += '\u001b[33m$message\u001b[0m';

  void info(dynamic message) => _message += '\u001b[34m$message\u001b[0m';

  void success(dynamic message) => _message += '\u001b[32m$message\u001b[0m';

  void trace(dynamic message) => _message += '\u001b[37m$message\u001b[0m';

  void newLine() => _message += '\n';

  void clear() => _message = '';
}

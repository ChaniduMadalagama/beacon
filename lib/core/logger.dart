import 'dart:developer' as dev;

class AppLogger {
  static void log(String message, {String? name}) {
    dev.log(message, name: name ?? 'APP');
  }

  static void error(String message, {Object? error, StackTrace? stackTrace}) {
    dev.log(message, name: 'ERROR', error: error, stackTrace: stackTrace);
  }
}

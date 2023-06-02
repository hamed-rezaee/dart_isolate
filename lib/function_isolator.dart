import 'dart:async';
import 'dart:isolate';

/// Executes a function in an isolate.
class FunctionIsolator<T> {
  /// Initializes a new instance of [FunctionIsolator].
  const FunctionIsolator();

  /// Executes a function in an isolate.
  ///
  /// [function] is the function to be executed in an isolate.
  /// [positionalArguments] are the positional arguments to be passed to the function.
  /// [namedArguments] are the named arguments to be passed to the function.
  /// Returns a [Future] that completes with the result of the function.
  Future<T> call(
    final Function function, [
    final List<dynamic>? positionalArguments,
    final Map<Symbol, dynamic>? namedArguments,
  ]) async {
    final ReceivePort receivePort = ReceivePort();
    final Isolate isolate = await Isolate.spawn(
      _isolateEntry,
      _IsolatePayload(
        function,
        positionalArguments,
        namedArguments,
        receivePort.sendPort,
      ),
    );

    final Completer<T> completer = Completer<T>();

    receivePort.listen((dynamic message) {
      if (message is T) {
        completer.complete(message);
      } else if (message is Exception) {
        completer.completeError(message);
      }

      _dispose(receivePort, isolate);
    });

    return completer.future;
  }

  static void _isolateEntry(_IsolatePayload payload) {
    try {
      final dynamic result = Function.apply(
        payload.function,
        payload.positionalArguments,
        payload.namedArguments,
      );

      payload.sendPort.send(result);
    } on Exception catch (e) {
      payload.sendPort.send(Exception(e));
    }
  }

  static void _dispose(ReceivePort receivePort, Isolate isolate) {
    receivePort.close();
    isolate.kill(priority: Isolate.immediate);
  }
}

class _IsolatePayload {
  _IsolatePayload(
    this.function,
    this.positionalArguments,
    this.namedArguments,
    this.sendPort,
  );

  final Function function;
  final List<dynamic>? positionalArguments;
  final Map<Symbol, dynamic>? namedArguments;
  final SendPort sendPort;
}

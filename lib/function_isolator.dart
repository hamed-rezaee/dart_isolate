import 'dart:async';
import 'dart:isolate';

/// Executes a function in an isolate.
class FunctionIsolator<T> {
  /// Initializes a new instance of the [FunctionIsolator] class.
  FunctionIsolator(
    this.function,
    this.positionalArguments, [
    this.namedArguments,
  ]);

  /// The function to be executed in the isolate.
  final Function function;

  /// The positional arguments to be passed to the function.
  final List<dynamic>? positionalArguments;

  /// The named arguments to be passed to the function.
  final Map<Symbol, dynamic>? namedArguments;

  /// Executes the function in an isolate.
  Future<T> call() async {
    final ReceivePort receivePort = ReceivePort();
    final Isolate isolate =
        await Isolate.spawn(_isolateEntry, receivePort.sendPort);

    final Completer<T> completer = Completer<T>();

    receivePort.listen((dynamic message) {
      if (message is SendPort) {
        message.send(
          _ExecutionPayload(function, positionalArguments, namedArguments),
        );
      } else if (message is T) {
        completer.complete(message);
        _dispose(receivePort, isolate);
      } else if (message is Exception) {
        completer.completeError(message);
        _dispose(receivePort, isolate);
      }
    });

    return completer.future;
  }

  void _isolateEntry(SendPort sendPort) {
    final ReceivePort receivePort = ReceivePort();

    sendPort.send(receivePort.sendPort);

    receivePort.listen((dynamic message) {
      if (message is _ExecutionPayload) {
        try {
          final dynamic result = Function.apply(
            message.function,
            message.positionalArguments,
            message.namedArguments,
          );

          sendPort.send(result);
        } on Exception catch (e) {
          sendPort.send(e);
        }
      }
    });
  }

  void _dispose(ReceivePort receivePort, Isolate isolate) {
    receivePort.close();
    isolate.kill(priority: Isolate.immediate);
  }
}

class _ExecutionPayload {
  _ExecutionPayload(
    this.function,
    this.positionalArguments, [
    this.namedArguments,
  ]);

  final Function function;
  final List<dynamic>? positionalArguments;
  final Map<Symbol, dynamic>? namedArguments;
}

import 'dart:async';
import 'dart:isolate';

class IsolateHandler<T> {
  Isolate? _isolate;
  late ReceivePort _receivePort;

  Future<T> run(Function callback, [dynamic? argument]) async {
    final completer = Completer<T>();
    _receivePort = ReceivePort();
    _isolate = await Isolate.spawn(_isolateEntry, _receivePort.sendPort);

    _receivePort.listen((message) {
      if (message is SendPort) {
        message.send([callback, argument]);
      } else if (message is Error) {
        completer.completeError(message);
        _receivePort.close();
        _isolate?.kill();
      } else {
        completer.complete(message as T);
        _receivePort.close();
        _isolate?.kill();
      }
    });

    return completer.future;
  }

  static void _isolateEntry(SendPort sendPort) {
    final receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);

    receivePort.listen((message) {
      final data = message as List;
      final callback = data[0] as Function;
      final argument = data[1];

      try {
        final result = Function.apply(callback, argument is Map ? [] : [argument], argument is Map ? argument : null);
        sendPort.send(result);
      } catch (error) {
        sendPort.send(error);
      }
    });
  }
}

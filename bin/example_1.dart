import 'dart:isolate';

Future<void> main(List<String> arguments) async {
  await getMessages().take(10).forEach(print);
}

Stream<String> getMessages() {
  final ReceivePort receivePort = ReceivePort();

  return Isolate.spawn(_getMessages, receivePort.sendPort)
      .asStream()
      .asyncExpand((Isolate event) => receivePort)
      .takeWhile((dynamic element) => element is String)
      .cast<String>();
}

Future<void> _getMessages(SendPort sendPort) async => Stream<String>.periodic(
      const Duration(milliseconds: 200),
      (_) => DateTime.now().toIso8601String(),
    ).forEach(sendPort.send);

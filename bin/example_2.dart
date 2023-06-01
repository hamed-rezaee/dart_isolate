import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

Future<void> main(List<String> arguments) async {
  do {
    stdout.write('You: ');
    final String? message = stdin.readLineSync(encoding: utf8);

    switch (message) {
      case null:
        continue;
      case 'exit':
        print('Goodbye!');
        exit(0);

      default:
        print('${await getMessages(message!)}');
        break;
    }
  } while (true);
}

const Map<String, String> messagesAndResponses = <String, String>{
  '': 'Ask me a question like "How are you?"',
  'Hello': 'Hi there!',
  'How are you?': 'I am doing well, thanks for asking.',
  'What is your name?': 'My name is Dart.',
};

Future<void> _communicator(SendPort sendPort) async {
  final ReceivePort receivePort = ReceivePort();

  sendPort.send(receivePort);

  final Stream<String> messages = receivePort
      .takeWhile((dynamic element) => element is String)
      .cast<String>();

  await for (final String message in messages) {
    final String response = messagesAndResponses[message] ?? 'I do not know.';

    sendPort.send(response);
  }
}

Future<String> getMessages(String message) async {
  final ReceivePort receivePort = ReceivePort();

  await Isolate.spawn(_communicator, receivePort.sendPort);

  final Stream<dynamic> stream = receivePort.asBroadcastStream();
  final SendPort communicator = await stream.first;

  communicator.send(message);

  return stream
      .takeWhile((dynamic element) => element is String)
      .cast<String>()
      .first;
}

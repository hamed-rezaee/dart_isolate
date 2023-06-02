import 'dart:async';
import 'dart:isolate';

import 'package:dart_isolate_playground/function_isolator.dart';
import 'package:dart_isolate_playground/function_isolator_extension.dart';

class User {
  User(this.id, this.name, this.email);

  factory User.fromJson(Map<String, dynamic> json) =>
      User(json['id'], json['name'], json['email']);

  final int id;
  final String name;
  final String email;
}

void main() async {
  final Duration normalDuration =
      await calculateExecutionTime(() => heavyCalculations());

  final Duration isolateDuration = await calculateExecutionTime(
    () async => const FunctionIsolator<void>()(heavyCalculations),
  );

  final Duration isolatorDuration = await calculateExecutionTime(
    () async => heavyCalculations.isolator(),
  );

  final Duration isolateRunDuration = await calculateExecutionTime(
    () async => Isolate.run(() => heavyCalculations()),
  );

  print('Normal way: Parsed in ${normalDuration.inMilliseconds}ms');
  print('Isolate Executor: Parsed in ${isolateDuration.inMilliseconds}ms');
  print('Isolator: Parsed in ${isolatorDuration.inMilliseconds}ms');
  print('Isolate Run: Parsed in ${isolateRunDuration.inMilliseconds}ms');
}

void heavyCalculations() {
  for (int i = 0; i < 1000; i++) {
    calculateFactorial(10000);
  }
}

int calculateFactorial(int n) {
  if (n == 0) {
    return 1;
  }

  return n * calculateFactorial(n - 1);
}

Future<Duration> calculateExecutionTime(Function function) async {
  final Stopwatch stopwatch = Stopwatch()..start();
  await function();
  stopwatch.stop();

  return stopwatch.elapsed;
}

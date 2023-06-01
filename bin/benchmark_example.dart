import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

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
  final http.Response response =
      await http.get(Uri.parse('https://jsonplaceholder.typicode.com/users'));

  final dynamic jsonData = json.decode(response.body);

  const int iterations = 1000;

  final Duration normalDuration = await calculateExecutionTime(() async {
    for (int i = 0; i < iterations; i++) {
      _parseUsers(jsonData);
    }
  });

  final Duration isolateDuration = await calculateExecutionTime(() async {
    for (int i = 0; i < iterations; i++) {
      await _parseUsersIsolate(jsonData);
    }
  });

  final Duration isolatorDuration = await calculateExecutionTime(() async {
    for (int i = 0; i < iterations; i++) {
      await _parseUsers.isolator(<dynamic>[jsonData]);
    }
  });

  print('Normal way: Parsed in ${normalDuration.inMilliseconds}ms');
  print('IsolateExecutor: Parsed in ${isolateDuration.inMilliseconds}ms');
  print('Isolator: Parsed in ${isolatorDuration.inMilliseconds}ms');
}

List<User> _parseUsers(List<dynamic> jsonData) =>
    jsonData.map((dynamic json) => User.fromJson(json)).toList();

Future<List<User>> _parseUsersIsolate(List<dynamic> jsonData) async =>
    FunctionIsolator<List<User>>(_parseUsers, <dynamic>[jsonData])();

Future<Duration> calculateExecutionTime(Function function) async {
  final Stopwatch stopwatch = Stopwatch()..start();
  await function();
  stopwatch.stop();

  return stopwatch.elapsed;
}

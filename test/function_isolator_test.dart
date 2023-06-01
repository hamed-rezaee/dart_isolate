import 'package:test/test.dart';

import 'package:dart_isolate_playground/function_isolator.dart';

void main() {
  group('FunctionIsolator tests =>', () {
    test('executes the function in an isolate with no parameters.', () {
      const int expectedResult = 42;

      final FunctionIsolator<int> isolator = FunctionIsolator<int>(() => 42);

      expect(isolator.call(), completion(equals(expectedResult)));
    });

    test('executes the function in an isolate with positional parameters.',
        () async {
      const int expectedResult = 42;

      final FunctionIsolator<int> isolator =
          FunctionIsolator<int>((int a, int b) => a + b, <int>[20, 22]);

      expect(isolator.call(), completion(equals(expectedResult)));
    });

    test('executes the function with optional positional parameters.',
        () async {
      const int expectedResult = 10;

      final FunctionIsolator<int> isolator = FunctionIsolator<int>(
        (int a, [int b = 0, int c = 0]) => a + b + c,
        <int>[5, 3, 2],
      );

      expect(isolator.call(), completion(equals(expectedResult)));
    });

    test('executes the function with optional parameters.', () async {
      const String expectedResult = 'Hello, John Doe!';

      final FunctionIsolator<String> isolator = FunctionIsolator<String>(
        (String name, {String prefix = ''}) => '$prefix$name!',
        <String>['John Doe'],
        <Symbol, String>{#prefix: 'Hello, '},
      );

      expect(isolator.call(), completion(equals(expectedResult)));
    });

    test('executes a function without return type.', () async {
      final FunctionIsolator<void> isolator =
          FunctionIsolator<void>(() => print('Hello, World!'));

      expect(isolator.call(), completes);
    });

    test('handles exceptions in the isolate.', () async {
      final FunctionIsolator<int> isolator =
          FunctionIsolator<int>(() => throw Exception('Something went wrong'));

      expect(isolator.call(), throwsA(isA<Exception>()));
    });
  });
}

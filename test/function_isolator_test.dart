import 'package:test/test.dart';

import 'package:dart_isolate_playground/function_isolator.dart';

void main() {
  group('FunctionIsolator tests =>', () {
    late final FunctionIsolator<void> voidIsolator;
    late final FunctionIsolator<int> intIsolator;
    late final FunctionIsolator<String> stringIsolator;

    setUpAll(() {
      voidIsolator = const FunctionIsolator<void>();
      intIsolator = const FunctionIsolator<int>();
      stringIsolator = const FunctionIsolator<String>();
    });

    test('executes the function in an isolate with no parameters.', () {
      const int expectedResult = 42;

      expect(
        intIsolator(() => expectedResult),
        completion(equals(expectedResult)),
      );
    });

    test('executes the function in an isolate with positional parameters.',
        () async {
      const int expectedResult = 42;

      expect(
        intIsolator((int a, int b) => a + b, <int>[20, 22]),
        completion(equals(expectedResult)),
      );
    });

    test('executes the function with optional positional parameters.',
        () async {
      const int expectedResult = 10;

      expect(
        intIsolator(
          (int a, [int b = 0, int c = 0]) => a + b + c,
          <int>[5, 3, 2],
        ),
        completion(equals(expectedResult)),
      );
    });

    test('executes the function with optional parameters.', () async {
      const String expectedResult = 'Hello, John Doe!';

      expect(
        stringIsolator(
          (String name, {String prefix = ''}) => '$prefix$name!',
          <String>['John Doe'],
          <Symbol, String>{#prefix: 'Hello, '},
        ),
        completion(equals(expectedResult)),
      );
    });

    test('executes a function without return type.', () async {
      expect(voidIsolator(() {}), completes);
    });

    test('handles exceptions in the isolate.', () async {
      expect(
        intIsolator(() => throw Exception('Something went wrong')),
        throwsA(isA<Exception>()),
      );
    });
  });
}

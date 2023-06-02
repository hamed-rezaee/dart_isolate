import 'package:dart_isolate_playground/function_isolator.dart';

/// Extension for [Function] to execute it in an isolate.
extension IsolatorExtension on Function {
  /// Executes the function in an isolate.
  Future<T> isolator<T>([
    final List<dynamic>? positionalArguments,
    final Map<Symbol, dynamic>? namedArguments,
  ]) async =>
      FunctionIsolator<T>()(this, positionalArguments, namedArguments);
}

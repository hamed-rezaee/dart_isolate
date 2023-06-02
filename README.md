# Function Isolator

`FunctionIsolator` is a Dart class that allows you to execute a function in an isolate, which is a separate execution context. This can be useful for offloading heavy computations or tasks to separate threads.

## Usage

1. Create an instance of `FunctionIsolator`:

```dart
final isolator = FunctionIsolator();
```

2. Execute the function in the isolate by calling the call method:

```dart
final result = await isolator.call(function, positionalArguments, namedArguments);
```

Since the `call` method is the _default method_, you can also call it directly:

```dart
final result = await isolator(function, positionalArguments, namedArguments);
```

The `call` method returns a Future that completes with the result of type `T` when the function execution is finished.

- `function`: The function to be executed in the isolate.

- `positionalArguments` (optional): The positional arguments to be passed to the function.

- `namedArguments` (optional): The named arguments to be passed to the function.

3. Handle the result or any potential exceptions:

```dart
try {
  final result = await isolator(function, positionalArguments, namedArguments);
  // Handle the result.
} catch (e) {
  // Handle the exception.
}
```

## Example

Here's an example that demonstrates how to use `FunctionIsolator`:

```dart
// Define a function to be executed in the isolate.
int addNumbers(int a, int b) => a + b;

void main() async {
  final isolator = FunctionIsolator<int>();

  try {
    final result = await isolator(addNumbers, [2, 3]);

    print(result); // Output: 5
  } catch (e) {
    print('Error: $e');
  }
}
```

In this example, the `addNumbers` function is executed in an isolate with positional arguments `[2, 3]`. The result is obtained and printed to the console.

Alternatively, you can use `Isolator Extension` to execute any function in an isolate, This extension allows you to call the isolator method directly on any function and execute it in an isolate.

```dart
// Define a function to be executed in the isolate.
int addNumbers(int a, int b) => a + b;

void main() async {
  try {
    final result = await addNumbers.isolator([2, 3]);

    print(result); // Output: 5
  } catch (e) {
    print('Error: $e');
  }
}
```

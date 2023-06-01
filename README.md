# Function Isolator

`FunctionIsolator` is a Dart class that allows you to execute a function in an isolate, which is a separate execution context. This can be useful for offloading heavy computations or tasks to separate threads.

## Usage

1. Create an instance of `FunctionIsolator` by passing the function and its optional arguments:

```dart
final isolator = FunctionIsolator(function, positionalArguments, namedArguments);
```

`function`: The function to be executed in the isolate.

`positionalArguments` (optional): The positional arguments to be passed to the function.

`namedArguments` (optional): The named arguments to be passed to the function.

2. Execute the function in the isolate by calling the call method:

```dart
final result = await isolator();
```

The `call` method returns a Future that completes with the result of type `T` when the function execution is finished.

3. Handle the result or any potential exceptions:

```dart
try {
  final result = await isolator.call();
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
  final isolator = FunctionIsolator(addNumbers, [2, 3]);

  try {
    final result = await isolator();

    print(result); // Output: 5
  } catch (e) {
    print('Error: $e');
  }
}
```

In this example, the `addNumbers` function is executed in an isolate with positional arguments `[2, 3]`. The result is obtained and printed to the console.

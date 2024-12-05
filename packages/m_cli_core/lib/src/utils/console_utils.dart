import 'dart:io';

import 'package:ansicolor/ansicolor.dart';
import 'package:dart_console/dart_console.dart';

/// Enum to define different types of text output for the console.
enum TextType {
  /// Represents debug messages, typically styled in green.
  debug,

  /// Represents warning messages, typically styled in yellow.
  warn,

  /// Represents error messages, typically styled in red.
  error,

  /// Represents normal messages, typically styled in white.
  normal;

  /// Returns the [AnsiPen] used to colorize text based on the [TextType].
  AnsiPen get textPain => switch (this) {
        TextType.debug => green,
        TextType.warn => yellow,
        TextType.error => red,
        TextType.normal => white,
      };

  /// Wraps the given [message] with the appropriate color based on the [TextType].
  Object wrapText(String message) {
    return textPain(message);
  }
}

/// A utility class for console-based interactions and text styling.
class ConsoleUtils {
  /// Private constructor to prevent instantiation.
  ConsoleUtils._();

  /// Prints a simple message to the console without a newline, using the specified [TextType].
  ///
  /// - [type]: The type of message (e.g., debug, warn, error, or normal). Defaults to `TextType.normal`.
  /// - [message]: The message to be printed.
  static void echoText({
    TextType type = TextType.normal,
    required String message,
  }) {
    stdout.write(type.wrapText(message));
  }

  /// Prints a message to the console followed by a newline, using the specified [TextType].
  ///
  /// - [type]: The type of message (e.g., debug, warn, error, or normal). Defaults to `TextType.normal`.
  /// - [messageLine]: The message to be printed.
  static void echoLine({
    TextType type = TextType.normal,
    required String messageLine,
  }) {
    Console().writeLine(type.wrapText(messageLine));
  }

  /// Prints a message and waits for user input, then returns the user's input.
  ///
  /// If the user provides an empty input, a warning message is displayed,
  /// and the prompt is repeated until a valid input is provided.
  ///
  /// - [type]: The type of the prompt message. Defaults to `TextType.normal`.
  /// - [messageOut]: The prompt message to be displayed to the user.
  ///
  /// Returns the user's input as a [String].
  static String? echoAndRead({
    TextType type = TextType.normal,
    required String messageOut,
  }) {
    // Print the prompt message.
    echoText(message: messageOut);

    // Read input from the user.
    String? userInput = stdin.readLineSync();

    // If the input is null or empty, show a warning and repeat the prompt.
    if (userInput == null || userInput.isEmpty) {
      echoLine(type: TextType.warn, messageLine: "Please input a value!");
      return echoAndRead(messageOut: messageOut);
    }

    // Return the user's input.
    return userInput;
  }
}

///ANSI pens Bold red for errors.
AnsiPen red = AnsiPen()..red(bold: true);

///ANSI pens Bold green for debug messages.
AnsiPen green = AnsiPen()..green(bold: true);

///ANSI pens Bold white for normal messages.
AnsiPen white = AnsiPen()..white(bold: true);

///ANSI pens Bold yellow for warnings.
AnsiPen yellow = AnsiPen()..yellow(bold: true);

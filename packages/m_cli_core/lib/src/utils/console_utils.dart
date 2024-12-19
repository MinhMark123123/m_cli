import 'dart:io';

import 'package:ansicolor/ansicolor.dart';
import 'package:dart_console/dart_console.dart';

/// Enum to define different types of text output for the console.
enum TextType {
  /// Represents debug messages, typically styled in green.
  success,

  /// Represents warning messages, typically styled in yellow.
  warn,

  /// Represents error messages, typically styled in red.
  error,

  /// Represents normal messages, typically styled in white.
  normal;

  /// Returns the [AnsiPen] used to colorize text based on the [TextType].
  AnsiPen get textPain => switch (this) {
        TextType.success => green,
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
    bool allowNullOrEmptyInput = false,
  }) {
    // Print the prompt message.
    echoText(message: messageOut);

    // Read input from the user.
    String? userInput = stdin.readLineSync();

    // If the input is null or empty, show a warning and repeat the prompt.
    if (allowNullOrEmptyInput == false &&
        (userInput == null || userInput.isEmpty)) {
      echoLine(type: TextType.warn, messageLine: "Please input a value!");
      return echoAndRead(messageOut: messageOut);
    }

    // Return the user's input.
    return userInput;
  }

  static bool echoConfirmSelection({
    required String message,
    String confirmHint = "(y/n)",
    List<String>? keysConfirm,
  }) {
    final userKeysConfirm = keysConfirm ?? ["y", "yes"];
    final userInput = echoAndRead(messageOut: message);
    if (userKeysConfirm.contains(userInput?.toLowerCase())) return true;
    return false;
  }

  static List<String> echoListOption({
    required String message,
    required List<String> options,
    bool isMultipleChoice = true,
  }) {
    final console = Console();
    console.writeLine("$message${options.map((e) => "\n").join()}");
    bool isPressedEnter = false;
    int selectedIndex = 0;
    _echoOptions(
      console: console,
      options: options,
      selectedIndex: selectedIndex,
    );
    console.rawMode = true;
    while (!isPressedEnter) {
      final key = console.readKey();
      if (key.isControl) {
        if (key.controlChar == ControlCharacter.enter) {
          isPressedEnter = true;
        } else if (key.controlChar == ControlCharacter.arrowUp) {
          selectedIndex =
              selectedIndex > 0 ? selectedIndex - 1 : options.length - 1;
        } else if (key.controlChar == ControlCharacter.arrowDown) {
          selectedIndex =
              selectedIndex < options.length - 1 ? selectedIndex + 1 : 0;
        }
        _echoOptions(
          console: console,
          options: options,
          selectedIndex: selectedIndex,
        );
      } else if (key.char == " ") {
        if (selectedIndex >= 0 && selectedIndex < options.length) {
          final prefix = options[selectedIndex].startsWith('* ') ? '' : '* ';
          if (!isMultipleChoice) {
            options = options
                .map(
                  (option) => option.replaceAll('* ', ''),
                )
                .toList();
          }
          options[selectedIndex] =
              '$prefix${options[selectedIndex].replaceAll('* ', '')}';
        }
        _echoOptions(
          console: console,
          options: options,
          selectedIndex: selectedIndex,
        );
      }
    }
    console.rawMode = false;
    final selectedOptions = options
        .where((option) => option.startsWith('* '))
        .map((option) => option.replaceAll('* ', ''))
        .toList();
    console.writeLine('Selected options: ${selectedOptions.join(', ')}');
    return selectedOptions;
  }

  static void _echoOptions({
    required Console console,
    required List<String> options,
    required int selectedIndex,
  }) {
    _clearOptionsListEcho(console, options, selectedIndex);
    for (int i = 0; i < options.length; i++) {
      var text = options[i];
      if (text.startsWith("* ")) {
        text = text.replaceAll('* ', '');
        text = green('* $text');
      } else {
        text = "  $text";
      }
      if (i == selectedIndex) {
        console.write(' > $text\n');
      } else {
        console.write('   $text\n');
      }
    }
  }

  static void _clearOptionsListEcho(
    Console console,
    List<String> options,
    int selectedIndex,
  ) {
    for (int i = 0; i < options.length; i++) {
      console.cursorUp();
      console.eraseLine();
    }
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

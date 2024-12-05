<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages).
-->
# test_badge_gen
![pub package](https://img.shields.io/pub/v/test_badge_gen.svg?label=pub&color=blue) ![Coverage](coverage_badge.svg)

**Test Badge Coverage ** is a simple command-line tool for generating test coverage badges in SVG format from an `lcov.info` file.
---

## Features

- Generate test coverage badges based on `lcov.info` files.
- Customize the output file path for generated badges.
- Built with Dart for speed and reliability.
- Provides helpful console output and guidance.

## Installation
1. Active `test_badge_gen` package :
   - Flutter:
    ```bash
      flutter pub global activate test_badge_gen
    ```
   - Or with Dart:
    ```bash
      dart pub global activate test_badge_gen
    ```
2. Ensure that the CLI executable is globally available. Add the Dart bin folder to your PATH:
    ```bash
      export PATH="$PATH":"$HOME/.pub-cache/bin"
    ```
3. Verify the installation:
    ```bash
      badge-test --help
    ```
## Usage

The badge-test CLI provides commands for generating test coverage badges. Below are usage instructions with examples.

#### Command: gen
The gen command generates a badge from the specified lcov.info file.

#### Syntax:
```bash
  badge-test gen --in=<path_to_lcov.info> --out=<output_path>
```
#### Options:
| Option       | Description                                                                                | Required | Default            |
|--------------|--------------------------------------------------------------------------------------------|----------|--------------------|
| --in=<path>  | The input path to the lcov.info file.                                                      | Yes      | None               |
| --out=<path> | The output path for the generated badge. If not specified, defaults to coverage_badge.svg. | No       | coverage_badge.svg |

#### Example:
1. Basic Usage:

   ```bash
   badge-test gen --in=lcov.info
   ```
   This generates a badge file named coverage_badge.svg in the current directory.

2. Custom Output Path:

   ```bash
   badge-test gen --in=lcov.info --out=badges/test_coverage.svg
   ```
   This generates a badge file at the specified output path.
   ![Coverage](doc/coverage_badge.svg)

3. Error Handling: If the input file is missing or invalid, the command will prompt an error message:

   ```
   Generator failed! Please input lcov.info file path.
   ```


## Additional information
### To show in README 
Add 
```
![Coverage](https://raw.githubusercontent.com/{you}/{repo}/master/{yourSVGFile}.svg?sanitize=true)
```
### Running the CLI Locally
Clone the repository:
```bash
git clone https://github.com/MinhMark123123/m_cli.git
cd m_cli/test_badge_gen
```
Activate the CLI locally:
```bash
dart pub global activate --source path .
```
Run :
```bash
badge-test gen --in=lcov.info
```

### Running Tests 🧪

To run all unit tests:

```sh
dart pub global activate coverage
dart test --coverage=coverage
dart pub global run coverage:format_coverage --lcov --in=coverage --out=coverage/lcov.info
```

To view the generated coverage report you can use [lcov](https://github.com/linux-test-project/lcov).

```sh
# Generate Coverage Report
genhtml coverage/lcov.info -o coverage/

# Open Coverage Report
open coverage/index.html
```

To Generate badge image

```
badge-test gen --in=coverage/lcov.info
```

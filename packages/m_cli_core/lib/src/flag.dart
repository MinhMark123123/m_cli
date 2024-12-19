import 'package:args/args.dart';

class Flag {
  final String name;
  final String abbr;
  final String help;

  Flag({
    required this.name,
    required this.abbr,
    required this.help,
  });

  bool isFlagEnable({ArgResults? argResults}) {
    return argResults?.flag(name) ?? false;
  }
}

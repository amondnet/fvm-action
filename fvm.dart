import 'dart:convert';

import 'package:github_actions_toolkit/github_actions_toolkit.dart' as action;
import 'dart:io';
void main() {
  const logger = action.log;
  const pathInput = action.Input(
    'path',
    isRequired: false,
  );

  final configPath = pathInput.value ?? '.fvm/fvm_config.json';
  final configFile = File(configPath);

  final config = jsonDecode(configFile.readAsStringSync());
  final flutterSdkVersion = config['flutterSdkVersion'];


}
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';

import 'app.dart';
import 'config/di/service_locator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o media_kit (MPV).
  MediaKit.ensureInitialized();

  // Registra dependências.
  setupDependencies();

  runApp(const FireLinkApp());
}

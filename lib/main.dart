import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';

import 'app.dart';
import 'config/di/service_locator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Registra o media_kit como backend de áudio para Windows/Linux.
  // Necessário porque just_audio não tem plugin nativo para desktop.
  JustAudioMediaKit.ensureInitialized();

  // Inicializa o serviço de background audio (notificação de mídia,
  // controles na lockscreen, headset buttons, etc.).
  // Apenas em plataformas mobile — no desktop é no-op ou pode falhar.
  if (!kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS)) {
    await JustAudioBackground.init(
      androidNotificationChannelId: 'com.firelink.audio.channel',
      androidNotificationChannelName: 'FireLink Audio',
      androidNotificationOngoing: true,
    );
  }

  // Registra dependências (DataSources, Repositories, BLoCs).
  setupDependencies();

  runApp(const FireLinkApp());
}

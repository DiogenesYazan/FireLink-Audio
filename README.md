# 🔥 FireLink Audio

Um cliente de música open-source de alta fidelidade, construído com **Flutter** e alimentado pelo YouTube como fonte de áudio.

![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)
![License](https://img.shields.io/badge/License-MIT-green)

## ✨ Funcionalidades

- 🔍 **Busca de músicas** — Pesquise qualquer música diretamente do YouTube
- 🎵 **Player de áudio completo** — Play, Pause, Next, Previous, Seek, Volume
- 📝 **Letras sincronizadas** — Letras em tempo real via lrclib.net (formato LRC)
- 🔔 **Background playback** — Continue ouvindo com a tela bloqueada (notificação de mídia)
- 🎨 **Design Spotify-like** — Tema escuro com gradientes lilás/roxo
- 📱 **Responsivo** — Otimizado para dispositivos mobile

## 🛠️ Tech Stack

| Camada | Tecnologia |
|--------|-----------|
| **Framework** | Flutter (Dart) |
| **Áudio** | just_audio + just_audio_background |
| **Busca & Stream** | youtube_explode_dart |
| **Letras** | lrclib.net API (gratuita, sem API key) |
| **Estado** | flutter_bloc (BLoC pattern) |
| **DI** | get_it (Service Locator) |
| **Imagens** | cached_network_image |
| **Fontes** | Google Fonts (Poppins) |

## 📂 Estrutura do Projeto

```
lib/
├── main.dart                    # Entry point
├── app.dart                     # MaterialApp + tema + providers
├── config/
│   ├── di/                      # Injeção de dependências (get_it)
│   └── theme/                   # Tema dark, paleta de cores
├── core/
│   ├── constants/               # URLs, configurações
│   ├── errors/                  # Classes de falha tipadas
│   └── utils/                   # Formatadores, debouncer
├── data/
│   ├── datasources/             # YouTube, lrclib.net
│   ├── models/                  # TrackModel, LyricsModel
│   └── repositories/            # Implementações concretas
├── domain/
│   ├── entities/                # Track, Lyrics (entidades puras)
│   └── repositories/            # Interfaces abstratas
└── presentation/
    ├── blocs/                   # PlayerBloc, SearchBloc, LyricsCubit
    ├── navigation/              # MainShell com BottomNavigationBar
    ├── screens/                 # Home, Search, Library
    └── widgets/                 # MiniPlayer, PlayerBottomSheet, etc.
```

## 🚀 Como Rodar

### Pré-requisitos

- Flutter SDK 3.x+
- Dart 3.x+
- Android Studio / Xcode (para emuladores)

### Setup

```bash
# Clone o repositório
git clone https://github.com/DiogenesYazan/FireLink-Audio.git
cd firelink-audio

# Instale as dependências
flutter pub get

# (Opcional) Configure variáveis de ambiente
cp .env.example .env

# Execute o app
flutter run
```

### Plataformas Testadas

- ✅ Android
- ✅ iOS
- ⚠️ Web (sem background playback)
- ⚠️ Windows/Linux/macOS (requer just_audio_media_kit)

## 🎨 Design System

- **Tema:** Dark Mode exclusivo
- **Paleta:** Gradientes entre Lilás (`#C77DFF`) e Roxo Meia-Noite (`#240046`)
- **Fonte:** Poppins (Google Fonts)
- **Estilo:** Inspirado no Spotify (Home, Busca, Player em Bottom Sheet, Biblioteca)

## ⚠️ Aviso Legal

> **Este projeto é exclusivamente para fins educacionais e de estudo.**
>
> O streaming de conteúdo protegido por direitos autorais pode violar leis locais e os Termos de Serviço do YouTube. Este aplicativo **não** se destina ao uso em produção ou distribuição comercial.
>
> Os desenvolvedores **não se responsabilizam** pelo uso indevido desta aplicação. Use por sua conta e risco, respeitando as leis de direitos autorais da sua jurisdição.
>
> Este projeto não é afiliado, associado, autorizado, endossado ou de qualquer forma oficialmente conectado ao YouTube, Google, Spotify ou qualquer de suas subsidiárias.

## 📄 Licença

Este projeto está licenciado sob a Licença MIT — veja o arquivo [LICENSE](LICENSE) para detalhes.

## 🙏 Créditos

- [youtube_explode_dart](https://pub.dev/packages/youtube_explode_dart) — Extração de metadados e streams do YouTube
- [just_audio](https://pub.dev/packages/just_audio) — Player de áudio multiplataforma
- [lrclib.net](https://lrclib.net) — API de letras sincronizadas
- [flutter_bloc](https://pub.dev/packages/flutter_bloc) — Gerenciamento de estado

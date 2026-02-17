# 🔥 FireLink Audio

Cliente de música open-source de alta fidelidade, construído com **Flutter** e alimentado pela **SoundCloud API** como fonte de áudio.

![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)
![License](https://img.shields.io/badge/License-MIT-green)

## ✨ Funcionalidades

### 🎵 Reprodução & Controle
- **Player completo** — Play, Pause, Next, Previous, Seek, Volume
- **Shuffle & Repeat** — Modos aleatório e repetição (uma/todas)
- **Fila de reprodução** — Visualize e reordene as próximas músicas
- **Background playback** — Continue ouvindo com a tela bloqueada (notificação de mídia no Android)
- **Mini player persistente** — Controles rápidos na barra inferior

### 🔍 Descoberta & Busca
- **Busca de músicas** — Pesquise qualquer música do catálogo SoundCloud
- **Trending charts** — Músicas populares por gênero (Pop, Eletrônica, Hip-Hop, R&B, Rock, Latin, etc.)
- **Histórico de reprodução** — Acesse suas últimas 50 músicas ouvidas

### ❤️ Biblioteca & Favoritos
- **Músicas curtidas** — Salve suas favoritas localmente (persistência via SharedPreferences)
- **Biblioteca organizada** — Acesso rápido a curtidas e histórico
- **Seção "Tocadas Recentemente"** — Atalhos na Home e na Biblioteca

### 📝 Letras Sincronizadas
- **Letras em tempo real** — Via lrclib.net (formato LRC)
- **Auto-scroll** — Acompanha a posição da música
- **Fallback para letras plain text** — Quando letras sincronizadas não estão disponíveis

### 🎨 Design Spotify-like
- **Tema dark exclusivo** — Gradientes lilás/roxo (#C77DFF → #240046)
- **Fonte Poppins** — Tipografia moderna e limpa
- **Equalizer animation** — Barras animadas nas músicas tocando
- **UI responsiva** — Otimizada para mobile e desktop

## 🛠️ Tech Stack

| Camada | Tecnologia |
|--------|-----------|
| **Framework** | Flutter (Dart ^3.11.0) |
| **Áudio** | just_audio + just_audio_background + just_audio_media_kit |
| **Fonte de Áudio** | SoundCloud API v2 (autodiscovery de client_id) |
| **Letras** | lrclib.net API (gratuita, sem API key) |
| **Estado** | flutter_bloc (BLoC pattern) + equatable |
| **DI** | get_it (Service Locator) |
| **Persistência** | shared_preferences (músicas curtidas + histórico) |
| **Imagens** | cached_network_image |
| **Fontes** | Google Fonts (Poppins) |
| **Streams** | rxdart (debounce na busca) |

## 📂 Estrutura do Projeto

```
lib/
├── main.dart                           # Entry point
├── app.dart                            # MaterialApp + tema + providers
├── config/
│   ├── di/service_locator.dart         # Injeção de dependências (get_it)
│   └── theme/                          # Tema dark, paleta de cores
├── core/
│   ├── constants/api_constants.dart    # URLs, configurações
│   ├── errors/failures.dart            # Classes de falha tipadas
│   └── utils/duration_formatter.dart   # Formatador de duração
├── data/
│   ├── datasources/                    # SoundCloud API, lrclib.net, SharedPreferences
│   ├── models/                         # TrackModel, LyricsModel
│   └── repositories/                   # Implementações concretas (Music, Lyrics, LikedSongs)
├── domain/
│   ├── entities/                       # Track, Lyrics (entidades puras)
│   └── repositories/                   # Interfaces abstratas
└── presentation/
    ├── blocs/                          # PlayerBloc, SearchBloc, LyricsCubit, HomeCubit, LikedSongsCubit, HistoryCubit
    ├── navigation/main_shell.dart      # MainShell com BottomNavigationBar
    ├── screens/                        # Home, Search, Library, LikedSongs
    └── widgets/                        # MiniPlayer, PlayerBottomSheet, QueueView, EqualizerAnimation, etc.
```

## 🚀 Como Rodar

### Pré-requisitos

- Flutter SDK ^3.11.0
- Dart ^3.11.0
- Android Studio / Xcode (para emuladores mobile)

### Setup

```bash
# Clone o repositório
git clone https://github.com/DiogenesYazan/FireLink-Audio.git
cd FireLink-Audio

# Instale as dependências
flutter pub get

# Execute o app
flutter run
```

### Plataformas Testadas

- ✅ **Windows** — Funcional (testado)
- ✅ **Android** — Funcional (background playback + notificação)
- ⚠️ **Linux** — Suportado via just_audio_media_kit (não testado)
- ⚠️ **macOS** — Suportado via just_audio_media_kit (não testado)
- ⚠️ **iOS** — Suportado (requer configuração adicional de permissões)
- ❌ **Web** — Limitações (sem background playback)

## 🎨 Design System

- **Tema:** Dark Mode exclusivo
- **Paleta:** Gradientes entre Lilás (`#C77DFF`) e Roxo Meia-Noite (`#240046`)
- **Fonte:** Poppins (Google Fonts)
- **Estilo:** Inspirado no Spotify (Home com trending/recentes, Busca, Player em Bottom Sheet, Biblioteca com curtidas)

## ⚠️ Aviso Legal

> **Este projeto é exclusivamente para fins educacionais e de estudo.**
>
> O streaming de conteúdo protegido por direitos autorais pode violar leis locais e os Termos de Serviço do SoundCloud. Este aplicativo **não** se destina ao uso em produção ou distribuição comercial.
>
> Os desenvolvedores **não se responsabilizam** pelo uso indevido desta aplicação. Use por sua conta e risco, respeitando as leis de direitos autorais da sua jurisdição.
>
> Este projeto não é afiliado, associado, autorizado, endossado ou de qualquer forma oficialmente conectado ao SoundCloud, Spotify ou qualquer de suas subsidiárias.

## 📄 Licença

Este projeto está licenciado sob a Licença MIT — veja o arquivo [LICENSE](LICENSE) para detalhes.

## 🙏 Créditos

- [SoundCloud API v2](https://developers.soundcloud.com/docs/api) — Fonte de áudio e metadados (com autodiscovery de client_id)
- [just_audio](https://pub.dev/packages/just_audio) — Player de áudio multiplataforma
- [lrclib.net](https://lrclib.net) — API de letras sincronizadas (gratuita)
- [flutter_bloc](https://pub.dev/packages/flutter_bloc) — Gerenciamento de estado
- [shared_preferences](https://pub.dev/packages/shared_preferences) — Persistência local

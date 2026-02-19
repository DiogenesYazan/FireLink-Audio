# 🔥 FireLink Audio

Um Cliente de Música Open-Source de Alta Fidelidade construído com **Flutter**.

O FireLink Audio traz uma experiência premium de streaming de música para seu desktop e dispositivos móveis, alimentado pelo vasto catálogo do YouTube, mas sem a necessidade de um servidor ou chaves de API. Ele apresenta um design moderno "estilo Spotify" com foco em estética, privacidade e capacidades offline.

![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)
![License](https://img.shields.io/badge/License-MIT-green)

---

## 📸 Prévia

![FireLink Audio Preview](https://i.imgur.com/VNJZZh0.png)
*(Capturas de tela pendentes de atualização com novos recursos)*

---

## ✨ Principais Funcionalidades

### 🎧 Reprodução Avançada
- **Áudio de Alta Fidelidade**: Alimentado por `media_kit` (MPV) para qualidade de som cristalina.
- **Reprodução em Segundo Plano**: Continue ouvindo mesmo com o app fechado ou tela desligada (Android/Windows).
- **Mini Player**: Controles persistentes para acesso rápido.
- **Gerenciamento de Fila**: Visualize e reordene suas próximas músicas.

### 📥 Offline e Cache
- **Cache Inteligente**: Armazena automaticamente faixas tocadas para replay instantâneo.
- **Cache Configurável**: Defina seu limite de cache até **15 GB** nas Configurações.
- **Downloads Offline**: Salve suas faixas favoritas para ouvir offline. Acesse a qualquer momento na seção **Biblioteca > Downloads**.

### 🔍 Descoberta
- **Busca Sem Servidor**: Encontre qualquer música, artista ou álbum diretamente do YouTube.
- **Paradas de Sucesso**: Gráficos dinâmicos baseados em gêneros (Pop, Rock, Hip-Hop, etc.).
- **Filtragem Inteligente**: Filtra automaticamente compilações longas para trazer faixas individuais.

### 📝 Letras e Metadados
- **Letras Sincronizadas**: Letras em tempo real do `lrclib.net` que rolam com a música.
- **Metadados Ricos**: Arte em alta resolução e informações do artista.

### 🎨 UI/UX Moderna
- **Modo Escuro Elegante**: Uma paleta curada de roxos profundos (`#240046`) e lilases vibrantes (`#C77DFF`).
- **Design Responsivo**: Adapta-se lindamente de telas de celular a janelas de desktop.
- **Animações**: Feedbacks visuais sutis, incluindo um equalizador em tempo real.

---

## 🛠️ Tecnologias

Construído com ❤️ usando o melhor do ecossistema Flutter.

| Camada | Tecnologia |
| :--- | :--- |
| **Framework** | Flutter (Dart ^3.11.0) |
| **Motor de Áudio** | `media_kit` (Baseado em MPV) + `media_kit_libs_windows_audio` |
| **Fonte de Dados** | `youtube_explode_dart` (Sem necessidade de API Key) |
| **Gerência de Estado** | `flutter_bloc` (Padrão BLoC) + `equatable` |
| **Injeção de Dependência** | `get_it` |
| **Persistência** | `shared_preferences` + `path_provider` |
| **Letras** | `lrclib.net` REST API |

---

## 🚀 Como Começar

### Pré-requisitos
- **Flutter SDK**: ^3.11.0
- **Dart SDK**: ^3.11.0
- **Windows**: Visual Studio C++ build tools (para target desktop Windows).
- **Android**: Android Studio & SDK.

### Instalação

1. **Clone o repositório**
   ```bash
   git clone https://github.com/DiogenesYazan/FireLink-Audio.git
   cd FireLink-Audio
   ```

2. **Instale as dependências**
   ```bash
   flutter pub get
   ```

3. **Execute o app**
   ```bash
   # Para Windows
   flutter run -d windows

   # Para Android
   flutter run -d android
   ```

---

## 📂 Estrutura do Projeto

```
lib/
├── main.dart                           # Ponto de Entrada da Aplicação
├── app.dart                            # Widget do App & Providers Globais
├── config/                             # Tema, Rotas, Injeção de Dependência
├── core/                               # Constantes, Utils, Extensões
├── data/
│   ├── datasources/                    # Youtube, OfflineManager, CacheManager
│   ├── models/                         # Modelos de Dados (parsing JSON)
│   └── repositories/                   # Implementações de Repositório
├── domain/
│   ├── entities/                       # Entidades de Domínio Puras
│   └── repositories/                   # Interfaces de Repositório
└── presentation/
    ├── blocs/                          # BLoCs (Lógica)
    ├── navigation/                     # Roteamento & Shell
    ├── screens/                        # Telas de UI (Home, Library, Settings)
    └── widgets/                        # Componentes Reutilizáveis
```

---

## ⚠️ Aviso Legal

> **Apenas para Fins Educacionais**
>
> Este projeto foi projetado estritamente para fins educacionais para demonstrar capacidades avançadas do Flutter, padrões de arquitetura e manipulação de áudio. O uso deste software para transmitir conteúdo protegido por direitos autorais pode violar leis locais e os Termos de Serviço da plataforma. Os desenvolvedores não endossam a pirataria e dependem de bibliotecas de terceiros para resolução de conteúdo.

---

## 👨‍💻 Autor

**Diogenes Yuri**  
Confira meu trabalho: [diogenesyuri.works](https://diogenesyuri.works/)

---

## 📄 Licença

Este projeto está licenciado sob a **Licença MIT** — veja o arquivo [LICENSE](LICENSE) para detalhes.

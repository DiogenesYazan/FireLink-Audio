/// Classes de falha tipadas para tratamento de erros no app.
sealed class Failure {
  const Failure(this.message);
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// Falha ao buscar tracks no SoundCloud.
class SearchFailure extends Failure {
  const SearchFailure([super.message = 'Erro ao buscar músicas.']);
}

/// Falha ao extrair stream de áudio.
class StreamExtractionFailure extends Failure {
  const StreamExtractionFailure([
    super.message = 'Erro ao extrair stream de áudio.',
  ]);
}

/// Falha ao buscar letras.
class LyricsFailure extends Failure {
  const LyricsFailure([super.message = 'Erro ao buscar letras.']);
}

/// Falha de conectividade.
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Sem conexão com a internet.']);
}

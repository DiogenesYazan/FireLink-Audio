import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/datasources/playlist_manager.dart';
import '../../../domain/entities/track.dart';

/// Cubit para gerenciar playlists locais.
class PlaylistCubit extends Cubit<PlaylistState> {
  PlaylistCubit({required PlaylistManager playlistManager})
    : _manager = playlistManager,
      super(const PlaylistState()) {
    loadPlaylists();
  }

  final PlaylistManager _manager;

  /// Carrega a lista de playlists.
  Future<void> loadPlaylists() async {
    emit(state.copyWith(status: PlaylistStatus.loading));
    try {
      final names = await _manager.getPlaylistNames();
      emit(state.copyWith(status: PlaylistStatus.loaded, playlistNames: names));
    } catch (e) {
      debugPrint('PlaylistCubit: Erro ao carregar playlists: $e');
      emit(state.copyWith(status: PlaylistStatus.error));
    }
  }

  /// Cria uma nova playlist.
  Future<void> createPlaylist(String name) async {
    await _manager.createPlaylist(name);
    await loadPlaylists();
  }

  /// Adiciona uma track a uma playlist.
  Future<void> addTrackToPlaylist(String playlistName, Track track) async {
    await _manager.addTrack(playlistName, track);
    // Se estamos visualizando esta playlist, recarrega tracks.
    if (state.currentPlaylist == playlistName) {
      await loadPlaylistTracks(playlistName);
    }
  }

  /// Remove uma track de uma playlist.
  Future<void> removeTrack(String playlistName, String trackId) async {
    await _manager.removeTrack(playlistName, trackId);
    if (state.currentPlaylist == playlistName) {
      await loadPlaylistTracks(playlistName);
    }
  }

  /// Carrega tracks de uma playlist específica.
  Future<void> loadPlaylistTracks(String name) async {
    try {
      final rawTracks = await _manager.getPlaylistTracks(name);
      final tracks = rawTracks
          .map(
            (t) => Track(
              trackId: t['trackId'] as String,
              title: t['title'] as String,
              artist: t['artist'] as String,
              thumbnailUrl: t['thumbnailUrl'] as String,
              duration: Duration(milliseconds: t['durationMs'] as int? ?? 0),
            ),
          )
          .toList();
      emit(state.copyWith(currentPlaylist: name, currentTracks: tracks));
    } catch (e) {
      debugPrint('PlaylistCubit: Erro ao carregar tracks: $e');
    }
  }

  /// Deleta uma playlist.
  Future<void> deletePlaylist(String name) async {
    await _manager.deletePlaylist(name);
    await loadPlaylists();
  }

  /// Renomeia uma playlist.
  Future<void> renamePlaylist(String oldName, String newName) async {
    await _manager.renamePlaylist(oldName, newName);
    await loadPlaylists();
  }
}

enum PlaylistStatus { initial, loading, loaded, error }

class PlaylistState extends Equatable {
  const PlaylistState({
    this.status = PlaylistStatus.initial,
    this.playlistNames = const [],
    this.currentPlaylist,
    this.currentTracks = const [],
  });

  final PlaylistStatus status;
  final List<String> playlistNames;
  final String? currentPlaylist;
  final List<Track> currentTracks;

  PlaylistState copyWith({
    PlaylistStatus? status,
    List<String>? playlistNames,
    String? currentPlaylist,
    List<Track>? currentTracks,
  }) {
    return PlaylistState(
      status: status ?? this.status,
      playlistNames: playlistNames ?? this.playlistNames,
      currentPlaylist: currentPlaylist ?? this.currentPlaylist,
      currentTracks: currentTracks ?? this.currentTracks,
    );
  }

  @override
  List<Object?> get props => [
    status,
    playlistNames,
    currentPlaylist,
    currentTracks,
  ];
}

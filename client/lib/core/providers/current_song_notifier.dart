import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/home/models/song_model.dart';
import '../../features/home/repositories/home_local_repository.dart';

part 'current_song_notifier.g.dart';

@riverpod
class CurrentSongNotifier extends _$CurrentSongNotifier {
  AudioPlayer? audioPlayer;
  bool isPlaying = false;
  late HomeLocalRepository _homeLocalRepository;

  @override
  SongModel? build() {
    _homeLocalRepository = ref.watch(homeLocalRepositoryProvider);
    return null;
  }

  void updateSong(SongModel song) async {
    await audioPlayer?.stop();
    await audioPlayer?.dispose();
    audioPlayer = AudioPlayer();
    final audioSource = AudioSource.uri(
      Uri.parse(song.song_url),
      tag: MediaItem(
        id: song.id,
        title: song.song_name,
        artist: song.artist,
        artUri: Uri.parse(song.song_url),
      ),
    );

    await audioPlayer!.setAudioSource(audioSource);

    audioPlayer!.playerStateStream.listen(
      (state) {
        if (state.processingState == ProcessingState.completed) {
          audioPlayer!.seek(Duration.zero);
          audioPlayer!.pause();
          isPlaying = false;

          this.state = this.state?.copyWith(
                color_hex_code: this.state?.color_hex_code,
              );
        }
      },
    );

    _homeLocalRepository.uploadLocalSong(song);
    audioPlayer!.play();
    isPlaying = true;
    state = song;
  }

  void playPause() {
    if (isPlaying) {
      audioPlayer?.pause();
    } else {
      audioPlayer?.play();
    }
    isPlaying = !isPlaying;
    state = state?.copyWith(
        color_hex_code: state
            ?.color_hex_code); // trick to riverpod that something changed and make the listeners rebuild
  }

  void seek(double val) {
    audioPlayer!.seek(
      Duration(
        milliseconds: (val * audioPlayer!.duration!.inMilliseconds).toInt(),
      ),
    );
  }
}

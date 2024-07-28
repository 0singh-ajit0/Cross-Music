import 'dart:io';
import 'dart:ui';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/providers/current_user_notifier.dart';
import '../../../core/utils.dart';
import '../models/fav_song_model.dart';
import '../models/song_model.dart';
import '../repositories/home_local_repository.dart';
import '../repositories/home_repository.dart';

part 'home_viewmodel.g.dart';

@riverpod
Future<List<SongModel>> getAllSongs(GetAllSongsRef ref) async {
  final token =
      ref.watch(currentUserNotifierProvider.select((user) => user!.token));
  final res = await ref.watch(homeRepositoryProvider).getAllSongs(token: token);

  return res.fold(
    (l) => throw l.message,
    (r) => r,
  );
}

@riverpod
Future<List<SongModel>> getAllFavSongs(GetAllFavSongsRef ref) async {
  final token =
      ref.watch(currentUserNotifierProvider.select((user) => user!.token));
  final res =
      await ref.watch(homeRepositoryProvider).getAllFavSongs(token: token);

  return res.fold(
    (l) => throw l.message,
    (r) => r,
  );
}

@riverpod
class HomeViewModel extends _$HomeViewModel {
  late HomeRepository _homeRepository;
  late HomeLocalRepository _homeLocalRepository;

  @override
  AsyncValue? build() {
    _homeRepository = ref.watch(homeRepositoryProvider);
    _homeLocalRepository = ref.watch(homeLocalRepositoryProvider);
    return null;
  }

  Future<void> initHive() async {
    await _homeLocalRepository.init();
  }

  Future<void> uploadSong({
    required File audioFile,
    required File thumbnailFile,
    required String songName,
    required String artist,
    required Color color,
  }) async {
    state = const AsyncValue.loading();
    final res = await _homeRepository.uploadSong(
      audioFile: audioFile,
      thumbnailFile: thumbnailFile,
      songName: songName,
      artist: artist,
      colorHexCode: colorToHex(color),
      token: ref.read(currentUserNotifierProvider)!.token,
    );

    res.fold(
      (l) => state = AsyncValue.error(l.message, StackTrace.current),
      (r) => state = AsyncValue.data(r),
    );
  }

  List<SongModel> getRecentlyPlayedSongs() {
    return _homeLocalRepository.loadSongs();
  }

  Future<void> favSong({
    required String songId,
  }) async {
    state = const AsyncValue.loading();
    final res = await _homeRepository.favSong(
      token: ref.read(currentUserNotifierProvider)!.token,
      songId: songId,
    );

    final val = res.fold(
      (l) => state = AsyncValue.error(l.message, StackTrace.current),
      (isFavorited) {
        final userNotifier = ref.read(currentUserNotifierProvider.notifier);
        if (isFavorited) {
          userNotifier.addUser(
            ref.read(currentUserNotifierProvider)!.copyWith(
              favorites: [
                ...ref.read(currentUserNotifierProvider)!.favorites,
                FavSongModel(
                  id: "id",
                  song_id: songId,
                  user_id: "",
                ),
              ],
            ),
          );
        } else {
          userNotifier.addUser(
            ref.read(currentUserNotifierProvider)!.copyWith(
                  favorites: ref
                      .read(currentUserNotifierProvider)!
                      .favorites
                      .where(
                        (fav) => fav.song_id != songId,
                      )
                      .toList(),
                ),
          );
        }
        ref.invalidate(getAllFavSongsProvider);
        return state = AsyncValue.data(isFavorited);
      },
    );
  }
}

import 'package:hive/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/song_model.dart';

part 'home_local_repository.g.dart';

@Riverpod(keepAlive: true)
HomeLocalRepository homeLocalRepository(HomeLocalRepositoryRef ref) {
  return HomeLocalRepository();
}

class HomeLocalRepository {
  late final Box box;

  Future<void> init() async {
    box = await Hive.openBox("songs");
  }

  void uploadLocalSong(SongModel song) {
    box.put(song.id, song.toJson());
  }

  List<SongModel> loadSongs() {
    List<SongModel> songs = [];
    for (final key in box.keys) {
      songs.add(SongModel.fromJson(box.get(key)));
    }
    return songs;
  }
}

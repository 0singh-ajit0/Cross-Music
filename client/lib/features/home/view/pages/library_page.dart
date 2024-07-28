import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/current_song_notifier.dart';
import '../../../../core/theme/app_pallete.dart';
import '../../../../core/widgets/loader.dart';
import '../../viewmodel/home_viewmodel.dart';
import 'upload_song_page.dart';

class LibraryPage extends ConsumerWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(getAllFavSongsProvider).when(
          data: (songs) {
            return ListView.builder(
              itemCount: songs.length + 1,
              itemBuilder: (context, index) {
                if (index == songs.length) {
                  return ListTile(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const UploadSongPage(),
                        ),
                      );
                    },
                    leading: const CircleAvatar(
                      radius: 35,
                      backgroundColor: Pallete.backgroundColor,
                      child: Icon(CupertinoIcons.plus),
                    ),
                    title: const Text(
                      "Upload new song",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 16,
                    ),
                  );
                }
                final song = songs[index];

                return ListTile(
                  onTap: () {
                    ref
                        .read(currentSongNotifierProvider.notifier)
                        .updateSong(song);
                  },
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(song.thumbnail_url),
                    radius: 35,
                    backgroundColor: Pallete.backgroundColor,
                  ),
                  title: Text(
                    song.song_name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  subtitle: Text(
                    song.artist,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              },
            );
          },
          error: (error, stackTrace) {
            return Center(
              child: Text(error.toString()),
            );
          },
          loading: () => const Loader(),
        );
  }
}

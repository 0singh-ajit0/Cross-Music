import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/current_song_notifier.dart';
import '../../../../core/providers/current_user_notifier.dart';
import '../../../../core/theme/app_pallete.dart';
import '../../../../core/utils.dart';
import '../../viewmodel/home_viewmodel.dart';

class MusicPlayer extends ConsumerWidget {
  const MusicPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSong = ref.watch(currentSongNotifierProvider);
    final songNotifier = ref.read(currentSongNotifierProvider.notifier);
    final userFavorites = ref.watch(
      currentUserNotifierProvider.select(
        (value) => value!.favorites,
      ),
    );

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            hexToColor(currentSong!.color_hex_code),
            const Color(0xff121212),
          ],
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Scaffold(
        backgroundColor: Pallete.transparentColor,
        appBar: AppBar(
          backgroundColor: Pallete.transparentColor,
          leading: Transform.translate(
            offset: const Offset(-15, 0),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Image.asset(
                  "assets/images/pull-down-arrow.png",
                  color: Pallete.whiteColor,
                ),
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 30.0),
                child: Hero(
                  tag: "music-image",
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(currentSong.thumbnail_url),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentSong.song_name,
                              style: const TextStyle(
                                color: Pallete.whiteColor,
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                overflow: TextOverflow.ellipsis,
                              ),
                              maxLines: 1,
                            ),
                            Text(
                              currentSong.artist,
                              style: const TextStyle(
                                color: Pallete.subtitleText,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                overflow: TextOverflow.ellipsis,
                              ),
                              maxLines: 1,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          await ref
                              .read(homeViewModelProvider.notifier)
                              .favSong(songId: currentSong.id);
                        },
                        icon: Icon(
                          userFavorites
                                  .where(
                                    (fav) => fav.song_id == currentSong.id,
                                  )
                                  .isNotEmpty
                              ? CupertinoIcons.heart_fill
                              : CupertinoIcons.heart,
                        ),
                        color: Pallete.whiteColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  StreamBuilder(
                    stream: songNotifier.audioPlayer!.positionStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox();
                      }

                      final position = snapshot.data;
                      final duration = songNotifier.audioPlayer!.duration;
                      double sliderValue = 0.0;

                      if (position != null && duration != null) {
                        sliderValue =
                            position.inMilliseconds / duration.inMilliseconds;
                      }

                      final secondsElapsed =
                          position!.inSeconds - (position.inMinutes * 60);
                      final secondsTotal =
                          duration!.inSeconds - (duration.inMinutes * 60);

                      return Column(
                        children: [
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: Pallete.whiteColor,
                              inactiveTrackColor:
                                  Pallete.whiteColor.withOpacity(0.117),
                              thumbColor: Pallete.whiteColor,
                              trackHeight: 4,
                              overlayShape: SliderComponentShape.noOverlay,
                            ),
                            child: Slider(
                              min: 0,
                              max: 1,
                              value: sliderValue,
                              onChanged: (value) {
                                sliderValue = value;
                              },
                              onChangeEnd: (value) {
                                songNotifier.seek(value);
                              },
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "${position.inMinutes}:${secondsElapsed < 10 ? '0$secondsElapsed' : secondsElapsed}",
                                style: const TextStyle(
                                  color: Pallete.subtitleText,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                              Text(
                                "${duration.inMinutes}:${secondsTotal < 10 ? '0$secondsTotal' : secondsTotal}",
                                style: const TextStyle(
                                  color: Pallete.subtitleText,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Image.asset(
                          "assets/images/shuffle.png",
                          color: Pallete.whiteColor,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Image.asset(
                          "assets/images/previus-song.png",
                          color: Pallete.whiteColor,
                        ),
                      ),
                      IconButton(
                        onPressed: songNotifier.playPause,
                        icon: Icon(
                          songNotifier.isPlaying
                              ? CupertinoIcons.pause_circle_fill
                              : CupertinoIcons.play_circle_fill,
                        ),
                        iconSize: 80,
                        color: Pallete.whiteColor,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Image.asset(
                          "assets/images/next-song.png",
                          color: Pallete.whiteColor,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Image.asset(
                          "assets/images/repeat.png",
                          color: Pallete.whiteColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Image.asset(
                          "assets/images/connect-device.png",
                          color: Pallete.whiteColor,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Image.asset(
                          "assets/images/playlist.png",
                          color: Pallete.whiteColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

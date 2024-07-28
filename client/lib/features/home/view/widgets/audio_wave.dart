import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_pallete.dart';

class AudioWave extends StatefulWidget {
  final String path;
  const AudioWave({
    super.key,
    required this.path,
  });

  @override
  State<AudioWave> createState() => _AudioWaveState();
}

class _AudioWaveState extends State<AudioWave> {
  late final PlayerController _playerController;

  @override
  void initState() {
    super.initState();
    _playerController = PlayerController();
    initPlayer();
  }

  void initPlayer() async {
    _playerController.preparePlayer(path: widget.path);
  }

  Future<void> playAndPause() async {
    if (!_playerController.playerState.isPlaying) {
      await _playerController.startPlayer(finishMode: FinishMode.stop);
    } else if (!_playerController.playerState.isPaused) {
      await _playerController.pausePlayer();
    }
    setState(() {});
  }

  @override
  void dispose() {
    _playerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: playAndPause,
          icon: Icon(
            _playerController.playerState.isPlaying
                ? CupertinoIcons.pause_solid
                : CupertinoIcons.play_arrow_solid,
          ),
        ),
        Expanded(
          child: AudioFileWaveforms(
            size: const Size(double.infinity, 100),
            playerController: _playerController,
            playerWaveStyle: const PlayerWaveStyle(
              fixedWaveColor: Pallete.borderColor,
              liveWaveColor: Pallete.gradient2,
              spacing: 6,
            ),
          ),
        ),
      ],
    );
  }
}

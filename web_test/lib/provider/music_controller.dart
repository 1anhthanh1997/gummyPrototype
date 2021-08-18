import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:web_test/config/id_config.dart';

class MusicController {
  AudioCache audioCache = new AudioCache();
  AudioPlayer backgroundMusicPlayer;
  AudioPlayer winSoundPlayer;
  AudioPlayer tutorialPlayer;
  AudioPlayer objectNamePlayer;

  void playAudioBackground(String url) async {
    if (backgroundMusicPlayer != null) {
      stopBackgroundMusic();
    }
    print('Play Music');
    backgroundMusicPlayer = await audioCache.loop(url);
  }

  void stopBackgroundMusic() async {
    if (backgroundMusicPlayer == null) return;
    await backgroundMusicPlayer.release();
  }

  void playItemSoundPlayer(String url) async {
    if (url == WIN_STINGER || url == WIN_STINGER_2 || url == WIN_STINGER_3) {
      if (winSoundPlayer != null) {
        stopWinSound();
      }
      winSoundPlayer = await audioCache.play(url, mode: PlayerMode.LOW_LATENCY);
    } else {
      AudioPlayer gameItemSoundPlayer;
      if (gameItemSoundPlayer != null) {
        stopGameItemSound(gameItemSoundPlayer);
      }
      gameItemSoundPlayer = await audioCache
          .play(
        url,
        mode: PlayerMode.LOW_LATENCY,
      )
          .whenComplete(() {
        stopGameItemSound(gameItemSoundPlayer);
      });
    }
  }

  void playObjectNamePlayer(String url) async {
    print(url);
    if (objectNamePlayer != null) {
      stopGameItemSound(objectNamePlayer);
    }
    print(url);
    objectNamePlayer = await audioCache.play(
      url,
      mode: PlayerMode.LOW_LATENCY,
    );
  }

  void stopObjectNameSound(AudioPlayer objectNamePlayer) async {
    if (objectNamePlayer == null) return;
    await objectNamePlayer.release();
  }

  void stopGameItemSound(AudioPlayer gameItemSoundPlayer) async {
    if (gameItemSoundPlayer == null) return;
    await gameItemSoundPlayer.release();
  }

  void stopWinSound() async {
    if (winSoundPlayer == null) return;
    await winSoundPlayer.release();
  }

  void playTutorialPlayer(String url) async {
    if (tutorialPlayer != null) {
      stopTutorial();
    }
    tutorialPlayer = await audioCache.play(url);
    tutorialPlayer.setPlaybackRate(playbackRate: 0.8);
  }

  void stopTutorial() async {
    if (tutorialPlayer == null) return;
    await tutorialPlayer.release();
  }
}

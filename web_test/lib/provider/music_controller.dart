import 'package:audioplayers/audioplayers.dart';

class MusicController{
  AudioCache audioCache = new AudioCache();
  AudioPlayer backgroundMusicPlayer;
  
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

}
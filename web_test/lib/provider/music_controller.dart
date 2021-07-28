import 'package:audioplayers/audioplayers.dart';
import 'package:web_test/config/id_config.dart';

class MusicController{
  AudioCache audioCache = new AudioCache();
  AudioPlayer backgroundMusicPlayer;
  AudioPlayer gameItemSoundPlayer;
  AudioPlayer winSoundPlayer;
  AudioPlayer tutorialPlayer;

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

  void playItemSoundPlayer(String url)async{
    if(url==WIN_STINGER||url==WIN_STINGER_2||url==WIN_STINGER_3){
      if(winSoundPlayer!=null){
        stopWinSound();
      }
      winSoundPlayer=await audioCache.play(url,mode: PlayerMode.LOW_LATENCY);
    }else{
      if(gameItemSoundPlayer!=null){
        stopGameItemSound();
      }
      gameItemSoundPlayer=await audioCache.play(url);
    }
  }

  void stopGameItemSound()async{
    if(gameItemSoundPlayer==null)return;
    await gameItemSoundPlayer.release();
  }

  void stopWinSound()async{
    if(winSoundPlayer==null)return;
    await winSoundPlayer.release();
  }

  void playTutorialPlayer(String url)async{
    if(tutorialPlayer!=null){
      stopTutorial();
    }
    tutorialPlayer=await audioCache.play(url);
  }

  void stopTutorial()async{
    if(gameItemSoundPlayer==null)return;
    await gameItemSoundPlayer.release();
  }

}
import 'dart:io';

import 'package:just_audio/just_audio.dart';
import 'package:web_test/config/id_config.dart';

class SecondMusicController {
  AudioPlayer objectNamePlayer;  

  void playObjectNamePlayer(String url) async {
    print(url);
    if (objectNamePlayer != null) {
      stopObjectNameSound(objectNamePlayer);
    }
    await objectNamePlayer.setFilePath(url);
    await objectNamePlayer.load();
   
  }

  void stopObjectNameSound(AudioPlayer objectNamePlayer) async {
    if (objectNamePlayer == null) return;
    await objectNamePlayer.stop();
  }

 
}

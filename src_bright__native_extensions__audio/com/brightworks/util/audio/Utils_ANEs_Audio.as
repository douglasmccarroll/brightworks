/*
 Copyright 2018 Brightworks, Inc.

 This file is part of Language Mentor.

 Language Mentor is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 Language Mentor is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with Language Mentor.  If not, see <http://www.gnu.org/licenses/>.

 */
package com.brightworks.util.audio {

import com.brightworks.constant.Constant_Private;
import com.brightworks.util.Log;
import com.distriqt.extension.mediaplayer.MediaInfo;
import com.distriqt.extension.mediaplayer.MediaPlayer;
import com.distriqt.extension.mediaplayer.audio.AudioPlayer;
import com.distriqt.extension.mediaplayer.audio.AudioPlayerOptions;
import com.distriqt.extension.mediaplayer.events.AudioPlayerEvent;
import com.distriqt.extension.mediaplayer.events.MediaErrorEvent;
import com.distriqt.extension.mediaplayer.events.RemoteCommandCenterEvent;
import com.langcollab.languagementor.constant.Constant_AppConfiguration;

import flash.filesystem.File;

public class Utils_ANEs_Audio {
   private static var _appPauseFunction:Function;
   private static var _audioCallback:Function;
   private static var _audioCurrentFileUrl:String;
   private static var _audioPlayer_Chirps:com.distriqt.extension.mediaplayer.audio.AudioPlayer;
   private static var _audioPlayer_Click:com.distriqt.extension.mediaplayer.audio.AudioPlayer;
   private static var _audioPlayer_Failure:com.distriqt.extension.mediaplayer.audio.AudioPlayer;
   private static var _audioPlayer_File_Background:com.distriqt.extension.mediaplayer.audio.AudioPlayer;
   private static var _audioPlayer_File_Standard:com.distriqt.extension.mediaplayer.audio.AudioPlayer;
   private static var _audioPlayer_Log_Error:com.distriqt.extension.mediaplayer.audio.AudioPlayer;
   private static var _audioPlayer_Log_Fatal:com.distriqt.extension.mediaplayer.audio.AudioPlayer;
   private static var _audioPlayer_Log_Warn:com.distriqt.extension.mediaplayer.audio.AudioPlayer;
   private static var _isMediaPlayerExtensionInitialized:Boolean;

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   //
   //          Public Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   public static function getCurrentFileUrl():String {
      return _audioCurrentFileUrl;
   }

   public static function initialize():void {
      if (_isMediaPlayerExtensionInitialized)
         return;
      try {
         MediaPlayer.init(Constant_AppConfiguration.ANE_KEY__DISTRIQT);
         MediaPlayer.service.remoteCommandCenter.registerForControlEvents();
         MediaPlayer.service.remoteCommandCenter.addEventListener(RemoteCommandCenterEvent.PAUSE, onMediaPlayerUserInput_Pause);
         MediaPlayer.service.remoteCommandCenter.addEventListener(RemoteCommandCenterEvent.PLAY, onMediaPlayerUserInput_Play);
         initializeReusableAudioPlayers();
         initializeAudioPlayer_File_Background();
         _isMediaPlayerExtensionInitialized = true;
      } catch (e:Error) {
         Log.error("Utils_ANEs_Audio.initializePlayersIfNeeded(): " + e.message);
      }
   }

   public static function playChirps():void {  // 6 chirps in 3 seconds - for experimenting with audio
      _audioPlayer_Chirps.play();
   }

   public static function playClick():void {
      _audioPlayer_Click.play();
   }

   public static function playFailureSound():void {
      _audioPlayer_Failure.play();
   }

   public static function playFile_Background(file:File, audioCallback:Function, volume:Number = 1.0, title:String = "", artist:String = ""):void {
      _audioCallback = audioCallback;
      _audioPlayer_File_Background.setVolume(volume);
      var info:MediaInfo = new MediaInfo();
      info.setTitle(title);
      info.setArtist(artist);
      MediaPlayer.service.remoteCommandCenter.setNowPlayingInfo(info);
      _audioPlayer_File_Background.addEventListener(AudioPlayerEvent.COMPLETE, onAudioPlayerComplete);
      _audioPlayer_File_Background.addEventListener(MediaErrorEvent.ERROR, onAudioPlayerError);
      _audioPlayer_File_Background.addEventListener(AudioPlayerEvent.INTERRUPTION_START, onAudioPlayerInterruptionStart);
      _audioPlayer_File_Background.addEventListener(AudioPlayerEvent.LOADED, onAudioPlayerLoaded);
      _audioPlayer_File_Background.loadFile(file);
      _audioCurrentFileUrl = file.url;
   }

   public static function playFile_Standard(file:File, audioCallback:Function, volume:Number = 1.0, title:String = "", artist:String = ""):void {
      ///// This may be used, if problems with microphone use can't be solved - we'll switch to playing file audio in foreground if/when mic is used ??
   }

   public static function playLogToneError():void {
      _audioPlayer_Log_Error.play();
   }

   public static function playLogToneFatal():void {
      _audioPlayer_Log_Fatal.play();
   }

   public static function playLogToneWarn():void {
      _audioPlayer_Log_Warn.play();
   }

   public static function setAppPauseFunction(f:Function):void {
      _appPauseFunction = f;
   }

   public static function stopMediaPlayer():void {
      stopFileAudioPlayers();
      _audioCurrentFileUrl = null;
   }

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   //
   //          Private Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -   '

   private static function initializeAudioPlayer_Reusable(path:String):com.distriqt.extension.mediaplayer.audio.AudioPlayer {
      var player:com.distriqt.extension.mediaplayer.audio.AudioPlayer
      try {
         var file:File = File.applicationDirectory.resolvePath(path);
         if (file.exists) {
            player = MediaPlayer.service.createAudioPlayer();
            player.loadFile(file);
         }
         else {
            Log.error("Utils_ANEs_Audio.initializeAudioPlayer_Reusable() - file does not exist - path: " + path);
         }
      } catch (e:Error) {
         Log.error("Utils_ANEs.initializeAudioPlayer_Reusable(): " + e.message);
      }
      return player;
   }

   private static function initializeAudioPlayer_File_Background():void {
      stopFileAudioPlayers();
      try {
         var options:AudioPlayerOptions = new AudioPlayerOptions();
         options.enableBackgroundAudio(true);
         _audioPlayer_File_Background = MediaPlayer.service.createAudioPlayer(options);
      } catch (e:Error) {
         Log.error("Utils_ANEs.initializeAudioPlayer_File_Background(): " + e.message);
      }
   }

   private static function initializeAudioPlayer_File_Standard(title:String, artist:String):void {
      stopFileAudioPlayers();
      try {
         _audioPlayer_File_Standard = MediaPlayer.service.createAudioPlayer();

         ///// These should get set each time a file audio is played - as they are removed each time a file audio is stopped
         _audioPlayer_File_Standard.addEventListener(AudioPlayerEvent.COMPLETE, onAudioPlayerComplete);
         _audioPlayer_File_Standard.addEventListener(MediaErrorEvent.ERROR, onAudioPlayerError);
         _audioPlayer_File_Standard.addEventListener(AudioPlayerEvent.LOADED, onAudioPlayerLoaded);
      } catch (e:Error) {
         Log.error("Utils_ANEs.initializeAudioPlayer_File_Standard(): " + e.message);
      }
   }

   private static function initializeReusableAudioPlayers():void {  // 6 chirps in 3 seconds - for experimenting with audio
      _audioPlayer_Chirps = initializeAudioPlayer_Reusable("assets/audio/chirps.mp3");
      _audioPlayer_Click = initializeAudioPlayer_Reusable("assets/audio/click.mp3");
      _audioPlayer_Failure = initializeAudioPlayer_Reusable("assets/audio/buzz_thud.mp3");
      _audioPlayer_Log_Error = initializeAudioPlayer_Reusable("assets/audio/logTone_Error.mp3");
      _audioPlayer_Log_Fatal = initializeAudioPlayer_Reusable("assets/audio/logTone_Fatal.mp3");
      _audioPlayer_Log_Warn = initializeAudioPlayer_Reusable("assets/audio/logTone_Warn.mp3");
   }

   private static function onAudioPlayerComplete(e:AudioPlayerEvent):void {
      stopFileAudioPlayers();
      _audioCurrentFileUrl = null;
      if (_audioCallback is Function) {
         _audioCallback(e);
      }
   }

   private static function onAudioPlayerError(e:MediaErrorEvent):void {
      stopFileAudioPlayers();
      _audioCurrentFileUrl = null;
      if (_audioCallback is Function) {
         _audioCallback(e);
      }
   }

   private static function onAudioPlayerInterruptionStart(e:AudioPlayerEvent):void {
      if (_appPauseFunction is Function)
            _appPauseFunction();
   }

   private static function onAudioPlayerLoaded(e:AudioPlayerEvent):void {
      com.distriqt.extension.mediaplayer.audio.AudioPlayer(e.currentTarget).play();
   }

   private static function onMediaPlayerUserInput_Pause(e:RemoteCommandCenterEvent):void {
      if (!(_audioCallback is Function))
         return;
      _audioCallback(e);
   }

   private static function onMediaPlayerUserInput_Play(e:RemoteCommandCenterEvent):void {
      if (!(_audioCallback is Function))
         return;
      _audioCallback(e);
   }

   private static function stopFileAudioPlayer(player:com.distriqt.extension.mediaplayer.audio.AudioPlayer):void {
      player.removeEventListener(AudioPlayerEvent.COMPLETE, onAudioPlayerComplete);
      player.removeEventListener(MediaErrorEvent.ERROR, onAudioPlayerError);
      player.removeEventListener(AudioPlayerEvent.INTERRUPTION_START, onAudioPlayerInterruptionStart);
      player.removeEventListener(AudioPlayerEvent.LOADED, onAudioPlayerLoaded);
      player.stop();
   }

   private static function stopFileAudioPlayers():void {
      if (_audioPlayer_File_Background) {
         stopFileAudioPlayer(_audioPlayer_File_Background);
      }
      if (_audioPlayer_File_Standard) {
         stopFileAudioPlayer(_audioPlayer_File_Standard);
      }
   }


}
}



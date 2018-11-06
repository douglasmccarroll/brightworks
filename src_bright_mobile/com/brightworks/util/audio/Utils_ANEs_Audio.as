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
   private static var _audioCallback:Function;
   private static var _audioCurrentFileUrl:String;
   private static var _audioPlayer:com.distriqt.extension.mediaplayer.audio.AudioPlayer;
   private static var _isMediaPlayerExtensionInitialized:Boolean;

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   //
   //          Public Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   public static function getCurrentFileUrl():String {
      return _audioCurrentFileUrl;
   }

   public static function isMediaPlayerSupported():Boolean {
      initializeMediaPlayerIfNeeded();
      return MediaPlayer.isSupported;
   }

   public static function playFile(file:File, audioCallback:Function, volume:Number = 1.0, title:String = "", artist:String = ""):void {
      _audioCallback = audioCallback;
      initializeAudioPlayer(title, artist);
      _audioPlayer.setVolume(volume);
      _audioPlayer.loadFile(file);
      _audioCurrentFileUrl = file.url;
   }

   public static function stopMediaPlayer():void {
      disposeAudioPlayer();
   }

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   //
   //          Private Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   private static function disposeAudioPlayer():void {
      if (_audioPlayer) {
         _audioPlayer.removeEventListener(AudioPlayerEvent.COMPLETE, onAudioPlayerComplete);
         _audioPlayer.removeEventListener(MediaErrorEvent.ERROR, onAudioPlayerError);
         _audioPlayer.removeEventListener(AudioPlayerEvent.LOADED, onAudioPlayerLoaded);
         _audioPlayer.removeEventListener(AudioPlayerEvent.LOADING, onAudioPlayerLoading);
         _audioPlayer.stop();
         _audioPlayer.destroy();
         _audioPlayer = null;
      }
      _audioCurrentFileUrl = null;
   }

   private static function initializeAudioPlayer(title:String, artist:String):void {
      initializeMediaPlayerIfNeeded();
      disposeAudioPlayer();
      try {
         var options:AudioPlayerOptions = new AudioPlayerOptions();
         options.enableBackgroundAudio(true);
         _audioPlayer = MediaPlayer.service.createAudioPlayer(options);
         var info:MediaInfo = new MediaInfo();
         info.setTitle(title);
         info.setArtist(artist);
         MediaPlayer.service.remoteCommandCenter.setNowPlayingInfo(info);
         _audioPlayer.addEventListener(AudioPlayerEvent.COMPLETE, onAudioPlayerComplete);
         _audioPlayer.addEventListener(MediaErrorEvent.ERROR, onAudioPlayerError);
         _audioPlayer.addEventListener(AudioPlayerEvent.LOADED, onAudioPlayerLoaded);
         _audioPlayer.addEventListener(AudioPlayerEvent.LOADING, onAudioPlayerLoading);
      } catch (e:Error) {
         Log.error("Utils_ANEs.initializeAudioPlayer(): " + e.message);
      }
   }

   private static function initializeMediaPlayerIfNeeded():void {
      if (_isMediaPlayerExtensionInitialized)
         return;
      try {
         MediaPlayer.init(Constant_AppConfiguration.APP_ID);
         MediaPlayer.service.remoteCommandCenter.registerForControlEvents();
         MediaPlayer.service.remoteCommandCenter.addEventListener(RemoteCommandCenterEvent.PAUSE, onMediaPlayerUserInput_Pause);
         MediaPlayer.service.remoteCommandCenter.addEventListener(RemoteCommandCenterEvent.PLAY, onMediaPlayerUserInput_Play);
         _isMediaPlayerExtensionInitialized = true;
      } catch (e:Error) {
         Log.error("Utils_ANEs_Audio.initializeMediaPlayerIfNeeded(): " + e.message);
      }
   }

   private static function onAudioPlayerComplete(e:AudioPlayerEvent):void {
      if (!(_audioCallback is Function))
         return;
      disposeAudioPlayer();
      _audioCurrentFileUrl = null;
      _audioCallback(e);
   }

   private static function onAudioPlayerError(e:MediaErrorEvent):void {
      if (!(_audioCallback is Function))
         return;
      disposeAudioPlayer();
      _audioCallback(e);
   }

   private static function onAudioPlayerLoaded(e:AudioPlayerEvent):void {
      _audioPlayer.play();
   }

   private static function onAudioPlayerLoading(e:AudioPlayerEvent):void {
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

}
}



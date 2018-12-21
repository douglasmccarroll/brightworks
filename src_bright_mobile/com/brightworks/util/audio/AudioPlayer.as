/*
 *  Copyright 2018 Brightworks, Inc.
 *
 *  This file is part of Language Mentor.
 *
 *  Language Mentor is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  Language Mentor is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with Language Mentor.  If not, see <http://www.gnu.org/licenses/>.
 *
 */
package com.brightworks.util.audio {
import com.brightworks.event.Event_Audio;
import com.brightworks.interfaces.IManagedSingleton;
import com.brightworks.util.Log;
import com.brightworks.util.Utils_ANEs;
import com.brightworks.util.singleton.SingletonManager;
import com.distriqt.extension.mediaplayer.events.AudioPlayerEvent;
import com.distriqt.extension.mediaplayer.events.MediaErrorEvent;
import com.distriqt.extension.mediaplayer.events.RemoteCommandCenterEvent;
import com.langcollab.languagementor.constant.Constant_LangMentor_Misc;
import com.langcollab.languagementor.model.MainModel;
import com.langcollab.languagementor.model.currentlessons.CurrentLessons;
import com.langcollab.languagementor.util.Utils_LangCollab;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.utils.ByteArray;

public class AudioPlayer extends EventDispatcher implements IManagedSingleton {
   private static var _instance:AudioPlayer;

   private var _currentLessons:CurrentLessons;
   private var _isPlaying:Boolean;
   private var _model:MainModel;
   private var _silenceAudioFile:File;
   private var _soundURL:String;

   // ****************************************************
   //
   //          Public Methods
   //
   // ****************************************************

   public function AudioPlayer(manager:SingletonManager) {
      Log.info("AudioPlayer constructor");
      _instance = this;
      _silenceAudioFile = File.applicationDirectory.resolvePath(
            Constant_LangMentor_Misc.FILEPATHINFO__SILENCE_AUDIO_FOLDER_NAME +
            File.separator +
            Constant_LangMentor_Misc.FILEPATHINFO__SILENCE_AUDIO_FILE_NAME);
   }

   public static function getInstance():AudioPlayer {
      Log.info("AudioPlayer.getInstance()");
      if (_instance == null)
         throw new Error("Singleton not initialized");
      return _instance;
   }

   public function initSingleton():void {
      Log.info("AudioPlayer.initSingleton()");
      _currentLessons = CurrentLessons.getInstance();
      _model = MainModel.getInstance();
      Utils_ANEs_Audio.initialize();
   }

   // A passedSoundVolumeAdjustmentFactor of 1 means that the audio file that we're playing will be played at its full volume
   public function playMp3File(soundUrl:String, volume:Number = 1.0):void {
      Log.info("AudioPlayer.playMp3File(): " + soundUrl);
      stop();
      _isPlaying = true;
      _soundURL = soundUrl;
      var lessonProvider:String = _model.getLessonVersionNativeLanguageProviderNameFromLessonVersionVO(_currentLessons.currentLessonVO);
      var lessonTitle:String = _model.getLessonVersionNativeLanguageNameFromLessonVersionVO(_currentLessons.currentLessonVO);
      var file:File = new File(_soundURL);
      Utils_ANEs_Audio.playFile(file, audioCallback, volume, lessonTitle, lessonProvider);
   }

   // When an audio completes we use this method to play an MP3 file consisting of silence. Reason: When the media player is displaying
   // in the lock screen, this causes it to display its controls as if sound is playing, which is what we want.
   // If/when we want to stop the media player we call Utils_ANEs_Audio.stopMediaPlayer().
   public function playSilenceFile():void {
      Log.info("AudioPlayer.playSilenceFile()");
      stop();
      _isPlaying = true;
      _soundURL = null;
      var lessonProvider:String = _model.getLessonVersionNativeLanguageProviderNameFromLessonVersionVO(_currentLessons.currentLessonVO);
      var lessonTitle:String = _model.getLessonVersionNativeLanguageNameFromLessonVersionVO(_currentLessons.currentLessonVO);
      Utils_ANEs_Audio.playFile(_silenceAudioFile, audioCallback, 1.0, lessonTitle, lessonProvider);
   }

   public function playWavSample(sample:ByteArray):void {
      Log.info("AudioPlayer.playWavSample()");
      stop();
      _isPlaying = true;
      _soundURL = null;
      var result:File = new File(Utils_LangCollab.tempAudioFileURL);
      var fs:FileStream = new FileStream();
      fs.open(result, FileMode.WRITE);
      fs.writeBytes(sample, 0, sample.length);
      fs.close();
      var lessonProvider:String = _model.getLessonVersionNativeLanguageProviderNameFromLessonVersionVO(_currentLessons.currentLessonVO);
      var lessonTitle:String = _model.getLessonVersionNativeLanguageNameFromLessonVersionVO(_currentLessons.currentLessonVO);
      var file:File = new File(Utils_LangCollab.tempAudioFileURL);
      Utils_ANEs_Audio.playFile(file, audioCallback, 1.0, lessonTitle, lessonProvider);
   }

   public function stop():void {
      if (_isPlaying) {
         Log.info("AudioPlayer.stop()");
         Utils_ANEs_Audio.stopMediaPlayer();
      }
      else {
         Log.info("AudioPlayer.stop() - function called when audio isn't playing");
      }
      _soundURL = null;
      _isPlaying = false;
   }
   
   // ****************************************************
   //
   //          Private Methods
   //
   // ****************************************************
   
   private function audioCallback(e:Object):void {
      if (e is AudioPlayerEvent) {
         switch (AudioPlayerEvent(e).type) {
            case AudioPlayerEvent.COMPLETE:
               playSilenceFile();
               dispatchEvent(new Event(Event.SOUND_COMPLETE));
               break;
            default:
               Log.warn("AudioPlayer.audioCallback() - Event type not supported: " + AudioPlayerEvent(e).type);
         }
      } else if (e is MediaErrorEvent) {
         Log.error("AudioPlayer.audioCallback() - Passed object is MediaErrorEvent - _soundURL: " + _soundURL);
      } else if (e is RemoteCommandCenterEvent) {
         switch (RemoteCommandCenterEvent(e).type) {
            case RemoteCommandCenterEvent.PAUSE:
               dispatchEvent(new Event_Audio(Event_Audio.AUDIO__USER_STOPPED_AUDIO));
               break;
            case RemoteCommandCenterEvent.PLAY:
               dispatchEvent(new Event_Audio(Event_Audio.AUDIO__USER_STARTED_AUDIO));
               break;
            default:
               Log.warn("AudioPlayer.audioCallback() - Event type not supported: " + RemoteCommandCenterEvent(e).type);
         }
      } else {
         Log.error("AudioPlayer.audioCallback() - Passed object is neither AudioPlayerEvent or MediaErrorEvent - _soundURL: " + _soundURL);
      }
   }


}
}


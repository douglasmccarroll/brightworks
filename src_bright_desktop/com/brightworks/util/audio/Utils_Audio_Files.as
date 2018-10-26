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

import mx.core.SoundAsset;

public class Utils_Audio_Files {

   [Embed('/assets/audio/chirps.mp3')]
   private static const _CHIRPS:Class;
   private static const _CHIRPS_INSTANCE:SoundAsset = new _CHIRPS(); // 6 chirps in 3 seconds - for experimenting with audio
   [Embed('/assets/audio/click.mp3')]
   private static const _CLICK:Class;
   private static const _CLICK_INSTANCE:SoundAsset = new _CLICK();
   [Embed('/assets/audio/buzz_thud.mp3')]
   private static const _FAIL_THUD:Class;
   private static const _FAIL_THUD_INSTANCE:SoundAsset = new _FAIL_THUD();
   [Embed('/assets/audio/logTone_Error.mp3')]
   private static const _LOG_TONE__ERROR:Class;
   private static const _LOG_TONE_INSTANCE__ERROR:SoundAsset = new _LOG_TONE__ERROR();
   [Embed('/assets/audio/logTone_Fatal.mp3')]
   private static const _LOG_TONE__FATAL:Class;
   private static const _LOG_TONE_INSTANCE__FATAL:SoundAsset = new _LOG_TONE__FATAL();
   [Embed('/assets/audio/logTone_Success.mp3')]
   private static const _LOG_TONE__SUCCESS:Class;
   private static const _LOG_TONE_INSTANCE__SUCCESS:SoundAsset = new _LOG_TONE__SUCCESS();
   [Embed('/assets/audio/logTone_Warn.mp3')]
   private static const _LOG_TONE__WARN:Class;
   private static const _LOG_TONE_INSTANCE__WARN:SoundAsset = new _LOG_TONE__WARN();
   [Embed('/assets/audio/pluck_high.mp3')]
   private static const _PLUCK_HIGH:Class;
   private static const _PLUCK_HIGH_INSTANCE:SoundAsset = new _PLUCK_HIGH();
   [Embed('/assets/audio/silence_half_second.mp3')]
   private static const _SILENCE_HALF_SECOND:Class;
   private static const _SILENCE_HALF_SECOND_INSTANCE:SoundAsset = new _SILENCE_HALF_SECOND();

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   //
   //     Public Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   public static function playChirps():void {  // 6 chirps in 3 seconds - for experimenting with audio
      _CHIRPS_INSTANCE.play();
   }

   public static function playClick():void {
      _CLICK_INSTANCE.play();
   }

   public static function playFailureSound():void {
      _FAIL_THUD_INSTANCE.play();
   }

   public static function playLogToneError():void {
      _LOG_TONE_INSTANCE__ERROR.play();
   }

   public static function playLogToneFatal():void {
      _LOG_TONE_INSTANCE__FATAL.play();
   }

   public static function playLogToneSuccess():void {
      _LOG_TONE_INSTANCE__SUCCESS.play();
   }

   public static function playLogToneWarn():void {
      _LOG_TONE_INSTANCE__WARN.play();
   }

   public static function playHighPluck():void {
      _PLUCK_HIGH_INSTANCE.play();
   }

   public static function playSilenceHalfSecond():void {
      _SILENCE_HALF_SECOND_INSTANCE.play();
   }

}
}

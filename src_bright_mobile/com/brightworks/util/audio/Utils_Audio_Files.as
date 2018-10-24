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

import com.brightworks.util.Utils_ANEs;
import com.brightworks.util.audio.Utils_ANEs_Audio;

import flash.filesystem.File;

public class Utils_Audio_Files {

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   //
   //     Public Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   public static function playChirps():void {  // 6 chirps in 3 seconds - for experimenting with audio
      play("assets/audio/chirps.mp3");
   }

   public static function playClick():void {
      play("assets/audio/click.mp3");
   }

   public static function playFailureSound():void {
      play("assets/audio/buzz_thud.mp3");
   }

   public static function playLogToneError():void {
      play("assets/audio/logTone_Error.mp3");
   }

   public static function playLogToneFatal():void {
      play("assets/audio/logTone_Fatal.mp3");
   }

   public static function playLogToneSuccess():void {
      play("assets/audio/logTone_Success.mp3");
   }

   public static function playLogToneWarn():void {
      play("assets/audio/logTone_Warn.mp3");
   }

   public static function playHighPluck():void {
      play("assets/audio/pluck_high.mp3");
   }

   public static function playSilenceHalfSecond():void {
      play("assets/audio/silence_half_second.mp3");
   }

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   //
   //     Private Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   private static function audioCallback(o:Object):void {
      
   }
   
   private static function play(path:String):void {
      var f:File = File.applicationDirectory.resolvePath(path);
      Utils_ANEs_Audio.audioPlayFile(f, audioCallback);
   }
}
}

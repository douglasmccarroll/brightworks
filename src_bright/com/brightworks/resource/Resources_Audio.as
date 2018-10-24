package com.brightworks.resource {

import com.brightworks.util.Utils_NativeExtensions;

import flash.filesystem.File;

public class Resources_Audio {

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
      Utils_NativeExtensions.audioPlayFile(f, audioCallback);
   }
}
}

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
package com.brightworks.util {
import com.brightworks.component.mobilealert.MobileAlert;
import com.brightworks.component.mobilealert.MobileDialog;

import flash.filesystem.File;


/*


 NOTE: We have two versions of this class - one for our mobile production projects and one for our
 desktop debugging project. Many ANEs don't support Windows/Mac, so we use a dummy methods
 for the desktop case.

 This is the Desktop version.

 */


public class Utils_ANEs {

   private static var _callback:Function;

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   //
   //          Public Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   public static function activateCodeScanner(codeScanResultCallback:Function, codeScanCancelCallback:Function, codeScanFailureCallback:Function):void {
   }

   public static function audioPlay(f:File, audioCallback:Function, volume:Number = 1.0):void {
   }

   public static function audioStopMediaPlayer():void {
   }

   public static function facebookShare():void {
   }

   public static function initialize():void {
   }

   public static function requestCameraPermissionForScanner(callback:Function):void {
      callback(false);
   }

   public static function requestMicrophonePermission(callback:Function):void {
      callback(true);
   }

   public static function showAlert_MultipleOptions(messageText:String, optionDisplayNames:Array, callback:Function):void {
      _callback = callback;
      var alertText:String = "This is a dummy multi-option alert\n\nMessage: " + messageText + "\n\nOptions: " + Utils_DataConversionComparison.convertArrayToDelimitedString(optionDisplayNames, ", ");
      MobileDialog.open(alertText, onMultiOptionDialogClose);
   }

   public static function showAlert_OkayButton(alertText:String, callback:Function = null):void {
      MobileDialog.open(alertText, callback);
   }

   public static function showAlert_Toast(alertText:String, useLongDisplay:Boolean = false):void {
      var duration:int = useLongDisplay ? 4000 : 2000;
      MobileAlert.open(alertText, true, duration);
   }

   public static function showRatingsPromptIfAppropriate():void {
   }

   private static function onMultiOptionDialogClose():void {
      _callback(-1);
   }


}
}



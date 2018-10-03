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


/*

 NOTE: This class has separate versions for our production project and our
 desktop debugging project. Many ANEs don't support
 Windows/Mac, so we use a dummy class/methods for the desktop case.

 This is the Desktop version.

 */


public class Utils_NativeExtensions {

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   //
   //          Public Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   public static function activateCodeScanner(codeScanResultCallback:Function, codeScanCancelCallback:Function, codeScanFailureCallback:Function):void {
   }

   /*public static function facebookShare(resultCallback:Function) {
      resultCallback();
   }

   public static function isFacebookSupported():Boolean {
      return false;
   }*/

   public static function requestMicrophonePermission(callback:Function):void {
   }

   public static function showRatingsPrompt():void {
   }


}
}



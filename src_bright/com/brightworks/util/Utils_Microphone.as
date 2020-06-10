/*
 Copyright 2020 Brightworks, Inc.

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

import flash.events.PermissionEvent;

import flash.media.Microphone;
import flash.permissions.PermissionStatus;

public class Utils_Microphone {
   private static var _isPermissionGranted_Microphone:Boolean;
   private static var _microphonePermissionCallback:Function;

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   //
   //          Public Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   public static function requestMicrophonePermission(callback:Function):void {  
      if (_isPermissionGranted_Microphone)
         callback(true);
      if (Microphone.isSupported) {
         if (Microphone.permissionStatus == PermissionStatus.GRANTED) {
            callback(true);
         }
         else {
            _microphonePermissionCallback = callback;
            var mic:Microphone = Microphone.getMicrophone();
            mic.addEventListener(PermissionEvent.PERMISSION_STATUS, onMicrophonePermissionRequestResponse);
            try {
               mic.requestPermission();
            }
            catch(e:Error) {
               callback(false);
            }
         }
      }
   }

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   //
   //          Private Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   private static function onMicrophonePermissionRequestResponse(e:PermissionEvent):void {
      if (e.status == PermissionStatus.GRANTED) {
         _isPermissionGranted_Microphone = true;
         _microphonePermissionCallback(true);
      }
      else {
         _microphonePermissionCallback(false);
      }
   }

}
}



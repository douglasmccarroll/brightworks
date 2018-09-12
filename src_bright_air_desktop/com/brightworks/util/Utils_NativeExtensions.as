/*
 Copyright 2008, 2009, 2010, 2011, 2012 Brightworks, Inc.

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
 Windows/Mac, so we use a dummy class/methods for that case.

 This is the Desktop version.

 */


public class Utils_NativeExtensions {

   public static const GOOGLE_ANALYTICS_CATEGORY__APP_STARTUP:String = "App Startup";
   public static const GOOGLE_ANALYTICS_CATEGORY__LESSON_ENTERED:String = "Lesson Entered";
   public static const GOOGLE_ANALYTICS_CATEGORY__LESSON_LEARNED:String = "Lesson Learned";

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   //
   //          Public Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   public static function activateCodeScanner(codeScanResultCallback:Function, codeScanCancelCallback:Function, codeScanFailureCallback:Function):void {
   }

   public static function facebookInvite(inviteText:String, resultCallbackFunc:Function):void {
   }

   public static function googleAnalyticsTrackAppStartup(appName:String, extraParams:Object):void {
   }

   public static function googleAnalyticsTrackLessonEntered(lessonName:String, lessonId:String, lessonVersion:String, providerId:String):void {
   }

   public static function googleAnalyticsTrackLessonLearned(lessonName:String, lessonVersion:String):void {
   }

   public static function isFacebookSupported():Boolean {
      return false;
   }

   // MyFlashLabs PermissionCheck needed for AIR 24 and later
   public static function requestMicrophonePermission(callback:Function):void {
   }

   public static function showRatingsPrompt():void {
   }

   public static function tweet(tweetText:String, resultCallbackFunc:Function):void {
   }

   public static function vibrate(duration:uint = 1):void {
   }


}
}



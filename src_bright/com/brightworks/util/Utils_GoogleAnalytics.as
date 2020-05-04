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



 This class was created by modifying code from Zwetan Kjukov's AS3 Universal
 Analytics project at https://github.com/zwetan/as3-universal-analytics/.
 Thanks Zwetan!  :)



 */
package com.brightworks.util {

import com.brightworks.constant.Constant_Private;

import flash.display.Loader;
import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.HTTPStatusEvent;
import flash.events.IOErrorEvent;
import flash.events.UncaughtErrorEvent;
import flash.net.URLRequest;
import flash.net.URLRequestMethod;

public class Utils_GoogleAnalytics {

   public static const GOOGLE_ANALYTICS_CATEGORY__APP_STARTUP:String = "App Startup";
   public static const GOOGLE_ANALYTICS_CATEGORY__LESSON_FINISHED:String = "Lesson Finished";

   private static var _sessionId:String;
   private static var _isAlphaOrBetaRelease:Boolean;
   private static var _loader:Loader;

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   //
   //     Public Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   public static function setIsAlphaOrBetaRelease(b:Boolean):void {
      _isAlphaOrBetaRelease = b;
   }

   public static function trackAppStartup(data:String):void {
      initIfNeeded();
      var clientId:String;
      if (_isAlphaOrBetaRelease) {
         // If we're in alpha or beta mode we use a hardcoded client ID, so that testing isn't reported as "real use" of the app.
         clientId = "AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE";
      }
      else {
         clientId = _sessionId;
      }
      sendEvent(Constant_Private.LANGMENTOR_GOOGLE_ANALYTICS_CODE__MENTOR_TYPE_SPECIFIC, clientId, GOOGLE_ANALYTICS_CATEGORY__APP_STARTUP, data);
   }

   public static function trackLessonFinished(lessonName:String, lessonId:String, lessonVersion:String, providerId:String):void {
      if (_isAlphaOrBetaRelease) {
         return;
      }
      initIfNeeded();
      // We generate a new "client ID" every time we report that a lesson has been finished because we want these events to display in Google Analytics on a map, and the only way we
      //    can find to do this is to use GA's Audience > Geo > Location map, which shows Users, Sessions, etc, but doesn't have the ability to display events. Solution: Make every lesson learned a separate "User".
      // We also use the same GA TID code in all "mentor types", i.e. the universal version and in language-specific versions, so that all lessons learned will be displayed in the same map
      sendEvent(Constant_Private.LANGMENTOR_GOOGLE_ANALYTICS_CODE__COMMON_TO_ALL_MENTOR_TYPES, Utils_Misc.generateImitationUUIDString(), GOOGLE_ANALYTICS_CATEGORY__LESSON_FINISHED, providerId + ":" + lessonId + ":" + lessonVersion, lessonName);
   }


   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   //
   //     Private Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   private static function initIfNeeded():void {
      // We create a new client ID each time the app is initialized. We don't persist this because we don't want to make it easy for governments or other actors to trace users.
      // Note that this is currently only being used on app startup, so we don't even really need to save the ID for the rest of the session. But we've used it in the past for events, and may do so again, so we're keeping it.
      if (!_sessionId) {
         _sessionId = Utils_Misc.generateImitationUUIDString();
      }
      if (!_loader) {
         _loader = new Loader();
         _loader.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onLoaderUncaughtError);
         _loader.contentLoaderInfo.addEventListener(HTTPStatusEvent.HTTP_STATUS, onLoaderHTTPStatus);
         _loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaderComplete);
         _loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLoaderIOError);
      }
   }

   private static function onLoaderUncaughtError(e:UncaughtErrorEvent):void {
      if (e.error is Error) {
         var error:Error = e.error as Error;
         Log.warn("Utils_GoogleAnalytics.onLoaderUncaughtError() - events error is Error - message: " + error.message);
      }
      else if (e.error is ErrorEvent) {
         var errorEvent:ErrorEvent = e.error as ErrorEvent;
         Log.warn("Utils_GoogleAnalytics.onLoaderUncaughtError() - event's error is ErrorEvent - errorID: " + errorEvent.errorID);
      }
      else {
         Log.warn("Utils_GoogleAnalytics.onLoaderUncaughtError() - event's error is neither Error nor ErrorEvent - toString() generates: " + e.toString());
      }
      if (_loader) {
         try {
            _loader.close();
            _loader.unload();
         }
         catch (error:Error) {
            var a:int = 1;  // for debugging
         }
      }
   }

   private static function onLoaderHTTPStatus(e:HTTPStatusEvent):void {
      if (e.status == 0) {
         // this happens when there is no internet connection
      }
      else if ((e.status >= 200) && (e.status < 300)) {
         // the request was accepted
      }
      else {
         Log.warn("Utils_GoogleAnalytics.onLoaderHTTPStatus() - event's status was not accepted");
         if (Utils_System.isAlphaOrBetaVersion()) {
            Utils_ANEs.showAlert_OkayButton("GA Post | Event's status was " + e.status);
         }
         if (_loader) {
            try {
               _loader.close();
               _loader.unload();
            }
            catch (error:Error) {
               var a:int = 1;  // for debugging
            }
         }
      }
   }

   private static function onLoaderIOError(e:IOErrorEvent):void {
      switch (e.errorID) {
         case 2036:
            // "Load never completed" - this happens when there is no connection to internet
            break;
         default:
            if (Utils_System.isAlphaOrBetaVersion()) {
               Utils_ANEs.showAlert_OkayButton("GA Post | ioError | Error ID: " + e.errorID);
            }
            Log.warn("Utils_GoogleAnalytics.onLoaderIOError() - errorID: " + e.errorID);
      }
      if (_loader) {
         try {
            _loader.close();
            _loader.unload();
         }
         catch (error:Error) {
            var a:int = 1;  // for debugging
         }
      }
   }

   private static function onLoaderComplete(e:Event):void {
      if (_loader) {
         try {
            _loader.unload();
         }
         catch (error:Error) {
            var a:int = 1;  // for debugging
         }
      }
   }

   private static function sendEvent(
         googleAnalyticsTIDCode:String,
         clientId:String,
         category:String,
         action:String,
         label:String = null,
         value:Number = NaN):void {
      var payload:Array = [];
      payload.push("v=1");
      payload.push("tid=" + googleAnalyticsTIDCode);
      payload.push("cid=" + clientId);
      payload.push("t=event");
      payload.push("ec=" + category);
      payload.push("ea=" + action);
      if (label)
         payload.push("el=" + label);
      if (!isNaN(value))
         payload.push("ev=" + value);
      var request:URLRequest = new URLRequest();
      request.method = URLRequestMethod.POST;
      request.url = "http://www.google-analytics.com/collect";
      request.data = payload.join("&");
      try {
         _loader.load(request);
      }
      catch (error:Error) {
         Log.warn("Utils_GoogleAnalytics.sendEvent() - Exception occurred when we executed _loader.load() - error.message: " + error.message);
      }
   }


}

}


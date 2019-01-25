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
   public static const GOOGLE_ANALYTICS_CATEGORY__LESSON_ENTERED:String = "Lesson Entered";
   public static const GOOGLE_ANALYTICS_CATEGORY__LESSON_LEARNED:String = "Lesson Learned";
   public static const GOOGLE_ANALYTICS_CATEGORY__LOG_DATA:String = "Log Data";

   private static var _clientID:String;
   private static var _isAlphaOrBetaRelease:Boolean;
   private static var _loader:Loader;
   private static var _trackLogDataCallbackFunction:Function;

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   //
   //     Public Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   
   public static function setIsAlphaOrBetaRelease(b:Boolean):void {
      _isAlphaOrBetaRelease = b;
   }

   public static function trackAppStartup(data:String):void {
      _trackLogDataCallbackFunction = null;
      sendEvent(GOOGLE_ANALYTICS_CATEGORY__APP_STARTUP, data);
   }

   public static function trackLessonEntered(lessonName:String, lessonId:String, lessonVersion:String, providerId:String):void {
      _trackLogDataCallbackFunction = null;
      sendEvent(GOOGLE_ANALYTICS_CATEGORY__LESSON_ENTERED, providerId + ":" + lessonId + ":" + lessonVersion, lessonName);
   }

   public static function trackLogData(data:String, trackLogDataCallbackFunction:Function = null):void {
      _trackLogDataCallbackFunction = trackLogDataCallbackFunction;
      sendEvent(GOOGLE_ANALYTICS_CATEGORY__LOG_DATA, data);
   }

   public static function trackLessonLearned(lessonName:String, lessonId:String, lessonVersion:String, providerId:String):void {
      _trackLogDataCallbackFunction = null;
      sendEvent(GOOGLE_ANALYTICS_CATEGORY__LESSON_LEARNED, providerId + ":" + lessonId + ":" + lessonVersion, lessonName);
   }


   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   //
   //     Private Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   private static function onLoaderUncaughtError(e:UncaughtErrorEvent):void {
      if (e.error is Error) {
         var error:Error = e.error as Error;
         Log.warn("GATracker.onLoaderUncaughtError() - events error is Error - message: " + error.message);
      }
      else if (e.error is ErrorEvent) {
         var errorEvent:ErrorEvent = e.error as ErrorEvent;
         Log.warn("GATracker.onLoaderUncaughtError() - event's error is ErrorEvent - errorID: " + errorEvent.errorID);
      }
      else {
         Log.warn("GATracker.onLoaderUncaughtError() - event's error is neither Error nor ErrorEvent - toString() generates: " + e.toString());
      }
      if (_trackLogDataCallbackFunction is Function) {
         _trackLogDataCallbackFunction(false);
         _trackLogDataCallbackFunction = null;
      }
   }

   private static function onLoaderHTTPStatus(e:HTTPStatusEvent):void {
      if (e.status == 200) {
         // the request was accepted
      }
      else {
         Log.warn("GATracker.onLoaderHTTPStatus() - event's status was not 200 (accepted)");
         if (_trackLogDataCallbackFunction is Function) {
            _trackLogDataCallbackFunction(false);
            _trackLogDataCallbackFunction = null;
         }
      }
   }

   private static function onLoaderIOError(e:IOErrorEvent):void {
      Log.warn("GATracker.onLoaderIOError() - errorID: " + e.errorID);
      if (_trackLogDataCallbackFunction is Function) {
         _trackLogDataCallbackFunction(false);
         _trackLogDataCallbackFunction = null;
      }
   }

   private static function onLoaderComplete(e:Event):void {
      if (_trackLogDataCallbackFunction is Function) {
         _trackLogDataCallbackFunction(true);
         _trackLogDataCallbackFunction = null;
      }
   }

   private static function sendEvent(
         category:String,
         action:String,
         label:String = null,
         value:Number = NaN):void {
      // We create a new client ID each time the app is initialized. We don't persist this because we don't want to make it easy for governments or other actors to trace users.
      // Exception: If we're in alpha or beta mode we use a hardcoded client ID, so that testing isn't reported as "real use" of the app. 
      if (!_clientID) {
         if (_isAlphaOrBetaRelease) {
            _clientID = "AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE";
         }
         else {
            _clientID = Utils_Misc.generateImitationUUIDString();
         }
      }
      if (!_loader) {
         _loader = new Loader();
         _loader.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onLoaderUncaughtError);
         _loader.contentLoaderInfo.addEventListener(HTTPStatusEvent.HTTP_STATUS, onLoaderHTTPStatus);
         _loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaderComplete);
         _loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLoaderIOError);
      }
      var payload:Array = [];
      payload.push("v=1");
      payload.push("tid=" + Constant_Private.LANGMENTOR_GOOGLE_ANALYTICS_CODE);
      payload.push("cid=" + _clientID);
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
      catch (e:Error) {
         Log.warn("GATracker.sendEvent() - Exception occurred when we executed _loader.load()");
      }
   }


}

}


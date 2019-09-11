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

import com.brightworks.constant.Constant_Private;

import flash.display.Loader;
import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.HTTPStatusEvent;
import flash.events.IOErrorEvent;
import flash.events.UncaughtErrorEvent;
import flash.net.URLRequest;
import flash.net.URLRequestMethod;

public class Utils_AWS {

   private static var _clientID:String;
   private static var _loader:Loader;
   private static var _logMessageCallbackFunction:Function;

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   //
   //     Public Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   
   public static function sendLogMessage(url:String, body:String, trackLogDataCallbackFunction:Function = null):void {
      _logMessageCallbackFunction = trackLogDataCallbackFunction;
      sendHttpPost(url, body);
   }

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   //
   //     Private Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   private static function onLoaderUncaughtError(e:UncaughtErrorEvent):void {
      if (e.error is Error) {
         var error:Error = e.error as Error;
         Log.warn("Utils_AWS.onLoaderUncaughtError() - events error is Error - message: " + error.message, false);
      }
      else if (e.error is ErrorEvent) {
         var errorEvent:ErrorEvent = e.error as ErrorEvent;
         Log.warn("Utils_AWS.onLoaderUncaughtError() - event's error is ErrorEvent - errorID: " + errorEvent.errorID, false);
      }
      else {
         Log.warn("Utils_AWS.onLoaderUncaughtError() - event's error is neither Error nor ErrorEvent - toString() generates: " + e.toString(), false);
      }
      if (_logMessageCallbackFunction is Function) {
         _logMessageCallbackFunction(true);   //// Returning true here because we don't want to spook the user, given the fact that this is probably a false alarm
         _logMessageCallbackFunction = null;
      }
   }

   private static function onLoaderHTTPStatus(e:HTTPStatusEvent):void {
      if (e.status == 200) {
         // the request was accepted
      }
      else {
         if (Utils_System.isRunningOnDesktop())
            return;
         Log.warn("Utils_AWS.onLoaderHTTPStatus() - event's status was not 200 (accepted)", false);
         if (_logMessageCallbackFunction is Function) {
            _logMessageCallbackFunction(true);    //// Returning true here because we don't want to spook the user, given the fact that this is probably a false alarm
            _logMessageCallbackFunction = null;
         }
      }
   }

   private static function onLoaderIOError(e:IOErrorEvent):void {
      if (Utils_System.isRunningOnDesktop())
            return;
      switch (e.errorID) {
         case 2124:
            //// AWS API Gateway is returning these errors even when the call succeeds - ignore for now
            break;
         default:
            if (Utils_System.isAlphaOrBetaVersion()) {
               Utils_ANEs.showAlert_OkayButton("HTTP AWS Post ioError - error ID: " + e.errorID);
            }
            Log.warn("Utils_AWS.onLoaderIOError() - errorID: " + e.errorID, false);
            if (_logMessageCallbackFunction is Function) {
               _logMessageCallbackFunction(true);   //// Returning true here because we don't want to spook the user, given the fact that this is probably a false alarm
               _logMessageCallbackFunction = null;
            }
      }
   }

   private static function onLoaderComplete(e:Event):void {
      if (_logMessageCallbackFunction is Function) {
         _logMessageCallbackFunction(true);
         _logMessageCallbackFunction = null;
      }
   }

   private static function sendHttpPost(
         url:String,
         body:String):void {
      if (!_loader) {
         _loader = new Loader();
         _loader.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onLoaderUncaughtError);
         _loader.contentLoaderInfo.addEventListener(HTTPStatusEvent.HTTP_STATUS, onLoaderHTTPStatus);
         _loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaderComplete);
         _loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLoaderIOError);
      }
      var request:URLRequest = new URLRequest();
      request.data = body;
      request.method = URLRequestMethod.POST;
      request.url = url;
      try {
         _loader.load(request);
      }
      catch (e:Error) {
         Log.warn("Utils_AWS.sendEvent() - Exception occurred when we executed _loader.load()", false);
      }
   }


}

}


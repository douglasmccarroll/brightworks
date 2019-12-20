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

   public static function sendUserActivityReportingToServer(url:String, body:String):void {
      sendHttpPost(url, body);
   }

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   //
   //     Private Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   private static function onLoaderUncaughtError(e:UncaughtErrorEvent):void {
      if (_logMessageCallbackFunction is Function) {
         _logMessageCallbackFunction(true);   //// Returning true in all cases because it seems that most "errors" are false alarms
         _logMessageCallbackFunction = null;
      }
      var errorString:String;
      if (e.error is Error) {
         var error:Error = e.error as Error;
         errorString = "Error Message: " + error.message;
      }
      else if (e.error is ErrorEvent) {
         var errorEvent:ErrorEvent = e.error as ErrorEvent;
         errorString = "Error ID: " + errorEvent.errorID;
      }
      else {
         errorString = "Error is neither Error nor ErrorEvent - toString() generates: " + e.toString();
      }
      if (_loader) {
         try {
            _loader.close();
            _loader.unload();
         }
         catch (e:Error) {
            var a:int = 1;  // for debugging
         }
      }
      if (Utils_System.isAlphaOrBetaVersion()) {
         Utils_ANEs.showAlert_OkayButton("AWS Post | Uncaught Error | " + errorString);
      }
   }

   private static function onLoaderHTTPStatus(e:HTTPStatusEvent):void {
      if (_logMessageCallbackFunction is Function) {
         _logMessageCallbackFunction(true);   //// Returning true in all cases because it seems that most "errors" are false alarms
         _logMessageCallbackFunction = null;
      }
      if (e.status == 0) {
         // we do nothing here because a zero means "no result yet"
      }
      else if ((e.status >= 200) && (e.status < 300)) {
         // the request was accepted
      }
      else {
         if (Utils_System.isAlphaOrBetaVersion()) {
            Utils_ANEs.showAlert_OkayButton("AWS Post | Event's status was " + e.status);
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
      if (_logMessageCallbackFunction is Function) {
         _logMessageCallbackFunction(true);   //// Returning true in all cases because it seems that most "errors" are false alarms
         _logMessageCallbackFunction = null;
      }
      var isFailure:Boolean = false;
      switch (e.errorID) {
         case 2036:
            // This happens when there's no internet connection
            isFailure = true;
            break;
         case 2124:
            //// AWS API Gateway is returning these errors even when the call succeeds - ignore for now
            break;
         default:
            isFailure = true;
            if (Utils_System.isAlphaOrBetaVersion()) {
               Utils_ANEs.showAlert_OkayButton("AWS Post | ioError | Error ID: " + e.errorID);
            }
      }
      if (isFailure) {
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

   private static function onLoaderComplete(e:Event):void {
      if (_logMessageCallbackFunction is Function) {
         _logMessageCallbackFunction(true);
         _logMessageCallbackFunction = null;
      }
      if (_loader) {
         try {
            _loader.unload();
         }
         catch (error:Error) {
            var a:int = 1;  // for debugging
         }
      }
   }

   private static function sendHttpPost(
         url:String,
         body:String):void {
      // Useful for generating 2035 ioErrors -   url = "http://lmentorlogs.cloudfoundry.com/logreports";
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
      catch (error:Error) {
         if (Utils_System.isAlphaOrBetaVersion()) {
            Utils_ANEs.showAlert_OkayButton("AWS Post | Exception occurred when we executed _loader.load() - error.message: " + error.message);
         }
      }
   }


}

}


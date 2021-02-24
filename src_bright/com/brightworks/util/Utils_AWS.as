/*
 Copyright 2021 Brightworks, Inc.

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

import mx.core.FlexGlobals;

public class Utils_AWS {

   private static var _loader:Loader;
   private static var _loaderUseCount:int = 0;
   private static var _logMessageCallbackFunction:Function;
   private static var _mostRecentBody:String;
   private static var _mostRecentURL:String;

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
         _logMessageCallbackFunction(true);   // Returning true in all cases because it seems that most "errors" are false alarms
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
            _loader = null;  // Once again, we assume that most errors are false alarms, so we don't resend
         }
         catch (e:Error) {
            var a:int = 1;  // for debugging
         }
      }
      if (Utils_System.isAlphaOrBetaVersion()) {
         var alertText:String = "AWS Post | Uncaught Error | " + errorString + " | " + Utils_DateTime.getCurrentTimeIn_HHMM_Format();
         if (_mostRecentBody) {
            alertText += " | " + sizeBodyTextForAlert(_mostRecentBody);
         }
         Utils_ANEs.showAlert_OkayButton(alertText);
      }
   }

   private static function onLoaderHTTPStatus(e:HTTPStatusEvent):void {
      if (_logMessageCallbackFunction is Function) {
         _logMessageCallbackFunction(true);   // Returning true in all cases because it seems that most "errors" are false alarms
         _logMessageCallbackFunction = null;
      }
      var isFailure:Boolean = false;
      if (e.status == 0) {
         // we do nothing here because a zero means "no result yet"
      }
      else if ((e.status >= 200) && (e.status < 300)) {
         // the request was accepted
         if (_loader) {
            try {
               // _loader.close();   // Causes an error - because loader is already closed, I assume
               _loader.unload();
               _loader = null;
            }
            catch (error:Error) {
               var a:int = 1;  // for debugging
            }
         }
      }
      else if (e.status == 502) {
         // Getting a lot of these for activity reports
         // 502 Bad Gateway server error - the server, while acting as a gateway or proxy, received an invalid response from the upstream server
         isFailure = true;
         if (_loader) {
            try {
               _loader.close();
               _loader.unload();
               FlexGlobals.topLevelApplication.callLater(sendHttpPost, [_mostRecentURL, _mostRecentBody]);
            }
            catch (error:Error) {
               var b:int = 1;  // for debugging
            }
         }
      }
      else {
         isFailure = true;
         if (_loader) {
            try {
               _loader.close();
               _loader.unload();
               _loader = null;
            }
            catch (error:Error) {
               var c:int = 1;  // for debugging
            }
         }
      }
      if (isFailure) {
         if (Utils_System.isAlphaOrBetaVersion()) {
            var alertText:String = "AWS Post | Event's status is " + e.status + " | " + _loaderUseCount + " Retries | " + Utils_DateTime.getCurrentTimeIn_HHMM_Format();
            if (_mostRecentBody) {
               var bodyText:String = sizeBodyTextForAlert(_mostRecentBody);
               alertText += " | " + bodyText;
            }
            Utils_ANEs.showAlert_OkayButton(alertText);
         }
      }
   }

   private static function onLoaderIOError(e:IOErrorEvent):void {
      if (_logMessageCallbackFunction is Function) {
         _logMessageCallbackFunction(true);   // Returning true in all cases because it seems that most "errors" are false alarms
         _logMessageCallbackFunction = null;
      }
      var isFailure:Boolean = false;
      switch (e.errorID) {
         case 2035:
         case 2036:
            //// These errors occur when there's no internet connection. If we want accurate reporting we should have an actions-to-be-reported pool, and keep trying to send this info.
            isFailure = true;
            break;
         case 2124:
            // AWS API Gateway is returning these errors even when the call succeeds - ignore for now
            break;
         default:
            isFailure = true;
            if (Utils_System.isAlphaOrBetaVersion()) {
               var alertText:String = "AWS Post | ioError | Error ID: " + e.errorID + " | " + Utils_DateTime.getCurrentTimeIn_HHMM_Format();
               if (_mostRecentBody) {
                  alertText += " | " + sizeBodyTextForAlert(_mostRecentBody);
               }
               Utils_ANEs.showAlert_OkayButton(alertText);
            }
      }
      if (isFailure) {
         if (_loader) {
            try {
               _loader.close();
               _loader.unload();
               _loader = null;  // Once again, we assume that most errors are false alarms, so we don't resend
            }
            catch (error:Error) {
               var a:int = 1;  // for debugging
            }
         }
      }
      else {
         _loader = null;
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
            _loader = null;
         }
         catch (error:Error) {
            var a:int = 1;  // for debugging
         }
      }
   }

   private static function sendHttpPost(
         url:String,
         body:String):void {
      if (_loader) {
         _loaderUseCount++;
      }
      else {
         _loader = new Loader();
         _loader.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onLoaderUncaughtError);
         _loader.contentLoaderInfo.addEventListener(HTTPStatusEvent.HTTP_STATUS, onLoaderHTTPStatus);
         _loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaderComplete);
         _loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLoaderIOError);
         _loaderUseCount = 1;
      }
      var request:URLRequest = new URLRequest();
      request.data = body;
      request.method = URLRequestMethod.POST;
      request.url = url;
      try {
         _loader.load(request);
         _mostRecentBody = body;
         _mostRecentURL = url;
      }
      catch (error:Error) {
         if (Utils_System.isAlphaOrBetaVersion()) {
            var alertText:String = "AWS Post | Exception occurred when we executed _loader.load() - error.message: " + error.message + " | " + Utils_DateTime.getCurrentTimeIn_HHMM_Format();
            if (body) {
               alertText += " | " + sizeBodyTextForAlert(body);
            }
            Utils_ANEs.showAlert_OkayButton(alertText);
         }
      }
   }

   private static function sizeBodyTextForAlert(bodyText:String):String {
      var newTextLength:int = Utils_System.isRunningOnDesktop() ? 250 : 500;
      return bodyText.length <= newTextLength ? bodyText : bodyText.substr(0, newTextLength) + "...";
   }




}

}


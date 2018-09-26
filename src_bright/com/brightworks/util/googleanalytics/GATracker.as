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
package com.brightworks.util.googleanalytics {

import com.brightworks.constant.Constant_Private;
import com.brightworks.util.Log;
import com.brightworks.util.Utils_Misc;

import flash.display.Loader;
import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.HTTPStatusEvent;
import flash.events.IOErrorEvent;
import flash.events.UncaughtErrorEvent;
import flash.net.URLRequest;
import flash.net.URLRequestMethod;

public class GATracker {
   private var _clientID:String;
   private var _loader:Loader;

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   //
   //     Public Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   public function GATracker() {
      _clientID = Utils_Misc.generateImitationUUIDString();
   }

   public function sendEvent(
         category:String,
         action:String,
         label:String = null,
         value:Number = NaN):void {
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
      var url:String = "http://www.google-analytics.com/collect";
      var request:URLRequest = new URLRequest();
      request.method = URLRequestMethod.GET;
      request.url = url;
      request.data = payload.join("&");
      _loader = new Loader();
      _loader.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onLoaderUncaughtError);
      _loader.contentLoaderInfo.addEventListener(HTTPStatusEvent.HTTP_STATUS, onLoaderHTTPStatus);
      _loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaderComplete);
      _loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLoaderIOError);
      try {
         _loader.load(request);
      }
      catch (e:Error) {
         Log.warn("GATracker.sendEvent() - Exception occurred when we executed _loader.load()");
         disposeLoader();
      }

   }
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   //
   //     Private Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   private function onLoaderUncaughtError(e:UncaughtErrorEvent):void {
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
      disposeLoader();
   }

   private function onLoaderHTTPStatus(e:HTTPStatusEvent):void {
      if (e.status == 200) {
         // the request was accepted
      }
      else {
         Log.warn("GATracker.onLoaderHTTPStatus() - event's status was not 200 (accepted)");
      }
   }

   private function onLoaderIOError(e:IOErrorEvent):void {
      Log.warn("GATracker.onLoaderIOError() - errorID: " + e.errorID);
      disposeLoader();
   }

   private function onLoaderComplete(event:Event):void {
      disposeLoader();
   }

   private function disposeLoader():void {
      _loader.uncaughtErrorEvents.removeEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onLoaderUncaughtError);
      _loader.contentLoaderInfo.removeEventListener(HTTPStatusEvent.HTTP_STATUS, onLoaderHTTPStatus);
      _loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoaderComplete);
      _loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onLoaderIOError);
      _loader = null;
   }

}

}

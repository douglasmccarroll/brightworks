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
import com.brightworks.interfaces.IManagedSingleton;
import com.brightworks.util.singleton.SingletonManager;

import flash.events.Event;
import flash.events.TimerEvent;

import mx.core.FlexGlobals;
import mx.core.UIComponent;

public class PerformanceAnalyzer implements IManagedSingleton {
   private static const _TIMER_INTERVAL:uint = 1000;

   private static var _instance:PerformanceAnalyzer;

   public var diagnosticString:String;

   private var _mostRecentEnterFrameTime:Number;
   private var _timer:AppActiveElapsedTimeTimer;

   // ****************************************************
   //
   //          Getters / Setters
   //
   // ****************************************************

   private var _loopsPerMS:Number;

   public function get loopsPerMS():Number {
      return _loopsPerMS;
   }

   // ****************************************************
   //
   //          Public Methods
   //
   // ****************************************************

   public function PerformanceAnalyzer(manager:SingletonManager):void {
      _instance = this;
      Log.debug("PerformanceAnalyzer constructor");
   }

   public static function getInstance():PerformanceAnalyzer {
      if (!(_instance))
         throw new Error("Singleton not initialized");
      return _instance;
   }

   public function initSingleton():void {
      computeLoopsPerMS();
      startTimer();
      UIComponent(FlexGlobals.topLevelApplication).addEventListener(Event.ENTER_FRAME, onEnterFrame);
   }

   // ****************************************************
   //
   //          Private Methods
   //
   // ****************************************************

   private function computeLoopsPerMS():void {
      var loopCount:Number = 100000000;
      while (true) {
         var startTime:Number = Utils_DateTime.getCurrentMS_BasedOnDate();
         var x:int = 0;
         for (var i:uint = 0; i < loopCount; i++) {
            x++;
         }
         var elapsedTime:Number = Utils_DateTime.getCurrentMS_BasedOnDate() - startTime;
         if (elapsedTime > 10) {
            break;
         }
         loopCount *= 10;
      }
      _loopsPerMS = Math.round(loopCount / elapsedTime);
      diagnosticString = "loopCount:" + loopCount + " elapsedTime:" + elapsedTime + " loopsPerMS:" + _loopsPerMS + " x:" + x;
   }

   private function onEnterFrame(event:Event):void {
      var currTime:Number = Utils_DateTime.getCurrentMS_AppActive();
      var msSinceLastEnterFrame:Number = currTime - _mostRecentEnterFrameTime;
      var infoReportingThreshold:Number = 300;
      if ((Log.isLoggingEnabled(Log.LOG_LEVEL__DEBUG)) ||
            (Log.isLoggingEnabled(Log.LOG_LEVEL__INFO) && (msSinceLastEnterFrame >= infoReportingThreshold))) {
         Log.frameLength(msSinceLastEnterFrame);
      }
      _mostRecentEnterFrameTime = currTime;
   }

   private function onTimer(event:TimerEvent):void {
      // restart timer?
   }

   private function startTimer():void {
      _timer = new AppActiveElapsedTimeTimer(_TIMER_INTERVAL);
      _timer.addEventListener(TimerEvent.TIMER, onTimer);
      _timer.start();
   }

}
}

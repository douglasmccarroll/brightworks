/*
Copyright 2008 - 2013 Brightworks, Inc.

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
import flash.events.EventDispatcher;

import mx.utils.ObjectUtil;

public class Utils_DateTime extends EventDispatcher implements IManagedSingleton {
   private static var _currentActivationStartTime:Number = 0;
   private static var _instance:Utils_DateTime;
   private static var _initialized:Boolean;
   private static var _totalElapsedTime_PreviousActivations:Number = 0;

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   //
   //          Public Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   public function Utils_DateTime(manager:SingletonManager) {
      _instance = this;
      _currentActivationStartTime = getCurrentMS_BasedOnDate(true);
      addEventListener(Event.ACTIVATE, onActivate);
      addEventListener(Event.DEACTIVATE, onDeactivate);
   }

   // Return values:
   //  -1 - d1 is before d2
   //   0 - dates are equal
   //   1 - d1 is after d2
   public static function compare(d1:Date, d2:Date):int {
      if (!_initialized)
         logNotInitialized();
      return ObjectUtil.dateCompare(d1, d2);
   }

   public static function computeDaysBeforePresent(date:Date):Number {
      if (!_initialized)
         logNotInitialized();
      var ms:Number = computeMillisecondsBeforePresent(date);
      var days:Number = convertMillisecondsToDays(ms);
      return days;
   }

   public static function computeMillisecondsBeforePresent(date:Date):Number {
      if (!_initialized)
         logNotInitialized();
      var currMS:Number = new Date().valueOf();
      var compMS:Number = date.valueOf();
      var result:Number = currMS - compMS;
      return result;
   }

   public static function convertMillisecondsToDays(ms:Number):Number {
      if (!_initialized)
         logNotInitialized();
      return convertMillisecondsToHours(ms) / 24;
   }

   public static function convertMillisecondsToHours(ms:Number):Number {
      if (!_initialized)
         logNotInitialized();
      var msPerHour:Number = 3600000;
      var result:Number = ms / msPerHour;
      return result;
   }

   public static function getCurrentDateIn_YYYYMMDD_Format():String {
      if (!_initialized)
         logNotInitialized();
      var result:String = "";
      var d:Date = new Date();
      result += d.fullYear;
      result += Utils_String.padBeginning(String(d.month + 1), 2, "0");
      result += Utils_String.padBeginning(String(d.date), 2, "0");
      return result;
   }

   public static function getCurrentDateTimeIn_YYYYMMDD_HHMMSS_Format():String {
      if (!_initialized)
         logNotInitialized();
      var result:String = "";
      var d:Date = new Date();
      result += d.fullYear;
      result += Utils_String.padBeginning(String(d.month + 1), 2, "0");
      result += Utils_String.padBeginning(String(d.date), 2, "0");
      result += "_";
      result += Utils_String.padBeginning(String(d.hours + 1), 2, "0");
      result += Utils_String.padBeginning(String(d.minutes + 1), 2, "0");
      result += Utils_String.padBeginning(String(d.seconds + 1), 2, "0");
      return result;
   }

   public static function getCurrentDateTimeIn_YYYYMMDDdotHHMMcolonTimeZoneOffset_Format():String {
      if (!_initialized)
         logNotInitialized();
      var result:String = "";
      var d:Date = new Date();
      result += d.fullYear;
      result += Utils_String.padBeginning(String(d.month + 1), 2, "0");
      result += Utils_String.padBeginning(String(d.date), 2, "0");
      result += ".";
      result += Utils_String.padBeginning(String(d.hours + 1), 2, "0");
      result += Utils_String.padBeginning(String(d.minutes + 1), 2, "0");
      result += ":";
      result += d.timezoneOffset / 60;
      return result;
   }

   public static function getCurrentMS_AppActive():Number {
      if (!_initialized)
         return 0;
      var result:Number = _totalElapsedTime_PreviousActivations;
      if (_currentActivationStartTime > 0)
         result += (getCurrentMS_BasedOnDate() - _currentActivationStartTime);
      return result;
   }

   public static function getCurrentMS_BasedOnDate(calledFromConstructor:Boolean = false):Number {
      if (!calledFromConstructor && !_initialized)
         logNotInitialized();
      return new Date().valueOf();
   }

   public static function getCurrentTimeIn_HHMM_Format():String {
      if (!_initialized)
         logNotInitialized();
      var result:String = "";
      var d:Date = new Date();
      result += Utils_String.padBeginning(String(d.hours + 1), 2, "0");
      result += Utils_String.padBeginning(String(d.minutes + 1), 2, "0");
      return result;
   }

   public static function getInstance():Utils_DateTime {
      if (!(_instance))
         throw new Error("Singleton not initialized");
      return _instance;
   }

   public function initSingleton():void {
      Utils_DateTime._initialized = true;
   }

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   //
   //          Private Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   private function onActivate(event:Event):void {
      if (_currentActivationStartTime > 0) {
         // We're already recording time. Do nothing.
         return;
      }
      _currentActivationStartTime = getCurrentMS_BasedOnDate();
   }

   private function onDeactivate(event:Event):void {
      if (Utils_System.isRunningOnDesktop()) {
         // When running on desktop, a deactivate event indicates that the app's window has lost
         // focus, but the app continues to execute. So we haven't really deactivated.
         return;
      }
      if (_currentActivationStartTime == 0) {
         Log.error("Utils_DateTime.onAppDeactivation(): _currentActivationStartTime == 0");
         return;
      }
      var elapsedMS:Number = getCurrentMS_BasedOnDate() - _currentActivationStartTime;
      _totalElapsedTime_PreviousActivations = _totalElapsedTime_PreviousActivations + elapsedMS;
      _currentActivationStartTime = 0;
   }

   private static function logNotInitialized():void {
      Log.fatal("Utils_DateTime.logNotInitialized(): Class not initialized - must be initialized at app startup");
   }

}
}


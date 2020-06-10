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
import flash.events.TimerEvent;
import flash.utils.Dictionary;
import flash.utils.Timer;

public class Utils_Timer {

   private static var _index_Timers_to_ArgLists:Dictionary = new Dictionary();
   private static var _index_Timers_to_Functions:Dictionary = new Dictionary();

   public static function callLater(func:Function, delayMS:int, argList:Array = null):void {
      if (!(argList is Array)) {
         argList = [];
      }
      if (argList.length > 5) {
         Log.error("Utils_Timer.callLater() - Too many arguments");
         return;
      }
      var timer:Timer = new Timer(delayMS, 1);
      timer.addEventListener(TimerEvent.TIMER, onTimer);
      _index_Timers_to_ArgLists[timer] = argList;
      _index_Timers_to_Functions[timer] = func;
      timer.start();
   }

   private static function onTimer(event:TimerEvent):void {
      var timer:Timer = Timer(event.currentTarget);
      timer.stop();
      timer.removeEventListener(TimerEvent.TIMER, onTimer);
      var func:Function = _index_Timers_to_Functions[timer];
      var argList:Array = _index_Timers_to_ArgLists[timer];
      Utils_ArrayVectorEtc.removePropsFromDictionary([timer], _index_Timers_to_ArgLists);
      Utils_ArrayVectorEtc.removePropsFromDictionary([timer], _index_Timers_to_Functions);
      switch (argList.length) {
         case 0:
            func();
            break;
         case 1:
            func(argList[0]);
            break;
         case 2:
            func(argList[0], argList[1]);
            break;
         case 3:
            func(argList[0], argList[1], argList[2]);
            break;
         case 4:
            func(argList[0], argList[1], argList[2], argList[3]);
            break;
         case 5:
            func(argList[0], argList[1], argList[2], argList[3], argList[4]);
            break;
         default:
            Log.error("Utils_Timer.onTimerComplete() - No case for " + argList.length + " arguments. Too many arguments");
      }
   }

}
}

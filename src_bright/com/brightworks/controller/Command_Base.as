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
package com.brightworks.controller {
import com.brightworks.base.Callbacks;
import com.brightworks.util.AppActiveElapsedTimeTimer;
import com.brightworks.util.Log;
import com.brightworks.util.Utils_System;

import flash.events.TimerEvent;

public class Command_Base {
   protected var callbacks:Callbacks;

   private var _timeoutTimer:AppActiveElapsedTimeTimer;
   private var _timeoutTimerCompleteFunction:Function;


   // --------------------------------------------
   //
   //           Public Methods
   //
   // --------------------------------------------

   public function Command_Base() {
      CommandManager.addCommand(this);
   }


   public function dispose():void {
      stopTimeoutTimer();
      CommandManager.removeCommand(this);
   }

   public function fault(info:Object = null):void {
      if (callbacks && (callbacks.fault is Function)) {
         callbacks.fault(info);
      }
      else {
         Log.fatal(["Command_Base.fault()", info]);
      }
   }

   public function result(data:Object = null):void {
      if (callbacks && (callbacks.result is Function)) {
         callbacks.result(data);
      }
      else {
         Log.fatal(["Command_Base.result(): result function instance isn't available", data]);
      }
   }

   public function update(data:Object = null):void {
      if (callbacks && (callbacks.update is Function)) {
         callbacks.update(data);
      }
      else {
         Log.fatal(["Command_Base.update(): update function instance isn't available", data]);
      }
   }

   // --------------------------------------------
   //
   //           Protected Methods
   //
   // --------------------------------------------

   protected function startOrRestartTimeoutTimer(timeoutMS:uint, timerCompleteFunction:Function):void {
      Log.debug("Command_Base.startOrRestartTimeoutTimer()");
      if (Utils_System.isRunningOnDesktop())
         timeoutMS = timeoutMS * 10;
      _timeoutTimerCompleteFunction = timerCompleteFunction;
      stopTimeoutTimer();
      _timeoutTimer = new AppActiveElapsedTimeTimer(timeoutMS);
      _timeoutTimer.addEventListener(TimerEvent.TIMER_COMPLETE, timerCompleteFunction);
      _timeoutTimer.start();
   }

   protected function stopTimeoutTimer():void {
      Log.debug("Command_Base.stopTimer()");
      if (_timeoutTimer) {
         _timeoutTimer.stop();
         _timeoutTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, _timeoutTimerCompleteFunction);
         _timeoutTimer = null;
      }
   }
}
}

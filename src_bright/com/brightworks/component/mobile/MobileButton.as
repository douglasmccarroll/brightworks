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
package com.brightworks.component.mobile {
import com.brightworks.constant.Constant_Misc;
import com.brightworks.interfaces.IDisposable;
import com.brightworks.util.audio.Utils_Audio_Files;
import com.brightworks.util.Utils_DateTime;

import flash.events.Event;
import flash.events.MouseEvent;

import spark.components.Button;

public class MobileButton extends Button implements IDisposable {
   public var clickSoundEnabled:Boolean = true;

   private var _isDisposed:Boolean;
   private var _mostRecentClickTime:Number;

   public function MobileButton() {
      super();
      addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
      addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
   }

   public function dispose():void {
      if (_isDisposed)
         return;
      _isDisposed = false;
      removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
      removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
   }

   private function onMouseDown(event:MouseEvent):void {
      if (_mostRecentClickTime > 0) {
         var currentTime:Number = Utils_DateTime.getCurrentMS_BasedOnDate();
         var timeSinceLastClick:Number = currentTime - _mostRecentClickTime;
         if (timeSinceLastClick <= Constant_Misc.USER_ACTION_REQUIRED_WAIT_INTERVAL)
            return;
      }
      _mostRecentClickTime = Utils_DateTime.getCurrentMS_BasedOnDate();
      if (clickSoundEnabled)
         Utils_Audio_Files.CLICK.play();
   }

   private function onRemovedFromStage(event:Event):void {
      dispose();
   }
}
}

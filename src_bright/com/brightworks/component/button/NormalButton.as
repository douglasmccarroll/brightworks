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





dmccarroll 20121122
We call this button "Normal" because it's just a standard Spark button with
vibration and a click sound added. If you want to apply styling it would probably be best to
subclass it, and style the subclass.


*/
package com.brightworks.component.button {
import com.brightworks.constant.Constants_Misc;
import com.brightworks.interfaces.IDisposable;
import com.brightworks.util.audio.Utils_Audio_Files;
import com.brightworks.util.Utils_DateTime;

import flash.events.Event;
import flash.events.MouseEvent;

import spark.components.Button;

public class NormalButton extends Button implements IDisposable {
   public var clickSoundEnabled:Boolean = true;

   private var _isDisposed:Boolean;
   private var _mostRecentClickTime:Number;

   public function NormalButton() {
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
      if ((_mostRecentClickTime > 0) && ((Utils_DateTime.getCurrentMS_BasedOnDate() - _mostRecentClickTime) <= Constants_Misc.USER_ACTION_REQUIRED_WAIT_INTERVAL))
         return;
      _mostRecentClickTime = Utils_DateTime.getCurrentMS_BasedOnDate();
      if (clickSoundEnabled)
         Utils_Audio_Files.playClick();
   }

   private function onRemovedFromStage(event:Event):void {
      dispose();
   }
}
}

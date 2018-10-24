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
We call this list "Normal" because it's just a standard Spark List with
vibratio and a click soundn added. If you want to apply styling it would probably be best to
subclass it, and style the subclass.


*/
package com.brightworks.component.list {
import com.brightworks.interfaces.IDisposable;
import com.brightworks.resource.Resources_Audio;

import flash.events.Event;

import spark.components.List;
import spark.events.IndexChangeEvent;

public class NormalList extends List implements IDisposable {
   public var clickSoundEnabled:Boolean = true;

   private var _isDisposed:Boolean;

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
   //
   //          Public Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

   public function NormalList() {
      super();
      addEventListener(IndexChangeEvent.CHANGE, onChange);
      addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
   }

   public function dispose():void {
      if (_isDisposed)
         return;
      _isDisposed = true;
      removeEventListener(IndexChangeEvent.CHANGE, onChange);
      removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
   }

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
   //
   //          Private Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   private function onChange(event:IndexChangeEvent):void {
      if (clickSoundEnabled)
         Resources_Audio.playClick();
   }

   private function onRemovedFromStage(event:Event):void {
      dispose();
   }

}
}

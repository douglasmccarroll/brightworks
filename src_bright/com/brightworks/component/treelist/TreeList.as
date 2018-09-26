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
package com.brightworks.component.treelist {
import com.brightworks.event.Event_TreeList;
import com.brightworks.interfaces.IDisposable;
import com.brightworks.resource.Resources_Audio;

import flash.events.Event;

import spark.components.List;
import spark.events.IndexChangeEvent;

public class TreeList extends List implements IDisposable {
   public var clickSoundEnabled:Boolean = true;

   private var _isDisposed:Boolean;

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
   //
   //          Public Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

   public function TreeList() {
      super();
      allowMultipleSelection = true;
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
   //          Protected Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

   // dmccarroll 20120728
   // I haven't researched this with great thoroughness, but it appears that this is only called when:
   //    a. An item is selected or deselected, AND
   //    b. allowMultipleSelection = true
   // It also appears that this method is only called once each time this happens.
   // All of which, fortunately, is just what we want.  :)
   // Why not listen for change events, or let the client code do so? Two reasons:
   //    a. Change events occur whether or not allowMultipleSelection equals true.
   //    b. I'm seeing multiple change events, with multiple indexes, in response to a single click.
   //       20121123 update: I'm not seeing this now - I'm only seeing one change event per change
   // Why not override item_mouseDownHandler()? Because it is called immediately, before the List knows
   // whether the user is selecting or dragging.
   override protected function calculateSelectedIndices(index:int, shiftKey:Boolean, ctrlKey:Boolean):Vector.<int> {
      if ((index >= 0) && (dataProvider) && (index < dataProvider.length)) {
         callLater(dispatchEvent_ToggleLeafItem, [dataProvider.getItemAt(index)]);
      }
      return super.calculateSelectedIndices(index, shiftKey, ctrlKey);
   }

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
   //
   //          Private Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   private function dispatchEvent_ToggleLeafItem(item:Object):void {
      var e:Event_TreeList = new Event_TreeList(Event_TreeList.TOGGLE_LEAF_ITEM);
      e.leafData = item;
      dispatchEvent(e);
   }

   private function onChange(event:IndexChangeEvent):void {
      if (clickSoundEnabled)
         Resources_Audio.CLICK.play();
   }

   private function onRemovedFromStage(event:Event):void {
      dispose();
   }

}
}


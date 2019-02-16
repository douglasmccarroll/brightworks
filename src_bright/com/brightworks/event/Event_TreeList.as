package com.brightworks.event {
public class Event_TreeList extends BwEvent {
   public static const TOGGLE_LEAF_ITEM:String = "event_TreeList_ToggleLeafItem";

   public var leafData:Object;

   public function Event_TreeList(type:String) {
      super(type);
   }
}
}

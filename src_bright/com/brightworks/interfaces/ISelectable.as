package com.brightworks.interfaces {

public interface ISelectable {

   function get isSelectable():Boolean; // Sometimes selectable things aren't selectable :)
   function get isSelected():Boolean;

   function set isSelected(value:Boolean):void;

}
}

package com.brightworks.util {
public class Color {

   public var alpha:uint;
   public var blue:uint;
   public var green:uint;
   public var red:uint;

   public function get value():uint {
      return red + (green * 256) + (blue * 256 * 256);
   }

   public function Color() {
   }
}
}

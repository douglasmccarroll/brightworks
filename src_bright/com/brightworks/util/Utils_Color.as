/*
 Copyright 2020 Brightworks, Inc.

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

public class Utils_Color {

   // Use AS ColorTransform class to brighten/darken display objects
   // Use mx.utils.ColorUtil to compute brightness-adjusted colors

   public static function createColor(colorValue:uint):Color {
      var color:Color = new Color();
      if (colorValue > 0xFFFFFF) {
         // Color is 32 bit color
         color.alpha = (colorValue >>> 24);
         color.red = (colorValue >>> 16) & 0xFF;
      }
      else {
         // Color is 24 bit color
         color.alpha = NaN;
         color.red = (colorValue >>> 16) & 0xFF;
      }
      color.green = (colorValue >>> 8) & 0xFF;
      color.blue = colorValue & 0xFF;
      return color;
   }

}
}




















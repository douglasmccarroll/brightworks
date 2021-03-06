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
package com.brightworks.util {
import flash.display.BitmapData;
import flash.geom.Matrix;

import mx.core.UIComponent;

public class Utils_Bitmap {
   public static function getUIComponentBitmapData(target:UIComponent):BitmapData {
      // With thanks to Andrew Trice
      var bd:BitmapData = new BitmapData(target.width, target.height);
      var m:Matrix = new Matrix();
      bd.draw(target, m);
      return bd;
   }
}
}

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
package com.brightworks.util {
import flash.system.Capabilities;

import mx.core.UIComponent;

import spark.components.supportClasses.GroupBase;
import spark.layouts.HorizontalLayout;
import spark.layouts.VerticalLayout;
import spark.layouts.supportClasses.LayoutBase;

public class Utils_Layout {
   public static function getScreenSquareInches():Number {
      /// does stage.stageHeight and stageWith work better on the desktop?
      var pixelsPerSquareInch:Number = Capabilities.screenDPI * Capabilities.screenDPI;
      var screenPixels:Number = Capabilities.screenResolutionX * Capabilities.screenResolutionY;
      var result:Number = screenPixels / pixelsPerSquareInch;
      return result;
   }

   public static function getStandardPadding():int {
      return Math.round(Utils_System.dpi / 20);
   }

   public static function getParentLayout(comp:UIComponent):LayoutBase {
      if (!comp.parent)
         return null;
      if (!(comp.parent is GroupBase))
         return null;
      return GroupBase(comp.parent).layout;
   }

   public static function getParentPaddingRight(comp:UIComponent):Number {
      var layout:LayoutBase = Utils_Layout.getParentLayout(comp);
      if (!layout)
         return 0;
      if (layout is HorizontalLayout)
         return HorizontalLayout(layout).paddingRight;
      if (layout is VerticalLayout)
         return VerticalLayout(layout).paddingRight;
      return 0;
   }

   public static function getParentPaddingLeft(comp:UIComponent):Number {
      var layout:LayoutBase = Utils_Layout.getParentLayout(comp);
      if (!layout)
         return 0;
      if (layout is HorizontalLayout)
         return HorizontalLayout(layout).paddingLeft;
      if (layout is VerticalLayout)
         return VerticalLayout(layout).paddingLeft;
      return 0;
   }

}
}


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
package com.brightworks.component.itemrenderer {
import com.brightworks.constant.Constant_Color;
import com.brightworks.util.Utils_Text;

import flash.system.Capabilities;

import spark.components.LabelItemRenderer;

public class BwLabelItemRenderer extends LabelItemRenderer {
   public function BwLabelItemRenderer() {
      super();
      setStyle("fontSize", Utils_Text.getStandardFontSize() * 1.5);
   }

   override protected function drawBackground(unscaledWidth:Number, unscaledHeight:Number):void {
      if (unscaledHeight == 0)
         return;
      var c:uint;
      c = selected ? Constant_Color.LIST_ITEM_BACKGROUND__SELECTED : Constant_Color.LIST_ITEM_BACKGROUND;
      graphics.beginFill(c, 1);
      graphics.drawRect(0, 0, unscaledWidth, unscaledHeight);
      graphics.endFill();
      graphics.lineStyle(1, 0xC0C0C0);
      graphics.moveTo(0, unscaledHeight - 1);
      graphics.lineTo(unscaledWidth, unscaledHeight - 1);
      graphics.lineStyle(1, 0xFFFFFF);
      graphics.moveTo(0, unscaledHeight);
      graphics.lineTo(unscaledWidth, unscaledHeight);
   }

   override protected function measure():void {
      super.measure();
      measuredHeight = measuredMinHeight = Capabilities.screenDPI * .5;
   }

}
}

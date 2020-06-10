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




This code is based on the code provided at
http://flexponential.com/2011/08/21/adding-multiline-text-support-to-labelitemrenderer/
by Steven Shongrunden



*/
package com.brightworks.component.itemrenderer {
import mx.core.DPIClassification;

public class MultilineLabelItemRenderer extends BwLabelItemRenderer {
   private var _oldUnscaledWidth:Number;

   public function MultilineLabelItemRenderer() {
      super();
      if (applicationDPI == DPIClassification.DPI_480)
         _oldUnscaledWidth = 960;
      else if (applicationDPI == DPIClassification.DPI_320)
         _oldUnscaledWidth = 640
      else if (applicationDPI == DPIClassification.DPI_240)
         _oldUnscaledWidth = 480
      else // 160 dpi
         _oldUnscaledWidth = 320
   }

   override protected function createLabelDisplay():void {
      super.createLabelDisplay();
      labelDisplay.multiline = true;
      labelDisplay.wordWrap = true;
   }

   override protected function measure():void {
      super.measure();
      var horizontalPadding:Number = getStyle("paddingLeft") + getStyle("paddingRight");
      var verticalPadding:Number = getStyle("paddingTop") + getStyle("paddingBottom");
      // now we need to measure labelDisplay's height.  Unfortunately, this is tricky and
      // is dependent on labelDisplay's width.  We use the old unscaledWidth as an
      // estimate for the new one.  If this estimate is wrong then there is code in
      // updateDisplayList() that will trigger a new measure pass to correct it.
      var labelDisplayEstimatedWidth:Number = _oldUnscaledWidth - horizontalPadding;
      setElementSize(labelDisplay, labelDisplayEstimatedWidth, NaN);
      measuredWidth = getElementPreferredWidth(labelDisplay) + horizontalPadding;
   }

   override protected function layoutContents(unscaledWidth:Number, unscaledHeight:Number):void {
      if (!labelDisplay)
         return;
      var paddingLeft:Number = getStyle("paddingLeft");
      var paddingRight:Number = getStyle("paddingRight");
      var paddingTop:Number = getStyle("paddingTop");
      var paddingBottom:Number = getStyle("paddingBottom");
      var verticalAlign:String = getStyle("verticalAlign");
      var viewWidth:Number = unscaledWidth - paddingLeft - paddingRight;
      var viewHeight:Number = unscaledHeight - paddingTop - paddingBottom;
      var vAlign:Number;
      if (verticalAlign == "top")
         vAlign = 0;
      else if (verticalAlign == "bottom")
         vAlign = 1;
      else // if (verticalAlign == "middle")
         vAlign = 0.5;
      if (label != "") {
         labelDisplay.commitStyles();
      }
      // Size the labelDisplay
      //   we want the labelWidth to be the viewWidth and then we'll calculate the height
      //   of the text from that
      var labelWidth:Number = Math.max(viewWidth, 0);
      // keep track of the old label height
      var oldPreferredLabelHeight:Number = 0;
      // We get called with unscaledWidth = 0 a few times...
      // rather than deal with this case normally,
      // we can just special-case it later to do something smarter
      if (labelWidth == 0) {
         // if unscaledWidth is 0, we want to make sure labelDisplay is invisible.
         // we could set labelDisplay's width to 0, but that would cause an extra
         // layout pass because of the text reflow logic.  To avoid that we can
         // just set its height to 0 instead of setting the width.
         setElementSize(labelDisplay, NaN, 0);
      }
      else {
         // grab old height before we resize the labelDisplay
         oldPreferredLabelHeight = getElementPreferredHeight(labelDisplay);
         // keep track of oldUnscaledWidth so we have a good guess as to the width
         // of the labelDisplay on the next measure() pass
         _oldUnscaledWidth = unscaledWidth;
         // set the width of labelDisplay to labelWidth.
         // set the height to old label height.  If the height's actually wrong,
         // we'll invalidateSize() and go through this layout pass again anyways
         setElementSize(labelDisplay, labelWidth, oldPreferredLabelHeight);
         // grab new labelDisplay height after the labelDisplay has taken its final width
         var newPreferredLabelHeight:Number = getElementPreferredHeight(labelDisplay);
         // if the resize caused the labelDisplay's height to change (because of
         // text reflow), then we need to re-measure ourselves with our new width
         if (oldPreferredLabelHeight != newPreferredLabelHeight)
            invalidateSize();
      }
      // Position the labelDisplay
      var labelY:Number = Math.round(vAlign * (viewHeight - oldPreferredLabelHeight)) + paddingTop;
      setElementPosition(labelDisplay, paddingLeft, labelY);
   }
}
}

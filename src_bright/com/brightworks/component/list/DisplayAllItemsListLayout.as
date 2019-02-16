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
package com.brightworks.component.list {
import mx.core.ILayoutElement;
import mx.core.mx_internal;

import spark.components.supportClasses.GroupBase;
import spark.layouts.supportClasses.LayoutBase;

use namespace mx_internal;

public class DisplayAllItemsListLayout extends LayoutBase {

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   //
   //          Getters / Setters
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   private var _rowCount:int = -1;

   public function get rowCount():int {
      return _rowCount;
   }

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   //
   //          Public Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   public function DisplayAllItemsListLayout():void {
      super();
      // Don't drag-scroll in the horizontal direction
      dragScrollRegionSizeHorizontal = 0;
   }

   override public function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
      super.updateDisplayList(unscaledWidth, unscaledHeight);
      var layoutTarget:GroupBase = target;
      // This if clause became necessary when we turned useVirtualLayout off, and the code below started using
      // getElementAt() rather than getVirtualElementAt(). See DisplayAllItemsList.createChildren() for an explanation
      // of why we turned useVirtualLayout off.
      if (!layoutTarget.getElementAt(0))
         return;
      if ((!layoutTarget) || (layoutTarget.numElements < 0)) {
         _rowCount = -1;
         return;
      }
      _rowCount = layoutTarget.numElements;
      if (_rowCount == 0)
         return;
      var consumedVerticalSpace:uint = 0;
      for (var i:int = 0; i < _rowCount; i++) {
         var layoutElement:ILayoutElement = useVirtualLayout ?
               layoutTarget.getVirtualElementAt(i) :
               layoutTarget.getElementAt(i);
         layoutElement.setLayoutBoundsPosition(0, consumedVerticalSpace);
         var remainingRows:uint = (_rowCount - i);
         var remainingVerticalSpace:uint = layoutTarget.height - consumedVerticalSpace;
         var rowHeight:uint = Math.floor(remainingVerticalSpace / remainingRows);
         layoutElement.setLayoutBoundsSize(layoutTarget.width, rowHeight);
         consumedVerticalSpace += rowHeight;
      }
   }
}
}


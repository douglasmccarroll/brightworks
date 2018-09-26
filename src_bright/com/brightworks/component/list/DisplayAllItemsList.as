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

public class DisplayAllItemsList extends NormalList {
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
   //
   //          Public Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

   public function DisplayAllItemsList() {
      super();
      layout = new DisplayAllItemsListLayout();
   }

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
   //
   //          Protected Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   override protected function createChildren():void {
      super.createChildren();
      // dmccarroll 20121126
      // The next line fixes a bug - the list would go blank if/when the user dragged it. I haven't been able to figure out why this
      // was happening - it could have to do with ItemRenderer_LearningModeList or with DisplayAllItemsListLayout - but this fixes the
      // problem. As we always want all items displayed, and don't want this list to scroll, this fix should do no harm.
      useVirtualLayout = false;
   }

}
}

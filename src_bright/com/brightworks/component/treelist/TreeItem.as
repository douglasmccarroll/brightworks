package com.brightworks.component.treelist {
import com.brightworks.interfaces.IDisposable;
import com.brightworks.util.Utils_Dispose;

import mx.collections.ArrayCollection;

public class TreeItem implements IDisposable {
   public var children:ArrayCollection;
   public var data:Object;
   public var iconClass:Class;
   public var isLeaf:Boolean;
   public var label:String;
   public var levelDisplayName:String;
   public var sortInfo:Object;
   public var parent:TreeItem;

   private var _isDisposed:Boolean = false;

   public function TreeItem() {
   }

   public function areAllChildrenLeafs():Boolean {
      var result:Boolean = true;
      for each (var treeItem:TreeItem in children) {
         if (!treeItem.isLeaf) {
            result = false;
            break;
         }
      }
      return result;
   }

   // Called (indirectly) by MainModel.set downloadedLessonSelectionTreeData();
   public function dispose():void {
      if (_isDisposed)
         return;
      _isDisposed = true;
      if (children) {
         Utils_Dispose.disposeArrayCollection(children, true);
      }
      data = null;
      parent = null;
   }

}
}

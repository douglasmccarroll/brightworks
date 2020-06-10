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
import com.brightworks.interfaces.IDisposable;

import flash.utils.Dictionary;

import mx.collections.ArrayCollection;

public class Utils_Dispose {
   public function Utils_Dispose() {
   }

   public static function disposeArray(a:Array, bDeepDispose:Boolean):void {
      if (!a) {
         return;
      }
      for each (var o:Object in a) {
         if ((o is IDisposable) && (bDeepDispose))
            IDisposable(o).dispose();
         else if (o is ArrayCollection)
            Utils_Dispose.disposeArrayCollection(ArrayCollection(o), bDeepDispose);
         else if (o is Array)
            Utils_Dispose.disposeArray(o as Array, bDeepDispose);
         else if (o is Dictionary)
            Utils_Dispose.disposeDictionary(Dictionary(o), bDeepDispose);
      }
      a.splice(0, a.length);
   }

   public static function disposeArrayCollection(a:ArrayCollection, bDeepDispose:Boolean):void {
      a.disableAutoUpdate();
      for each (var o:Object in a) {
         if ((o is IDisposable) && (bDeepDispose))
            IDisposable(o).dispose();
         else if (o is ArrayCollection)
            Utils_Dispose.disposeArrayCollection(ArrayCollection(o), bDeepDispose);
         else if (o is Array)
            Utils_Dispose.disposeArray(o as Array, bDeepDispose);
         else if (o is Dictionary)
            Utils_Dispose.disposeDictionary(Dictionary(o), bDeepDispose);
      }
      a.removeAll();
   }

   public static function disposeDictionary(d:Dictionary, bDeepDispose:Boolean):void {
      for (var o:Object in d) {
         var val:Object = d[o];
         if ((o is IDisposable) && (bDeepDispose))
            IDisposable(o).dispose();
         else if (o is ArrayCollection)
            Utils_Dispose.disposeArrayCollection(ArrayCollection(o), bDeepDispose);
         else if (o is Array)
            Utils_Dispose.disposeArray(o as Array, bDeepDispose);
         else if (o is Dictionary)
            Utils_Dispose.disposeDictionary(Dictionary(o), bDeepDispose);
         if ((val is IDisposable) && (bDeepDispose))
            IDisposable(val).dispose();
         else if (val is ArrayCollection)
            Utils_Dispose.disposeArrayCollection(ArrayCollection(val), bDeepDispose);
         else if (val is Array)
            Utils_Dispose.disposeArray(val as Array, bDeepDispose);
         else if (val is Dictionary)
            Utils_Dispose.disposeDictionary(Dictionary(val), bDeepDispose);
         delete d[o];
      }
   }

}
}


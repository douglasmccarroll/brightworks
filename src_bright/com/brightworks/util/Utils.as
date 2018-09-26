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
import flash.utils.describeType;

public class Utils {
   public function Utils():void {
   }

   public static function dump(o:Object):void {
      //race("Dump for " + getFullyQualdType(o))
      var i:int = 0;
      for (var prop:* in o) {
         i++;
         var val:* = o[prop];
         var propType:String = typeof prop;
         var valType:String = typeof val;
         //race("  " + String(i) + ":")
         //race("    Prop: " + String(prop) + ": " + getFullyQualdType(prop))
         //race("    Val:  " + String(val ) + ": " + getFullyQualdType(val ))
      }
   }

   public static function getFullyQualdType(o:Object):String {
      var x:XML = describeType(o);
      var s:String = x.@name;
      return s;
   }
}
}


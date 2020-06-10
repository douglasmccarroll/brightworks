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
import flash.display.DisplayObjectContainer;


public class Utils_Misc {

   // The random string that this function creates doesn't meet the criteria for a true UUID, but it's good enough to satisfy Google Analytics
   public static function generateImitationUUIDString(value:Array = null):String {
      var uid:Array = new Array();
      var chars:Array = new Array(48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 65, 66, 67, 68, 69, 70);
      var separator:uint = 45;
      var template:Array = value || new Array(8, 4, 4, 4, 12);
      for (var a:uint = 0; a < template.length; a++) {
         for (var b:uint = 0; b < template[a]; b++) {
            uid.push(chars[Math.floor(Math.random() * chars.length)]);
         }
         if (a < template.length - 1) {
            uid.push(separator);
         }
      }
      var result:String = String.fromCharCode.apply(null, uid);
      return result;
   }

   public static function getFirstDisplayListAncestorThatIsInstanceOfClassOrInstanceOfSubclass(comp:DisplayObjectContainer, clazz:Class):DisplayObjectContainer {
      var currComp:DisplayObjectContainer = comp;
      var result:DisplayObjectContainer;
      while (true) {
         if (currComp.parent) {
            if (currComp.parent is clazz) {
               result = currComp.parent;
               break;
            }
            else {
               currComp = currComp.parent;
            }
         }
         else {
            break;
         }
      }
      return result;
   }


}
}









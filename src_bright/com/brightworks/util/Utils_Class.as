/*
Copyright 2008 - 2013 Brightworks, Inc.

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
import mx.utils.ObjectUtil;

public class Utils_Class {
   // To get get reference to Class from class name use
   //     flash.utils.getDefinitionByName(name:String):Object

   public static function getInstanceType(instance:Object, fullyQuald:Boolean = true):String {
      var name:String;
      if (instance is String) {
         name = "String";
      } else {
         var ci:Object = ObjectUtil.getClassInfo(instance);
         name = ci.name;
      }
      if (!fullyQuald) {
         if (name.indexOf("::") != -1) {
            name = Utils_String.getCharsAfterSubstring(name, "::");
         }
      }
      return name;
   }
}
}


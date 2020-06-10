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


public class Utils_URL {
   public static const FILEPATHINFO__DESKTOP_SERVER_STRING:String = "//127.0.0.1/";   // changed this from 'localhost' because I was getting "Error #2032: Stream Error" with localhost

   public static function convertUrlToDesktopServerUrl(url:String):String {
      var result:String = Utils_String.replaceAll(url, "//", FILEPATHINFO__DESKTOP_SERVER_STRING);
      return result;
   }

   public static function isUrlProperlyFormed(url:String):Boolean {
      if (url.substr(0, 4) != "http")
         return false;
      if (url.indexOf("//") == -1)
         return false;
      if (Utils_String.getCountOfSubstringInString(url, "//") != 1)
         return false;
      if (url.indexOf(".") == -1)
         return false;
      if (url.indexOf(".") > (url.length - 3))
         return false;
      return true;
   }
}
}









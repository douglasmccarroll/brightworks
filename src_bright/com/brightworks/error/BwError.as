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
/// review these comments - things have changed
/*
    This class is designed to work with our Log.fatal() method.

    Classes that aren't qualified to specify a user-friendly error message throw these errors. They
    can set its .errorInfo prop to any kind of object - hopefully one that contains information that will
    be useful in a log file - and this includes an array of such objects. See the Debug class for more
    details on how this information will be used.

    When this error is caught by a class that is qualified to create a user-friendly error message, that
    class should handle it as follows:
        - Get its .message property and create a user-friendly message based on the type
        - Get its .errorInfoArray property
        - Use Array.unshift() to add the message to the beginning of the array
        - Pass the array into Log.fatal();

    Note that when we say "user-friendly" we mean a fairly technically oriented user who will be looking
    at all the detailed error data. The Log.fatal() method displays a generic error message when an error
    occurs.
*/
package com.brightworks.error {
import mx.utils.ArrayUtil;

public class BwError extends Error {
   private var _errorInfo:Object;

   public function set errorInfo(o:Object):void {
      _errorInfo = o;
   }

   public function get errorInfoArray():Array {
      var a:Array = ArrayUtil.toArray(_errorInfo);
      return a;
   }

   public function BwError(message:String, errorInfo:Object = null) {
      super(message)
      _errorInfo = errorInfo;
   }
}
}


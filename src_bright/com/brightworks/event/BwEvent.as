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
package com.brightworks.event {
import com.brightworks.base.Callbacks;
import com.brightworks.techreport.ITechReport;

import flash.events.Event;

import mx.utils.ArrayUtil;

public class BwEvent extends Event {
   public static const COMPLETE:String = "complete";
   public static const FAILURE:String = "failure";
   public static const NEW_INFO:String = "newInfo";
   public static const NO_INTERNET_CONNECTION:String = "noInternetConnection";

   public var callbacks:Callbacks;
   public var cause:Object;
   public var techReport:ITechReport;

   private var _info:Object; // Can be an object or an array, suitable for logging

   public function get infoArray():Array {
      var a:Array = ArrayUtil.toArray(_info);
      return a;
   }

   public function BwEvent(type:String, techReport:ITechReport = null, info:Object = null) {
      super(type, true);
      this.techReport = techReport;
      _info = info;
   }

}
}

/*
Copyright 2021 Brightworks, Inc.

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
package com.brightworks.base {

public class Callbacks {
   public var fault:Function;
   public var result:Function;
   public var update:Function;

   public function Callbacks(result:Function, fault:Function = null, update:Function = null) {
      this.fault = fault;
      this.result = result;
      this.update = update;
   }

   public function dispose():void {
      fault = null;
      result = null;
      update = null;
   }
}
}

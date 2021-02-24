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
package com.brightworks.service {
import com.brightworks.util.Log;

import mx.rpc.IResponder;

public class BwAsyncResponder implements IResponder {
   private var resultHandler:Function;
   private var faultHandler:Function;
   private var handlerArgs:Array;

   public function BwAsyncResponder(resultHandler:Function, faultHandler:Function = null, handlerArgs:Array = null) {
      this.resultHandler = resultHandler;
      this.faultHandler = faultHandler;
      this.handlerArgs = handlerArgs;
   }

   public function result(data:Object):void {
      if (!(handlerArgs)) {
         resultHandler(data);
      }
      else {
         resultHandler.apply(null, [data].concat(handlerArgs));
      }
   }

   public function fault(info:Object):void {
      if (faultHandler != null) {
         if (handlerArgs == null) {
            faultHandler(info);
         }
         else {
            try {
               faultHandler(info);
            }
            catch (e:Error) {
               faultHandler.apply(null, [info].concat(handlerArgs));
            }
         }
      }
      else {
         Log.warn(["BwAsyncResponder.fault(): No faultHandler", info]);
      }
   }
}
}

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
package com.brightworks.vo {
import com.brightworks.interfaces.IDisposable;
import com.brightworks.util.Log;
import com.brightworks.util.Utils_Dispose;
import com.brightworks.util.Utils_Object;

import flash.events.EventDispatcher;
import flash.utils.Dictionary;

public class VO extends EventDispatcher implements IDisposable {
   protected var setPropList:Array; // We record props that are set here, but only those that != null when not set - it's easy enough to know when those aren't set by looking for 'null'.

   private var _isDisposed:Boolean = false;

   // --------------------------------------------
   //
   //           Public Methods
   //
   // --------------------------------------------

   public function VO() {
      setPropList = [];
   }

   public function clone():VO {
      return Utils_Object.cloneInstance(this);
   }

   public function dispose():void /// needs to be called, but where/when? - save in many cases
   {
      if (_isDisposed)
         return;
      _isDisposed = true;
      if (setPropList) {
         Utils_Dispose.disposeArray(setPropList, true);
         setPropList = null;
      }
   }

   public function getClass():Class {
      throw new Error("VO.getClass(): abstract method called");
      return null;
   }

   public function getPropInfoList():Dictionary {
      throw new Error("VO.getPropNameArrayList(): abstract method called");
      return null;
   }

   public function getAssociatedTableName():String {
      throw new Error("VO.getAssociatedTableName(): abstract method called");
      return null;
   }

   // (DLM 200908) See comments in IVO Interface
   public function getPropNameList_SetProps():Array {
      var result:Array = setPropList.slice();
      var propInfoList:Dictionary = getPropInfoList();
      var propName:String;
      var propType:String;
      var propValue:Object;
      for (propName in propInfoList) {
         propType = propInfoList[propName];
         propValue = this[propName];
         switch (propType) {
            case "Boolean":
            case "int":
            case "Number":
            case "uint":
               // Properties of these types are contained in _setPropList, which our
               // result var is a copy of. We can't figure out whether they are set
               // by looking at their values, because when unset their values aren't
               // 'null' - they are 0 or false.
               break;
            case "String":
            case "Date": {
               if (propValue != null) {
                  result.push(propName);
               }
               break;
            }
            default: {
               Log.fatal("VO.getPropNameList_SetProps(): No case for propType of '" + propType + "'");
            }
         }
      }
      return result;
   }

   public function isReferencingInstance(vo:VO):Boolean {
      // We can't do the following here, because referencing VOs have different prop names from ref'd VOs.
      // And we don't want to change this if we can avoid it, because using different names improves clarity.
      /*for each (var propName:String in IVO(this).getPropNameList_KeyProps())
      {
          if ((!vo.hasOwnProperty(propName)) || (vo[propName] != this[propName]))
              return false;
      }
      return true;*/
      Log.warn("VO.isReferencingInstance(): Static method - should not be called.");
      return false;
   }

   // --------------------------------------------
   //
   //           Protected Methods
   //
   // --------------------------------------------

   protected function doKeyPropsMatch(o:Object):Boolean {
      var keyPropList:Array = IVO(this).getPropNameList_KeyProps();
      for each (var propName:String in keyPropList) {
         if (!o.hasOwnProperty(propName))
            return false;
         if (o[propName] != this[propName])
            return false;
      }
      return true;
   }

   protected function extractPropInfoList():Dictionary {
      return Utils_Object.getInstancePropInfoList(this);
   }

   protected function extractAssociatedTableName():String {
      var result:String = Utils_Object.getClassNameForInstance(this);
      var testString:String = result.substring(result.length - 2, result.length);
      if (testString != "VO") {
         Log.fatal("VO.extractTableName(): VO class name (" + result + ") does not end with 'VO'");
      }
      result = result.substring(0, result.length - 2);
      return result;
   }
}
}

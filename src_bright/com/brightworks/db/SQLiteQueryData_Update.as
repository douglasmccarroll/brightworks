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
/*
        Notes:

            1. See notes on dates in SQLiteQueryData_Insert

*/
package com.brightworks.db {
import com.brightworks.util.Log;
import com.brightworks.util.Utils_ArrayVectorEtc;
import com.brightworks.vo.IVO;

import flash.utils.Dictionary;

public class SQLiteQueryData_Update extends SQLiteQueryData {
   private var _index_propNames_to_selectValues:Dictionary;
   private var _isSingleRecordUpdate:Boolean;
   private var _updatedPropNames:Array;

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   //
   //          Public Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   // vo arg contains "update to" values for the props specified in updatedPropNames /// can we use getPropNameList_SetProps() instead of updatedPropNames?
   public function SQLiteQueryData_Update(
         vo:IVO,
         updatedPropNames:Array,
         isSingleRecordUpdate:Boolean,
         index_propNames_to_selectValues:Dictionary = null) {
      super();
      for each (var updatedPropName:String in updatedPropNames) {
         if (!Object(vo).hasOwnProperty(updatedPropName))
            Log.fatal(["SQLiteQueryData_Update: VO doesn't contain updatedPropName of '" + updatedPropName + "': ", vo]);
      }
      this.vo = vo;
      _updatedPropNames = updatedPropNames;
      _index_propNames_to_selectValues = index_propNames_to_selectValues;
      confirmNotBothSingleRecordUpdateAndKeyPropsAreSpecifiedAsSelectValues();
      _isSingleRecordUpdate = isSingleRecordUpdate;
   }

   public function doesUpdateKeyProps():Boolean {
      return (getListOfKeyPropsBeingUpdated().length > 0);
   }

   public function getListOfKeyPropsBeingUpdated():Array {
      return Utils_ArrayVectorEtc.createStringArrayContainingStringsInOneArrayContainedBySecondStringArray(_updatedPropNames, vo.getPropNameList_KeyProps());
   }

   override public function getParameters():Object {
      var result:Object = {};
      for each (var propName:String in _updatedPropNames) {
         result[":" + propName + "UpdateValue"] = vo[propName];
      }
      if (_isSingleRecordUpdate) {
         for each (propName in vo.getPropNameList_KeyProps()) {
            if (result.hasOwnProperty(propName))
               continue;
            result[":" + propName] = vo[propName];
         }
      }
      if (_index_propNames_to_selectValues) {
         for (propName in _index_propNames_to_selectValues) {
            if (result.hasOwnProperty(propName))
               continue;
            result[":" + propName] = _index_propNames_to_selectValues[propName];
         }
      }
      return result;
   }

   override public function getSQLString():String {
      // UPDATE database-name.table-name SET assignment [, assignment]* [WHERE expr]
      var result:String =
            "UPDATE " +
            databaseName + "." +
            vo.getAssociatedTableName() +
            " SET ";
      var columnName:String;
      // Add column names
      var columnNameAdded:Boolean = false;
      for each (columnName in _updatedPropNames) {
         if (columnNameAdded)
            result += ", "
         result += columnName + "=:" + columnName + "UpdateValue";
         columnNameAdded = true;
      }
      // If this is a single-record update we use the passed VO's key prop values to specify the
      // record, plus any values in _index_propNames_to_selectValues. The additional values, if
      // any, have the effect of deciding whether the record will be updated or not.
      // If this is a multi-record update we use (only) values in _index_propNames_to_selectValues
      // to construct the SELECT clause. If none are supplied, all records in the specified table
      // are updated.
      var keyAdded:Boolean = false;
      if ((_isSingleRecordUpdate) ||
            ((_index_propNames_to_selectValues) && (Utils_ArrayVectorEtc.getDictionaryLength(_index_propNames_to_selectValues) > 0)))
         result = result + " WHERE "
      if (_isSingleRecordUpdate) {
         // Add values or, actually, parameters
         for each (columnName in vo.getPropNameList_KeyProps()) {
            if (keyAdded)
               result += " AND "
            result += columnName + "=:" + columnName;
            keyAdded = true;
         }
      }
      if (_index_propNames_to_selectValues) {
         // Add values or, actually, parameters
         for (columnName in _index_propNames_to_selectValues) {
            if (keyAdded)
               result += " AND "
            result += columnName + "=:" + columnName;
            keyAdded = true;
         }
      }
      // e.g. result = "UPDATE main.Chunk SET suppressed=:suppressedUpdateValue WHERE contentProviderId=:contentProviderId AND LessonVersionSignature=:LessonVersionSignature AND locationInOrder=:locationInOrder"
      return result;
   }

   override public function isRowsAffectedCountValid(count:Number):Boolean {
      if ((_isSingleRecordUpdate) && (count != 1))
         return false;
      return true;
   }

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   //
   //          Private Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   private function confirmNotBothSingleRecordUpdateAndKeyPropsAreSpecifiedAsSelectValues():void {
      if (!_isSingleRecordUpdate)
         return;
      if (!_index_propNames_to_selectValues)
         return;
      var keyPropNameList:Array = vo.getPropNameList_KeyProps();
      for (var selectPropName:String in _index_propNames_to_selectValues) {
         if (keyPropNameList.indexOf(selectPropName) != -1)
            Log.fatal("SQLiteQueryData_Update.confirmNotBothSingleRecordUpdateAndKeyPropsAreSpecifiedAsSelectValues() failed: 'select' prop name: " + selectPropName);
         break;
      }
   }

}
}














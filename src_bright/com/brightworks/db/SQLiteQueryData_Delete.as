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
package com.brightworks.db {
import com.brightworks.util.Log;
import com.brightworks.vo.IVO;

public class SQLiteQueryData_Delete extends SQLiteQueryData {
   
   public function SQLiteQueryData_Delete(
         vo:IVO,
         minAllowedRowsAffectedCount:Number = 0,
         maxAllowedRowsAffectedCount:Number = Number.MAX_VALUE) {
      super(minAllowedRowsAffectedCount, maxAllowedRowsAffectedCount);
      this.vo = vo;
   }

   override public function getParameters():Object {
      var result:Object = {};
      for each (var propName:String in vo.getPropNameList_KeyProps()) {
         if (result.hasOwnProperty(propName)) {
            Log.warn(["SQLiteQueryData_Delete.getParameters(): vo.getPropNameList_KeyProps() has '" + propName + "' listed more than once.", vo]);
            continue;
         }
         result[":" + propName] = vo[propName];
      }
      return result;
   }

   override public function getSQLString():String {
      // DELETE FROM database-name.table-name [WHERE expr] 
      var result:String =
            "DELETE FROM " +
            databaseName + "." +
            vo.getAssociatedTableName() +
            " WHERE ";
      var columnName:String;
      var keyAdded:Boolean = false;
      for each (columnName in vo.getPropNameList_KeyProps()) {
         if (keyAdded)
            result += " AND "
         result += columnName + "=:" + columnName;
         keyAdded = true;
      }
      // e.g. DELETE FROM main.LessonVersion WHERE contentProviderId=:contentProviderId AND lessonVersionSignature=:lessonVersionSignature	
      return result;
   }
}


}

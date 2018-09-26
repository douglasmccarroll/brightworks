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





        Notes:

            1. When inserting Date data can we just pass in a Date, using parameters of course,
               or do we have to get a Julian formatted date, e.g.
                    UPDATE my_table SET my_column = STRFTIME('%J','2008-01-02 03:04:05')
               as discussed at http://www.verysimple.com/blog/2008/09/09/working-with-dates-in-flex-air-and-sqlite/?

*/
package com.brightworks.db {
import com.brightworks.vo.IVO;

public class SQLiteQueryData_Insert extends SQLiteQueryData {
   public function SQLiteQueryData_Insert(
         vo:IVO,
         minAllowedRowsAffectedCount:Number = 0,
         maxAllowedRowsAffectedCount:Number = Number.MAX_VALUE) {
      super(minAllowedRowsAffectedCount, maxAllowedRowsAffectedCount);
      this.vo = vo;
   }

   override public function getParameters():Object {
      var result:Object = {};
      var setPropList:Array = vo.getPropNameList_SetProps();
      for each (var propName:String in setPropList) {
         result[":" + propName] = vo[propName];
      }
      return result;
   }

   override public function getSQLString():String {
      var result:String =
            "INSERT INTO " +
            databaseName + "." +
            vo.getAssociatedTableName() +
            " (";
      var columnName:String;
      var setPropList:Array = vo.getPropNameList_SetProps();
      // Add column names
      var columnNameAdded:Boolean = false;
      for each (columnName in setPropList) {
         if (columnNameAdded)
            result = result + ", "
         result = result + columnName;
         columnNameAdded = true;
      }
      result = result + ") VALUES ("
      // Add values or, actually, parameters
      var paramAdded:Boolean = false;
      for each (columnName in setPropList) {
         if (paramAdded)
            result = result + ", "
         result = result + ":" + columnName;
         paramAdded = true;
      }
      result = result + ")"
      // e.g. "INSERT INTO main.LessonVersion (levelId, uploaded, LessonVersionSignature, contentProviderId, publishedLessonVersionId) VALUES (:levelId, :uploaded, :LessonVersionSignature, :contentProviderId, :publishedLessonVersionId)"	
      return result;
   }
}
}












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
package com.brightworks.db
{
    import com.brightworks.util.Log;
    import com.brightworks.vo.IVO;

    import flash.utils.Dictionary;

    public class SQLiteQueryData_Select extends SQLiteQueryData
    {
        private var _maxAllowedResultCount:Number;
        private var _minAllowedResultCount:Number;
        private var _orderByPropNames:Vector.<String>;

        public function SQLiteQueryData_Select(
            vo:IVO,
            orderByPropNames:Vector.<String>,
            minAllowedResultCount:Number = 0,
            maxAllowedResultCount:Number = Number.MAX_VALUE)
        {
            super();
            if (!orderByPropNames)
                orderByPropNames = new Vector.<String>();
            var propName:String;
            for each (propName in orderByPropNames)
            {
                if (!Object(vo).hasOwnProperty(propName))
                    Log.fatal(["SQLiteQueryData_Select: VO doesn't contain orderByPropName of '" + propName + "': ", vo]);
            }
            this.vo = vo;
            _minAllowedResultCount = minAllowedResultCount;
            _maxAllowedResultCount = maxAllowedResultCount;
            _orderByPropNames = orderByPropNames;
        }

        override public function getParameters():Object
        {
            var result:Object = {};
            var columnName:String;
            var setPropList:Array = vo.getPropNameList_SetProps();
            for each (columnName in setPropList)
            {
                result[":" + columnName] = vo[columnName];
            }
            return result;
        }

        override public function getSQLString():String
        {
            var result:String = "SELECT";
            var columnName:String;
            var voPropInfo:Dictionary = vo.getPropInfoList();
            var columnNameAdded:Boolean = false;
            for (columnName in voPropInfo)
            {
                if (columnNameAdded)
                    result = result + ","
                result = result + " " + columnName;
                columnNameAdded = true;
            }
            result = result + " FROM " + databaseName + "." + vo.getAssociatedTableName();
            var voSetPropsList:Array = vo.getPropNameList_SetProps();
            if (voSetPropsList.length > 0)
            {
                result += " WHERE ";
                var keyAdded:Boolean = false;
                for each (columnName in voSetPropsList)
                {
                    if (keyAdded)
                        result += " AND "
                    result += columnName + "=:" + columnName;
                    keyAdded = true;
                }
            }
            columnNameAdded = false;
            if (_orderByPropNames.length > 0)
            {
                result += " ORDER BY";
                for each (columnName in _orderByPropNames)
                {
                    if (columnNameAdded)
                        result = result + ","
                    result = result + " " + columnName;
                    columnNameAdded = true;
                }
            }
            // e.g. "SELECT id, iso639_3Code, hasRecommendedLibraries FROM main.Language WHERE iso639_3Code=:iso639_3Code"	
            //    "SELECT id, locationInOrder, labelToken, isDualLanguage FROM main.LearningMode ORDER BY  locationInOrder"	

            return result;
        }

        public function isResultCountValid(count:Number):Boolean
        {
            if (count < _minAllowedResultCount)
                return false;
            if (count > _maxAllowedResultCount)
                return false;
            return true;
        }
    }
}

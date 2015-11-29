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
/*
        Notes:

            1. From the docs:
                    Using statement parameters instead of concatenating user-entered values into
                    a statement's text prevents a SQL injection attack. SQL injection can't happen
                    because the parameter values are treated explicitly as substituted values,
                    rather than becoming part of the literal statement text.


*/
package com.brightworks.db
{
    import com.brightworks.util.Log;
    import com.brightworks.vo.IVO;

    import flash.net.Responder;

    public class SQLiteQueryData
    {
        public static const PROBLEM_TYPE__NO_ROWS_AFFECTED_COUNT:String = "No 'rows affected' count";
        public static const PROBLEM_TYPE__ROWS_AFFECTED_COUNT_INVALID:String = "'rows affected' result is invalid";

        public var databaseName:String = "main";
        public var prefetch:int = -1;
        public var responder:Responder;

        protected var vo:IVO; // Only set in subclass constructors

        private var _maxAllowedRowsAffectedCount:Number;
        private var _minAllowedRowsAffectedCount:Number;

        // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
        //
        //          Public Methods
        //
        // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

        public function SQLiteQueryData(
            minAllowedRowsAffectedCount:Number = 0, 
            maxAllowedRowsAffectedCount:Number = Number.MAX_VALUE)
        {
            _minAllowedRowsAffectedCount = minAllowedRowsAffectedCount;
            _maxAllowedRowsAffectedCount = maxAllowedRowsAffectedCount;
        }

        public function getParameters():Object
        {
            // Abstract function
            Log.fatal("Abstract method, SQLiteQueryData.getParameters(), called.");
            return "Error";
        }

        public function getSQLString():String
        {
            // Abstract function
            Log.fatal("Abstract method, SQLiteQueryData.getSQLString(), called.");
            return "Error";
        }

        public function getVOClass():Class
        {
            return vo.getClass();
        }

        public function isRowsAffectedCountValid(count:Number):Boolean
        {
            if (count < _minAllowedRowsAffectedCount)
                return false;
            if (count > _maxAllowedRowsAffectedCount)
                return false;
            return true;
        }
    }
}

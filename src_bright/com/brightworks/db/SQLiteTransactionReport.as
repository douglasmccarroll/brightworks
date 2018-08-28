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
package com.brightworks.db {
import com.brightworks.interfaces.IDisposable;
import com.brightworks.techreport.ITechReport;
import com.brightworks.techreport.TechReport;
import com.brightworks.util.Utils_Dispose;

import flash.errors.SQLError;
import flash.utils.Dictionary;

public class SQLiteTransactionReport extends TechReport implements ITechReport, IDisposable {
   public var error:SQLError;
   public var finalTransactionStatus:String;
   public var index_resultData_by_queryData:Dictionary;
   public var index_rowsAffected_by_queryData:Dictionary;
   public var index_statementStatus_by_queryData:Dictionary;
   public var isSuccessful:Boolean;

   private var _isDisposed:Boolean = false;

   public function SQLiteTransactionReport() {
   }

   override public function dispose():void {
      super.dispose();
      if (_isDisposed)
         return;
      _isDisposed = true;
      if (index_resultData_by_queryData) {
         Utils_Dispose.disposeDictionary(index_resultData_by_queryData, true);
         index_resultData_by_queryData = null;
      }
      if (index_rowsAffected_by_queryData) {
         Utils_Dispose.disposeDictionary(index_rowsAffected_by_queryData, true);
         index_resultData_by_queryData = null;
      }
      if (index_statementStatus_by_queryData) {
         Utils_Dispose.disposeDictionary(index_statementStatus_by_queryData, true);
         index_statementStatus_by_queryData = null;
      }
      if (index_statementStatus_by_queryData) {
         Utils_Dispose.disposeDictionary(index_statementStatus_by_queryData, true);
         index_statementStatus_by_queryData = null;
      }
   }
}
}

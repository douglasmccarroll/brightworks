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
/*
        Notes:

            1. This was originally implemented with an asynchronous connection, then
               converted to synchronous because of an AIR/iOS bug. Obviously,
               async operations have advantages.

               If you'd like to see how this was implemented for asynchronous transactions,
               take a look at revision 842. It wouldn't be hard to revise this class so
               that it could do both types.

            2. "... a single prepared SQLStatement can not be used to queue up all the
               database operations if using an asynchronous connection. Reusing the same
               SQLStatement on a synchronous connection is valid since the call to
               execute() will have finished before the parameters on the SQLStatement
               are changed.

               "... only one database operation can be executing on a SQLConnection at a
               time. If both long-running and short-running database operations will occur
               that are independent of each other, it is possible to have multiple
               connections open to the same database. In order to take advantage of
               multiple connections, you will need to use  asynchronous connections. One
               connection can handle the long-running database operations while another
               connection handles the short database operations. However, it is not
               recommended to use multiple connections if both read and write database
               operations will be used simultaneously. Attempting to update a database
               on one connection while reading on another will generate an exception."

               Daniel Rinehart (http://www.adobe.com/devnet/air/flex/articles/air_sql_operations_07.html)


            3. (DLM 200908) One thing that isn't clear to me is:
                  a. The docs encourage the reuse of SQLStatements
                  b. But it isn't clear whether a) I can execute a given statement multiple times
                     in a loop, or if b) I have to wait for one execution to finish before starting
                     the next.
               This wouldn't be hard to test. If it is possible to do (a) then there may be a potential
               for performance gains, especially in inserts. But this would require a significant
               re-working of my architecture, which I'm pretty happy with. So I should get some time
               data when inserting data for 30 lessons.
*/
package com.brightworks.db {
import com.brightworks.interfaces.IDisposable;
import com.brightworks.util.Log;
import com.brightworks.util.Utils_DateTime;
import com.brightworks.util.Utils_Dispose;
import com.brightworks.util.Utils_Object;
import com.brightworks.util.Utils_System;

import flash.data.SQLConnection;
import flash.data.SQLMode;
import flash.data.SQLResult;
import flash.errors.SQLError;
import flash.events.EventDispatcher;
import flash.events.SQLErrorEvent;
import flash.filesystem.File;
import flash.utils.Dictionary;

public class SQLiteTransaction extends EventDispatcher implements ISQLiteOperation, IDisposable {
   public static const STATUS_BEGINNING:String = "beginning";
   public static const STATUS_COMMITTING:String = "committing";
   public static const STATUS_COMPLETE:String = "complete";
   public static const STATUS_ERROR_BEGIN_FAILED:String = "errorBeginFailed";
   public static const STATUS_ERROR_COMMIT_FAILED:String = "errorCommitFailed";
   public static const STATUS_ERROR_OPEN_FAILED:String = "errorOpenFailed";
   public static const STATUS_ERROR_ROLLBACK_FAILED:String = "errorRollbackFailed";
   public static const STATUS_EXECUTING_STATEMENTS:String = "executingStatement";
   public static const STATUS_INSTANTIATED:String = "instantiated";
   public static const STATUS_OPENING:String = "opening";
   public static const STATUS_ROLLING_BACK_AFTER_ERROR:String = "rollingBackAfterError";
   public static const STATUS_TIMED_OUT:String = "timedOut";

   private static const STATEMENTSTATUS_COMPLETE:String = "complete";
   private static const STATEMENTSTATUS_ERROR:String = "error";
   private static const STATEMENTSTATUS_EXECUTING:String = "executing";
   private static const TIMEOUT_DEFAULT_MS:int = 180000;

   public var index_resultData_by_queryData:Dictionary;
   public var index_rowsAffected_by_queryData:Dictionary;

   private var _connection:SQLConnection;
   private var _connectionErrorEvent:SQLErrorEvent;
   private var _databaseFile:File;
   private var _diagnosticInfoString:String;
   private var _index_queryData_by_statement:Dictionary;
   private var _index_statementStatus_by_queryData:Dictionary;
   private var _index_statement_by_queryData:Dictionary;
   private var _isDisposed:Boolean;
   private var _queryDataList:Array; // An array of SQLiteQueryData instances
   private var _startTransactionMilliseconds:Number;
   private var _timeoutMilliseconds:int;

   // --------------------------------------------
   //
   //           Public Methods
   //
   // --------------------------------------------

   public function SQLiteTransaction(queryData:Object, diagnosticInfoString:String = null, timeout:int = 0) {
      _diagnosticInfoString = diagnosticInfoString;
      Log.debug("SQLiteTransaction Constructor" + getDiagnosticInfoString());
      if (queryData is Array) {
         _queryDataList = queryData as Array;
      }
      else {
         if (!queryData is SQLiteQueryData)
            throw new Error("SQLiteTransaction constructor passed a queryData object that is neither SQLiteQueryData nor Array" + getDiagnosticInfoString());
         _queryDataList = [queryData];
      }
      (timeout > 0) ? _timeoutMilliseconds = timeout : _timeoutMilliseconds = TIMEOUT_DEFAULT_MS;
      if (Utils_System.isInDebugMode())
         _timeoutMilliseconds = _timeoutMilliseconds * 6;
      _index_queryData_by_statement = new Dictionary();
      _index_statement_by_queryData = new Dictionary();
      _index_statementStatus_by_queryData = new Dictionary();
      index_resultData_by_queryData = new Dictionary();
      index_rowsAffected_by_queryData = new Dictionary();
   }

   public function dispose():void {
      Log.debug("SQLiteTransaction.dispose()" + getDiagnosticInfoString());
      if (_isDisposed) {
         Log.debug("SQLiteTransaction.dispose(): Already disposed" + getDiagnosticInfoString());
         return;
      }
      _isDisposed = true;
      if (_connection) {
         _connection.close();
         _connection = null;
      }
      if (_databaseFile) {
         _databaseFile = null;
      }
      if (_index_queryData_by_statement) {
         Utils_Dispose.disposeDictionary(_index_queryData_by_statement, true);
         _index_queryData_by_statement = null;
      }
      if (index_resultData_by_queryData) {
         Utils_Dispose.disposeDictionary(index_resultData_by_queryData, true);
         index_resultData_by_queryData = null;
      }
      if (index_rowsAffected_by_queryData) {
         Utils_Dispose.disposeDictionary(index_rowsAffected_by_queryData, true);
         index_resultData_by_queryData = null;
      }
      if (_index_statement_by_queryData) {
         Utils_Dispose.disposeDictionary(_index_statement_by_queryData, true);
         _index_statement_by_queryData = null;
      }
      if (_index_statementStatus_by_queryData) {
         Utils_Dispose.disposeDictionary(_index_statementStatus_by_queryData, true);
         _index_statementStatus_by_queryData = null;
      }
      if (_queryDataList) {
         Utils_Dispose.disposeArray(_queryDataList, true);
         _queryDataList = null;
      }
   }

   public function execute(databaseFile:File):SQLiteTransactionReport {
      Log.debug("SQLiteTransaction.execute()" + getDiagnosticInfoString());
      _startTransactionMilliseconds = Utils_DateTime.getCurrentMS_AppActive();
      _databaseFile = databaseFile;
      _connection = new SQLConnection();
      try {
         _connection.open(_databaseFile, SQLMode.UPDATE);
      }
      catch (error:SQLError) {
         Log.error("SQLiteTransaction.execute(): Error when opening DB: " + error.message);
         return createFailureReport(STATUS_OPENING, error);
      }
      _connection.begin();
      for each (var queryData:SQLiteQueryData in _queryDataList) {
         if (Log.isLoggingEnabled(Log.LOG_LEVEL__DEBUG)) {
            var logInfoList:Array = [];
            logInfoList.push("SQLiteTransaction.onBeginResult()" + getDiagnosticInfoString() + " - Executing BwSQLStatement:");
            logInfoList.push("SQL string: " + queryData.getSQLString());
            logInfoList.push("Parameters:\n" + Utils_Object.getInstanceStateInfo(queryData.getParameters()));
         }
         var sqlStatement:BwSQLStatement = new BwSQLStatement();
         sqlStatement.sqlConnection = _connection;
         sqlStatement.text = queryData.getSQLString();
         sqlStatement.setParameters(queryData.getParameters());
         if (queryData is SQLiteQueryData_Select) {
            if (Log.isLoggingEnabled(Log.LOG_LEVEL__DEBUG)) {
               var voClassString:String = "queryData VO class:\n" + Utils_Object.getInstanceStateInfo(queryData.getVOClass());
               logInfoList.push(voClassString);
            }
            sqlStatement.itemClass = queryData.getVOClass();
         }
         if (Log.isLoggingEnabled(Log.LOG_LEVEL__DEBUG)) {
            logInfoList.push("\n");
            Log.debug(logInfoList);
         }
         _index_queryData_by_statement[sqlStatement] = queryData;
         _index_statement_by_queryData[queryData] = sqlStatement;
         _index_statementStatus_by_queryData[queryData] = STATEMENTSTATUS_EXECUTING;
         try {
            sqlStatement.execute();
         }
         catch (error:SQLError) {
            try {
               _connection.rollback();
               var path:String = File.applicationStorageDirectory.nativePath;  // For debugging
               return createFailureReport(STATEMENTSTATUS_EXECUTING, error);
            }
            catch (error:SQLError) {
               return createFailureReport(STATUS_ROLLING_BACK_AFTER_ERROR, error);
            }
         }
         var result:SQLResult = sqlStatement.getResult();
         queryData = _index_queryData_by_statement[sqlStatement];
         var resultData:Array;
         if (result.data == null) {
            resultData = []
         }
         else {
            resultData = result.data;
         }
         index_resultData_by_queryData[queryData] = resultData;
         index_rowsAffected_by_queryData[queryData] = result.rowsAffected;
         _index_statementStatus_by_queryData[queryData] = STATEMENTSTATUS_COMPLETE;

      }
      try {
         _connection.commit();
      }
      catch (error:SQLError) {
         try {
            _connection.rollback();
            return createFailureReport(STATUS_COMMITTING, error);
         }
         catch (error:SQLError) {
            return createFailureReport(STATUS_ROLLING_BACK_AFTER_ERROR, error);
         }
      }
      _connection.close();
      _connection = null;
      return createSuccessReport(STATUS_COMPLETE);
   }

   // --------------------------------------------
   //
   //           Private Methods
   //
   // --------------------------------------------

   private function createFailureReport(status:String, error:SQLError):SQLiteTransactionReport {
      // The most common causes are:
      //   - Failing to revise DB SQL or VO so that they match
      //   - Failing to rebuild DB after modifying SQL script
      //   - Failing to clean this project after rebuilding DB
      //   - Failing to ensure "clear app date" - may need to delete DB file manually
      Log.debug("SQLiteTransaction.createFailureReport()" + getDiagnosticInfoString());
      var report:SQLiteTransactionReport = new SQLiteTransactionReport();
      report.error = error;
      report.finalTransactionStatus = status;
      report.index_statementStatus_by_queryData = _index_statementStatus_by_queryData;
      report.isSuccessful = false;
      return report;
   }

   private function createSuccessReport(status:String):SQLiteTransactionReport {
      Log.debug("SQLiteTransaction.createSuccessReport()" + getDiagnosticInfoString());
      var report:SQLiteTransactionReport = new SQLiteTransactionReport();
      report.finalTransactionStatus = status;
      report.index_resultData_by_queryData = index_resultData_by_queryData;
      report.index_rowsAffected_by_queryData = index_rowsAffected_by_queryData;
      report.isSuccessful = true;
      return report;
   }

   private function getDiagnosticInfoString():String {
      if (_diagnosticInfoString)
         return " - diagnostic info: " + _diagnosticInfoString;
      else
         return "";
   }

}
}



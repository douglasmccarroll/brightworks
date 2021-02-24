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
package com.brightworks.util.csv {
import com.brightworks.base.Callbacks;
import com.brightworks.event.BwEvent;
import com.brightworks.util.Utils_Dispose;
import com.brightworks.util.file.FileSaver;

import flash.utils.ByteArray;

import mx.collections.ArrayCollection;

public class Utils_CsvFileCreator {
   private static var _callbacks:Callbacks;
   private static var _columnLabelsArray:Array = [];
   private static var _columnsArray:Array = [];
   private static var _fileSaver:FileSaver;

   public static function addColumn_ArrayCollection(ac:ArrayCollection, label:String = ""):void {
      _columnsArray.push(ac);
      _columnLabelsArray.push(label);
   }

   public static function clear():void {
      if (_columnsArray) {
         Utils_Dispose.disposeArray(_columnsArray, false);
         _columnsArray = null;
      }
      if (_fileSaver) {
         _fileSaver.dispose();
         _fileSaver = null;
      }
      if (_callbacks) {
         _callbacks.dispose();
         _callbacks = null;
      }
   }

   public static function getText():String {
      var result:String = "";
      var columnCount:uint = _columnsArray.length;
      for (var i:uint = 0; i < columnCount; i++) {
         if (i > 0)
            result += ",";
         result += _columnLabelsArray[i];
      }
      result += "\n";
      var rowCount:uint = getLengthOfLongestColumn();
      for (var currRowNumber:uint = 1; currRowNumber <= rowCount; currRowNumber++) {
         for (var currColumnNumber:uint = 1; currColumnNumber <= columnCount; currColumnNumber++) {
            if (currColumnNumber > 1) {
               result += ",";
            }
            var currColumnList:ArrayCollection = _columnsArray[currColumnNumber - 1];
            if (currColumnList.length >= currRowNumber) {
               result += currColumnList[currRowNumber - 1];
            }
         }
         result += "\n";
      }
      return result;
   }

   public static function writeFile(fileName:String, fileFolder:String, callbacks:Callbacks = null):void {
      _callbacks = callbacks;
      _fileSaver = new FileSaver();
      _fileSaver.fileFolder = fileFolder;
      _fileSaver.fileName = fileName;
      var ba:ByteArray = new ByteArray();
      ba.writeUTFBytes(getText());
      _fileSaver.fileData = ba;
      _fileSaver.start();
      _fileSaver.addEventListener(BwEvent.COMPLETE, onSaveComplete);
      _fileSaver.addEventListener(BwEvent.FAILURE, onSaveFailure);
      ba.clear();
   }

   private static function getLengthOfLongestColumn():uint {
      var result:uint = 0;
      for each (var subArray:ArrayCollection in _columnsArray) {
         result = Math.max(result, subArray.length);
      }
      return result;
   }

   private static function onSaveComplete(e:BwEvent):void {
      if (_callbacks)
         _callbacks.result();
      clear();
   }

   private static function onSaveFailure(e:BwEvent):void {
      if (_callbacks)
         _callbacks.fault(e);
      clear();
   }
}
}













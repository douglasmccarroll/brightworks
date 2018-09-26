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
package com.brightworks.util.download {
import com.brightworks.interfaces.IDisposable;
import com.brightworks.util.Log;
import com.brightworks.util.Utils_Dispose;
import com.brightworks.util.Utils_Object;

import flash.utils.Dictionary;

public class FileSetDownloaderFilesInfo implements IDisposable {
   private var _isDisposed:Boolean = false;

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
   //
   //          Getters & Setters
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

   private var _fileInfoList:Dictionary = new Dictionary();

   public function get fileInfoList():Dictionary {
      var result:Dictionary = new Dictionary();
      for (var fileId:String in _fileInfoList) {
         result[fileId] = _fileInfoList[fileId];
      }
      return result;
   }

   public function get length():uint {
      var result:uint = 0;
      for (var fileId:String in _fileInfoList) {
         result++;
      }
      return result;
   }

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
   //
   //          Public Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

   public function FileSetDownloaderFilesInfo() {
      if (Log.isLoggingEnabled(Log.LOG_LEVEL__DEBUG))
         return;
      Log.debug("FileSetDownloaderFilesInfo constructor");
   }

   public function dispose():void {
      if (_isDisposed)
         return;
      Log.debug("FileSetDownloaderFilesInfo.dispose()");
      _isDisposed = true;
      if (_fileInfoList) {
         Utils_Dispose.disposeDictionary(_fileInfoList, true);
         _fileInfoList = null;
      }
   }

   public function addFileInfo(fileId:String, fileInfo:FileSetDownloaderFileInfo):void {
      if (Log.isLoggingEnabled(Log.LOG_LEVEL__DEBUG)) {
         var logInfo:Array = [];
         logInfo.push("FileSetDownloaderFilesInfo.addFileInfo()");
         logInfo.push("fileId: " + fileId);
         logInfo.push("fileInfo: \n" + Utils_Object.getInstanceStateInfo(fileInfo));
         Log.debug(logInfo);
      }
      if ((!fileInfo.fileFolderURL) ||
            (!fileInfo.fileNameBody) ||
            (!fileInfo.fileNameExtension)) {
         Log.warn("FileSetDownloaderFilesInfo.addFileInfo(): fileInfo arg not fully populated.");
         return;
      }
      _fileInfoList[fileId] = fileInfo;
   }

   public function getFileInfo(fileId:String):FileSetDownloaderFileInfo {
      return FileSetDownloaderFileInfo(_fileInfoList[fileId]);
   }

}
}

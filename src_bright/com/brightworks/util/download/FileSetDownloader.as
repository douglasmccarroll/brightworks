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
package com.brightworks.util.download {
import com.brightworks.event.BwEvent;
import com.brightworks.interfaces.IDisposable;
import com.brightworks.util.Log;
import com.brightworks.util.Utils_Dispose;

import flash.events.EventDispatcher;
import flash.utils.Dictionary;

public class FileSetDownloader extends EventDispatcher implements IDisposable {
   public static var FILE_DOWNLOADER_STATUS__COMPLETE:String = "fileDownLoaderStatus_Complete";
   public static var FILE_DOWNLOADER_STATUS__FAILED:String = "fileDownLoaderStatus_Failed";
   public static var FILE_DOWNLOADER_STATUS__STARTED:String = "fileDownLoaderStatus_Started";

   public var filesInfo:FileSetDownloaderFilesInfo;

   private var _bClientWillDisposeFilesInfo:Boolean;
   private var _isDisposed:Boolean = false;
   private var _index_fileId_to_fileDownloader:Dictionary;
   private var _index_fileId_to_fileDownloaderStatus:Dictionary;
   private var _index_fileDownloader_to_fileId:Dictionary;

   // --------------------------------------------
   //
   //           Getters / Setters
   //
   // --------------------------------------------

   public function get downloadedByteCount():Number {
      var result:Number = 0;
      for each (var fd:FileDownloader in _index_fileId_to_fileDownloader) {
         if (fd.fileData)
            result += fd.fileData.length;
      }
      return result;
   }

   // Error report is passed out when reporting fault, but may also be accessed via this getter.
   // In both cases we need to updateErrorReport().
   private var _errorReport:FileSetDownloaderErrorReport = new FileSetDownloaderErrorReport();

   public function get errorReport():FileSetDownloaderErrorReport {
      updateErrorReport();
      return _errorReport;
   }

   // --------------------------------------------
   //
   //           Public Methods
   //
   // --------------------------------------------

   public function FileSetDownloader(bClientWillDisposeFilesInfo:Boolean) {
      super();
      _bClientWillDisposeFilesInfo = bClientWillDisposeFilesInfo;
   }

   public function dispose():void {
      if (_isDisposed)
         return;
      _isDisposed = true;
      if (_index_fileId_to_fileDownloader) {
         Utils_Dispose.disposeDictionary(_index_fileId_to_fileDownloader, true);
         _index_fileId_to_fileDownloader = null;
      }
      if (_index_fileDownloader_to_fileId) {
         Utils_Dispose.disposeDictionary(_index_fileDownloader_to_fileId, true);
         _index_fileDownloader_to_fileId = null;
      }
      filesInfo = null; // Needs to be disposed by client
      _errorReport = null;
      _index_fileId_to_fileDownloaderStatus = null;
   }

   public function start():void {
      if (!filesInfo) {
         _errorReport.bFileInfoNotPopulated = true;
         dispatchEvent(new BwEvent(BwEvent.FAILURE, _errorReport));
         return;
      }
      _index_fileId_to_fileDownloader = new Dictionary();
      _index_fileDownloader_to_fileId = new Dictionary();
      _index_fileId_to_fileDownloaderStatus = new Dictionary();
      _errorReport.index_fileId_to_fileDownloaderStatus = _index_fileId_to_fileDownloaderStatus;

      for (var fileId:String in filesInfo.fileInfoList) {
         var thisFilesData:FileSetDownloaderFileInfo = filesInfo.getFileInfo(fileId);
         var fd:FileDownloader = new FileDownloader();
         fd.downloadFileName = thisFilesData.fileNameBody;
         fd.downloadFileExtension = thisFilesData.fileNameExtension;
         fd.downloadFolderURL = thisFilesData.fileFolderURL;
         fd.addEventListener(BwEvent.COMPLETE, onDownloadComplete);
         fd.addEventListener(BwEvent.FAILURE, onDownloadFailure);
         _index_fileId_to_fileDownloader[fileId] = fd;
         _index_fileDownloader_to_fileId[fd] = fileId;
         _index_fileId_to_fileDownloaderStatus[fileId] = FILE_DOWNLOADER_STATUS__STARTED;
         fd.start();
      }

   }

   // --------------------------------------------
   //
   //           Private Methods
   //
   // --------------------------------------------

   private function checkForDone():void {
      if (isDone()) {
         if (isAnyErrors()) {
            updateErrorReport();
            reportFailure();
         } else {
            dispatchEvent(new BwEvent(BwEvent.COMPLETE));
         }
      }
   }

   private function isAnyErrors():Boolean {
      var fileId:String;
      var fd:FileDownloader;
      for (fileId in _index_fileId_to_fileDownloader) {
         fd = _index_fileId_to_fileDownloader[fileId];
         switch (fd.status) {
            case FileDownloader.STATUS_COMPLETE:
            case FileDownloader.STATUS_DOWNLOADING:
               // do nothing in loop
               break;
            case FileDownloader.STATUS_ERROR: {
               return true;
               break;
            }
            default: {
               Log.fatal("FileSetDownloader.isAnyErrors(): no switch case for " + fd.status);
            }
         }
      }
      return false;
   }

   /**
    *
    * @return
    *
    */
   private function isDone():Boolean {
      var fileId:String;
      var fd:FileDownloader;
      for (fileId in _index_fileId_to_fileDownloader) {
         fd = _index_fileId_to_fileDownloader[fileId];
         switch (fd.status) {
            case FileDownloader.STATUS_COMPLETE:
            case FileDownloader.STATUS_ERROR:
               // do nothing in loop
               break;
            case FileDownloader.STATUS_DOWNLOADING: {
               return false;
               break;
            }
            default: {
               Log.fatal("FileSetDownloader.isDone(): no switch case for " + fd.status);
            }
         }
      }
      return true;
   }

   private function onDownloadComplete(event:BwEvent):void {
      var fd:FileDownloader = FileDownloader(event.target);

      // Keep for debugging lesson download failures
      if (fd.fullFileURL.indexOf("/langcollab") != -1) {
         var foo:int = 1;
      }

      var fileId:String = _index_fileDownloader_to_fileId[fd];
      var thisFilesData:FileSetDownloaderFileInfo = filesInfo.getFileInfo(fileId);
      Log.debug(["FileSetDownloader.onDownloadComplete()", thisFilesData.fileFolderURL && thisFilesData.fileNameBody && "." && thisFilesData.fileNameExtension]);
      _index_fileId_to_fileDownloaderStatus[fileId] = FILE_DOWNLOADER_STATUS__COMPLETE;
      thisFilesData.fileData = fd.fileData;
      checkForDone();
   }

   private function onDownloadFailure(event:BwEvent):void {
      // In many scenarios a "download failure" isn't really a failure. The code may just be looking to see
      // whether one or more files exists. So, if you're hitting this point in the code its best to look
      // at the client code's failure handler to see if this is actually a problem.
      Log.debug(["FileSetDownloader.onDownloadFailure()", event, "\n\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n\n"]);
      var fd:FileDownloader = FileDownloader(event.target);

      // Keep for debugging lesson download failures
      if (fd.fullFileURL.indexOf("/langcollab") != -1) {
         var foo:int = 1;
      }

      var fileId:String = _index_fileDownloader_to_fileId[fd];
      _index_fileId_to_fileDownloaderStatus[fileId] = FILE_DOWNLOADER_STATUS__FAILED;
      checkForDone();
   }

   private function reportFailure():void {
      var e:BwEvent = new BwEvent(BwEvent.FAILURE, errorReport);
      dispatchEvent(e);
   }

   private function updateErrorReport():void {
      for (var fileId:String in _index_fileId_to_fileDownloader) {
         var fd:FileDownloader = _index_fileId_to_fileDownloader[fileId];
         if (fd.status != FileDownloader.STATUS_COMPLETE) {
            if (!_errorReport.index_fileId_to_fileDownloaderErrorReport)
               _errorReport.index_fileId_to_fileDownloaderErrorReport = new Dictionary();
            _errorReport.index_fileId_to_fileDownloaderErrorReport[fileId] = fd.errorReport;
         }
      }
   }

}
}


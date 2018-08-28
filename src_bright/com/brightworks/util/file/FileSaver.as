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
package com.brightworks.util.file {
import com.brightworks.event.BwEvent;
import com.brightworks.interfaces.IDisposable;
import com.brightworks.util.Log;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IOErrorEvent;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.utils.ByteArray;

public class FileSaver extends EventDispatcher implements IDisposable {
   public static const STATUS_COMPLETE:String = "complete";
   public static const STATUS_ERROR:String = "error";
   public static const STATUS_NOT_STARTED:String = "notStarted";
   public static const STATUS_SAVING:String = "saving";

   public var errorReport:FileSaverErrorReport;
   public var fileData:ByteArray;
   public var fileFolder:String;
   public var fileName:String;
   public var status:String;

   private var _fileStream:FileStream;

   public function FileSaver() {
      super();
      status = STATUS_NOT_STARTED;
   }

   public function dispose():void {
      if (_fileStream) {
         _fileStream.close();
      }
      _fileStream = null;
      errorReport = null;
      fileData = null;
   }

   public function getFullFilePath():String {
      return fileFolder + File.separator + fileName;
   }

   public function start():void {
      status = STATUS_SAVING;
      var file:File = new File();
      file.nativePath = getFullFilePath();
      _fileStream = new FileStream();
      //_fileStream.addEventListener(Event.CLOSE, onStreamClose);
      //_fileStream.addEventListener(IOErrorEvent.IO_ERROR, onStreamError);
      //_fileStream.openAsync(file, FileMode.WRITE);
      _fileStream.open(file, FileMode.WRITE);
      _fileStream.writeBytes(fileData, 0, fileData.length);
      _fileStream.close();
      status = STATUS_COMPLETE;
      dispatchEvent(new BwEvent(BwEvent.COMPLETE));
   }

   private function onStreamClose(event:Event):void {
      if (status == STATUS_ERROR) {
         // This should never happen
         Log.debug("FileSaver.onStreamClose(): " + getFullFilePath() + " Close event after error event");
      }
      else {
         status = STATUS_COMPLETE;
         dispatchEvent(new BwEvent(BwEvent.COMPLETE));
      }
   }

   private function onStreamError(event:IOErrorEvent):void {
      if (status == STATUS_COMPLETE) {
         // This should never happen
         Log.warn("FileSaver.onStreamError(): " + getFullFilePath() + " Error event after close event");
      }
      status = STATUS_ERROR;
      errorReport = new FileSaverErrorReport();
      errorReport.errorEventText = event.text;
      errorReport.errorEventType = event.type;
      errorReport.fileFolder = fileFolder;
      errorReport.fileName = fileName;
      var e:BwEvent = new BwEvent(BwEvent.FAILURE, errorReport);
      dispatchEvent(e);
   }
}
}

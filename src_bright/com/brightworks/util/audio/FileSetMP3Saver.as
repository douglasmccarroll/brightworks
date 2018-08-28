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
package com.brightworks.util.audio {
// This could be made more generic, so that it saves any type of file, and either
// set a "file byte data prop name" prop, or pass in an "extract file byte data"
// strategy...

import com.brightworks.event.BwEvent;
import com.brightworks.interfaces.IDisposable;
import com.brightworks.util.Log;
import com.brightworks.util.Utils_Dispose;
import com.brightworks.util.file.FileSaver;

import flash.events.EventDispatcher;
import flash.events.TimerEvent;
import flash.utils.Dictionary;
import flash.utils.Timer;

public class FileSetMP3Saver extends EventDispatcher implements IDisposable {
   private var _currentActiveFileSaver:FileSaver;
   private var _index_fileId_to_fileSaver:Dictionary;
   private var _interFileDelay:uint;
   private var _interFileDelayTimer:Timer;
   private var _isDisposed:Boolean = false;
   private var _unstartedFileSaverList:Array;

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
   //
   //          Getters / Setters
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

   // fileData format:
   //      props = 'fileId' String - unique, of course - client code can use whatever it wants for this]
   //      vals  = MP3FileInfo instances
   private var _fileData:Dictionary;

   public function set fileData(value:Dictionary):void {
      _fileData = value;
   }

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
   //
   //          Public Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

   public function FileSetMP3Saver() {
      super();
   }

   public function dispose():void {
      if (_isDisposed)
         return;
      _isDisposed = true;
      _fileData = null;
      if (_currentActiveFileSaver) {
         _currentActiveFileSaver.dispose();
         _currentActiveFileSaver = null;
      }
      if (_index_fileId_to_fileSaver) {
         Utils_Dispose.disposeDictionary(_index_fileId_to_fileSaver, true);
         _index_fileId_to_fileSaver = null;
      }
      if (_unstartedFileSaverList) {
         Utils_Dispose.disposeArray(_unstartedFileSaverList, true);
      }
      stopInterFileDelayTimer();
   }

   public function start(interFileDelay:uint = 0):void {
      _index_fileId_to_fileSaver = new Dictionary();
      _interFileDelay = interFileDelay;
      _unstartedFileSaverList = [];
      var fileId:String;
      var oneFilesData:MP3FileInfo;
      var fs:FileSaver;
      for (fileId in _fileData) {
         oneFilesData = _fileData[fileId];
         fs = new FileSaver();
         fs.fileName = oneFilesData.fileName;
         fs.fileFolder = oneFilesData.fileFolder;
         fs.fileData = oneFilesData.mp3FormattedByteData;
         fs.addEventListener(BwEvent.COMPLETE, onSaveComplete);
         fs.addEventListener(BwEvent.FAILURE, onSaveFailure);
         _unstartedFileSaverList.push(fs);
         _index_fileId_to_fileSaver[fileId] = fs;
      }
      continueOrFinish();
   }

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
   //
   //          Private Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

   private function continueOrFinish():void {
      if (_unstartedFileSaverList.length > 0) {
         if (_interFileDelay > 0) {
            _interFileDelayTimer = new Timer(_interFileDelay, 1);
            _interFileDelayTimer.addEventListener(TimerEvent.TIMER, startNewFileSave);
            _interFileDelayTimer.start();
         }
         else {
            startNewFileSave();
         }
      }
      else {
         if ((getCountOfFileSaversWithStatusOf(FileSaver.STATUS_ERROR) > 0) ||
               (getCountOfFileSaversWithStatusOf(FileSaver.STATUS_SAVING) > 0)) {
            var report:FileSetMP3SaverTechReport = new FileSetMP3SaverTechReport();
            if (getCountOfFileSaversWithStatusOf(FileSaver.STATUS_ERROR) > 0) {
               var fileSaverErrorReports:Dictionary = new Dictionary();
               var fileId:String;
               var fs:FileSaver;
               for (fileId in _index_fileId_to_fileSaver) {
                  fs = _index_fileId_to_fileSaver[fileId];
                  if (fs.status == FileSaver.STATUS_ERROR) {
                     fileSaverErrorReports[fileId] = fs.errorReport;
                  }
               }
               report.fileSaverErrorReports = fileSaverErrorReports;
            }
            if (getCountOfFileSaversWithStatusOf(FileSaver.STATUS_SAVING) > 0) {
               Log.error("FileSetMP3Saver.continueOrFinish(): One or more FileSavers are still saving");
               var fileSaversStillSavingWhenSetIsFinishedList:Array = [];
               for (fileId in _index_fileId_to_fileSaver) {
                  fs = _index_fileId_to_fileSaver[fileId];
                  if (fs.status == FileSaver.STATUS_SAVING) {
                     fileSaversStillSavingWhenSetIsFinishedList.push(fs.getFullFilePath());
                  }
               }
               report.fileSaversStillSavingWhenSetIsFinishedList = fileSaversStillSavingWhenSetIsFinishedList;
            }
            var e:BwEvent = new BwEvent(BwEvent.FAILURE, report);
            dispatchEvent(e);
         }
         else {
            dispatchEvent(new BwEvent(BwEvent.COMPLETE));
         }
      }
   }

   private function getCountOfFileSaversWithStatusOf(status:String):uint {
      var result:uint = 0;
      var fileId:String;
      var fs:FileSaver;
      for (fileId in _index_fileId_to_fileSaver) {
         fs = _index_fileId_to_fileSaver[fileId];
         if (fs.status == status)
            result++;
      }
      return result;
   }

   private function onSaveComplete(event:BwEvent):void {
      continueOrFinish();
   }

   private function onSaveFailure(event:BwEvent):void {
      continueOrFinish();
   }

   private function startNewFileSave(event:TimerEvent = null):void {
      stopInterFileDelayTimer();
      _currentActiveFileSaver = _unstartedFileSaverList.shift();
      _currentActiveFileSaver.start();
   }

   private function stopInterFileDelayTimer():void {
      if (_interFileDelayTimer) {
         _interFileDelayTimer.stop();
         _interFileDelayTimer.removeEventListener(TimerEvent.TIMER, startNewFileSave);
         _interFileDelayTimer = null;
      }
   }

}
}


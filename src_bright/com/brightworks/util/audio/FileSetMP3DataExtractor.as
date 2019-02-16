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
package com.brightworks.util.audio {
import com.brightworks.event.BwEvent;
import com.brightworks.interfaces.IDisposable;
import com.brightworks.util.Log;
import com.brightworks.util.Utils_Dispose;

import flash.events.EventDispatcher;
import flash.events.TimerEvent;
import flash.media.Sound;
import flash.utils.Dictionary;
import flash.utils.Timer;

public class FileSetMP3DataExtractor extends EventDispatcher implements IDisposable {
   private var _interFileDelay:uint;
   private var _interFileDelayTimer:Timer;
   private var _isDisposed:Boolean = false;
   private var _unstartedFileIdList:Array;

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
   //
   //          Getters / Setters
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

   // fileData format:
   //     - props  = file IDs
   //     - values = MP3FileInfo instances
   private var _fileData:Dictionary; // props are file names, values are null at first, then file lengths in ms

   public function get fileData():Dictionary {
      return _fileData
   }

   public function set fileData(value:Dictionary):void {
      _fileData = value;
   }

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
   //
   //          Public Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

   public function FileSetMP3DataExtractor() {
      super();
   }

   public function dispose():void {
      if (_isDisposed)
         return;
      _isDisposed = true;
      if (_fileData) {
         Utils_Dispose.disposeDictionary(_fileData, true);
         _fileData = null;
      }
      if (_unstartedFileIdList) {
         Utils_Dispose.disposeArray(_unstartedFileIdList, true);
         _unstartedFileIdList = null;
      }
      stopInterFileDelayTimer();
   }

   public function start(interFileDelay:uint = 0):void {
      Log.debug("FileSetMP3DataExtractor.start()");
      _interFileDelay = interFileDelay;
      _unstartedFileIdList = [];
      for (var fileId:String in fileData) {
         _unstartedFileIdList.push(fileId);
      }
      continueOrFinish();
   }

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
   //
   //          Private Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

   private function continueOrFinish():void {
      if (_unstartedFileIdList.length > 0) {
         if (_interFileDelay > 0) {
            _interFileDelayTimer = new Timer(_interFileDelay, 1);
            _interFileDelayTimer.addEventListener(TimerEvent.TIMER, startNewDataExtraction);
            _interFileDelayTimer.start();
         }
         else {
            startNewDataExtraction();
         }
      }
      else {
         dispatchEvent(new BwEvent(BwEvent.COMPLETE));
      }
   }

   private function startNewDataExtraction(event:TimerEvent = null):void {
      var fileId:String = _unstartedFileIdList.shift();
      var mp3FileInfo:MP3FileInfo = fileData[fileId];
      var sound:Sound = new Sound();
      sound.loadCompressedDataFromByteArray(mp3FileInfo.mp3FormattedByteData, mp3FileInfo.mp3FormattedByteData.length);
      mp3FileInfo.duration = sound.length;
      continueOrFinish();
   }

   private function stopInterFileDelayTimer():void {
      if (_interFileDelayTimer) {
         _interFileDelayTimer.stop();
         _interFileDelayTimer.removeEventListener(TimerEvent.TIMER, startNewDataExtraction);
         _interFileDelayTimer = null;
      }
   }

}
}

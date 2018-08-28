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
import com.brightworks.util.IPercentCompleteReporter;
import com.brightworks.util.Log;
import com.brightworks.util.Utils_Math;
import com.brightworks.util.Utils_String;

import flash.errors.IOError;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.HTTPStatusEvent;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.net.URLRequest;
import flash.net.URLStream;
import flash.utils.ByteArray;

public class FileDownloader extends EventDispatcher implements IPercentCompleteReporter, IDisposable {
   public static const STATUS_COMPLETE:String = "complete";
   public static const STATUS_DOWNLOADING:String = "downloading";
   public static const STATUS_ERROR:String = "error";

   public var bytesLoaded:int = 0;
   public var bytesTotal:int = 0;
   public var downloadComplete:Boolean;
   public var downloadFailed:Boolean;
   public var downloadFileName:String;
   public var downloadFileExtension:String;
   public var errorReport:FileDownloaderErrorReport;
   public var fileData:ByteArray;
   public var status:String;

   private var _isDisposed:Boolean = false;
   private var _request:URLRequest;
   private var _stream:URLStream;

   // --------------------------------------------
   //
   //           Getters / Setters
   //
   // --------------------------------------------

   private var _downloadFolderURL:String;

   public function get downloadFolderURL():String {
      return _downloadFolderURL;
   }

   public function set downloadFolderURL(value:String):void {
      value = Utils_String.trimStringEnd(value, "/");
      _downloadFolderURL = value;
   }

   public function get fullFileURL():String {
      return downloadFolderURL + "/" + downloadFileName + "." + downloadFileExtension;
   }

   // --------------------------------------------
   //
   //           Public Methods
   //
   // --------------------------------------------

   public function FileDownloader() {
      super();
      Log.debug("FileDownloader constructor");
   }

   public function dispose():void {
      Log.debug("FileDownloader.dispose(): " + fullFileURL);
      if (_isDisposed)
         return;
      _isDisposed = true;
      closeStream(true);
      errorReport = null;
      if (fileData) {
         fileData.clear();
         fileData = null;
      }
      _request = null;
      _stream = null;
   }

   public function getPercentComplete():int {
      if (bytesTotal == 0)
         return 0;
      return Utils_Math.computePercentageInteger_RoundDown(bytesLoaded, bytesTotal);
   }

   public function start():void {
      Log.debug("FileDownloader.start(): " + fullFileURL);
      status = STATUS_DOWNLOADING;
      fileData = new ByteArray();
      _request = new URLRequest(fullFileURL);
      _stream = new URLStream();
      downloadComplete = false;
      downloadFailed = false;
      errorReport = new FileDownloaderErrorReport();
      errorReport.downloadFolderURL = downloadFolderURL;
      errorReport.downloadFileName = downloadFileName;
      errorReport.downloadFileExtension = downloadFileExtension;
      _stream.addEventListener(ProgressEvent.PROGRESS, onDownloadProgress);
      _stream.addEventListener(Event.COMPLETE, onDownloadComplete);
      _stream.addEventListener(IOErrorEvent.IO_ERROR, onDownloadError);
      _stream.addEventListener(IOErrorEvent.NETWORK_ERROR, onDownloadError);
      _stream.addEventListener(IOErrorEvent.VERIFY_ERROR, onDownloadError);
      _stream.addEventListener(HTTPStatusEvent.HTTP_STATUS, onDownloadStatus);
      _stream.load(_request);
   }

   // --------------------------------------------
   //
   //           Private Methods
   //
   // --------------------------------------------

   private function closeStream(calledFromDispose:Boolean = false):void {
      if (_stream) {
         if (calledFromDispose)
            Log.debug("FileDownloader.closeStream(): " + fullFileURL + " - called from dispose() and _stream still contains instance");
         else
            Log.debug("FileDownloader.closeStream(): " + fullFileURL);
         _stream.removeEventListener(ProgressEvent.PROGRESS, onDownloadProgress);
         _stream.removeEventListener(Event.COMPLETE, onDownloadComplete);
         _stream.removeEventListener(IOErrorEvent.IO_ERROR, onDownloadError);
         _stream.removeEventListener(IOErrorEvent.NETWORK_ERROR, onDownloadError);
         _stream.removeEventListener(IOErrorEvent.VERIFY_ERROR, onDownloadError);
         _stream.removeEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, onDownloadStatus);

         try {
            _stream.close();
         }
         catch (error:IOError) {
            Log.debug("FileDownloader.closeStream(): " + fullFileURL + " - _stream.close() caused error - already closed?");
            // Do nothing - stream was not open or could not be closed
         }
         _stream = null;
      }
      else {
         if (!calledFromDispose)
            Log.debug("FileDownloader.closeStream(): " + fullFileURL + " - not called from dispose() and _stream doesn't contain instance");
      }
      _request = null;
   }

   private function onDownloadComplete(event:Event):void {
      Log.debug("FileDownloader.onDownloadComplete(): " + fullFileURL);
      //this is getting called from a URLStream after everything is downloaded
      //event is an Event


      status = STATUS_COMPLETE;
      downloadComplete = true;
      _stream.readBytes(fileData);
      closeStream();
      var e:BwEvent = new BwEvent(BwEvent.COMPLETE);
      e.cause = event;
      dispatchEvent(e);
   }

   private function onDownloadError(event:IOErrorEvent):void {
      Log.debug("FileDownloader.onDownloadError(): " + fullFileURL + " - " + event.text);
      status = STATUS_ERROR;
      downloadFailed = true;
      errorReport.ioErrorEventText = event.text;
      var e:BwEvent = new BwEvent(BwEvent.FAILURE, errorReport);
      dispatchEvent(e);
   }

   private function onDownloadProgress(event:ProgressEvent):void {
      bytesLoaded = event.bytesLoaded;
      bytesTotal = event.bytesTotal;
   }

   private function onDownloadStatus(event:HTTPStatusEvent):void {
      // For debugging...
      // trace(event.status);
   }
}
}


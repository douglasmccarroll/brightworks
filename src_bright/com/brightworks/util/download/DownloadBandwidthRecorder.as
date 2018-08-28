package com.brightworks.util.download {
import com.brightworks.util.Utils_DateTime;

import flash.utils.ByteArray;

public class DownloadBandwidthRecorder {
   private var _byteCountList:Array = [];
   private var _timeList:Array = [];

   public function DownloadBandwidthRecorder() {
   }

   public function getBytesDownloadedInPreviousMilliseconds(milliseconds:Number):Number {
      var beginTime:Number = Utils_DateTime.getCurrentMS_BasedOnDate() - milliseconds;
      var result:Number = 0;
      for (var i:int = _byteCountList.length - 1; i >= 0; i--) {
         if (_timeList[i] >= beginTime)
            result += _byteCountList[i];
      }
      return result;
   }

   public function reportByteArray(ba:ByteArray):void {
      reportDownloadedByteCount(ba.length);
   }

   public function reportDownloadedByteCount(count:Number):void {
      _byteCountList.push(count);
      _timeList.push(Utils_DateTime.getCurrentMS_BasedOnDate());
   }

   public function reportFileDownloader(fd:FileDownloader):void {
      if (!(fd))
         return;
      if (!(fd.fileData))
         return;
      reportByteArray(fd.fileData);
   }

   public function reportFileSetDownloader(fsd:FileSetDownloader):void {
      if (!(fsd))
         return;
      reportDownloadedByteCount(fsd.downloadedByteCount);
   }

}
}

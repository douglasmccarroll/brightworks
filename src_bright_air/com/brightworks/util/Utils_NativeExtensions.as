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
package com.brightworks.util {

// Note - If you're having problems with MyFlashLab extensions, ensure that the most recent versions of
// androidSupport and overrideAir 'common dependency extensions' are installed
import com.myflashlab.air.extensions.barcode.Barcode;
import com.myflashlab.air.extensions.barcode.BarcodeEvent;
import com.myflashlab.air.extensions.nativePermissions.PermissionCheck;

/*




 NOTE: This class has separate versions for our production project and our
 desktop debugging project. Many ANEs don't support
 Windows/Mac, so we use a dummy methods for the desktop case.

 This is the production version.


*/
public class Utils_NativeExtensions {

   private static var _codeScanner:Barcode;
   private static var _codeScanCancelCallback:Function;
   private static var _codeScanResultCallback:Function;
   private static var _permissionCheck:PermissionCheck;

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   //
   //          Public Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   public static function activateCodeScanner(codeScanResultCallback:Function, codeScanCancelCallback:Function, codeScanFailureCallback:Function):void {
      _codeScanCancelCallback = codeScanCancelCallback;
      _codeScanResultCallback = codeScanResultCallback;
      if (!_codeScanner) {
         _codeScanner = new Barcode();
         _codeScanner.addEventListener(BarcodeEvent.RESULT, onCodeScanResult);
         _codeScanner.addEventListener(BarcodeEvent.CANCEL, onCodeScanCancel);
      }
      if (!_codeScanner.isSupported()) {
         codeScanFailureCallback();
         return;
      }
      if (!_permissionCheck)
         _permissionCheck = new PermissionCheck();
      var permissionState:int = _permissionCheck.check(PermissionCheck.SOURCE_CAMERA);
      if (permissionState == PermissionCheck.PERMISSION_UNKNOWN || permissionState == PermissionCheck.PERMISSION_DENIED) {
         var requestResultHandler:Function = function (result:int):void {
            if (result == PermissionCheck.PERMISSION_GRANTED) {
               activateCodeScanner_Continued();
            } else {
               codeScanCancelCallback();
            }
         }
         _permissionCheck.request(PermissionCheck.SOURCE_CAMERA, requestResultHandler);
      } else {
         activateCodeScanner_Continued();
      }
   }

   public static function activateCodeScanner_Continued():void {
      _codeScanner.open([Barcode.QR], null, true);
   }

   public static function requestMicrophonePermission(callback:Function):void {
      if (!_permissionCheck)
         _permissionCheck = new PermissionCheck();
      var permissionState:int = _permissionCheck.check(PermissionCheck.SOURCE_MIC);
      if (permissionState == PermissionCheck.PERMISSION_UNKNOWN || permissionState == PermissionCheck.PERMISSION_DENIED) {
         var requestResultHandler:Function = function (result:int):void {
            if (result == PermissionCheck.PERMISSION_GRANTED) {
               callback(true);
            } else {
               callback(false);
            }
         }
         _permissionCheck.request(PermissionCheck.SOURCE_MIC, requestResultHandler);
      } else {
         callback(true);
      }
   }

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   //
   //          Private Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


   private static function onCodeScanCancel(event:BarcodeEvent):void {
      _codeScanCancelCallback();
   }

   private static function onCodeScanResult(event:BarcodeEvent):void {
      _codeScanResultCallback(event.param.data);
   }

}
}



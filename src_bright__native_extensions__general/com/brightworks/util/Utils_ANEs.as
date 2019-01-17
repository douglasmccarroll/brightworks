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

// If you're having problems with extensions, ensure that the most recent versions of extension and of "common dependency extensions" are installed
import com.brightworks.component.mobilealert.MobileAlert;
import com.brightworks.component.mobilealert.MobileDialog;
import com.brightworks.constant.Constant_Private;
import com.brightworks.util.audio.Utils_ANEs_Audio;
import com.distriqt.extension.dialog.Dialog;
import com.distriqt.extension.dialog.DialogTheme;
import com.distriqt.extension.dialog.DialogView;
import com.distriqt.extension.dialog.Gravity;
import com.distriqt.extension.dialog.builders.AlertBuilder;
import com.distriqt.extension.dialog.events.DialogViewEvent;
import com.langcollab.languagementor.constant.Constant_AppConfiguration;
import com.langcollab.languagementor.model.MainModel;
import com.myflashlab.air.extensions.barcode.Barcode;
import com.myflashlab.air.extensions.barcode.BarcodeEvent;
import com.myflashlab.air.extensions.nativePermissions.PermissionCheck;
import com.myflashlab.air.extensions.rateme.RateMe;
import com.myflashlab.air.extensions.rateme.RateMeEvents;

/*
import com.myflashlab.air.extensions.fb.Facebook;
import com.myflashlab.air.extensions.fb.FacebookEvents;
import com.myflashlab.air.extensions.fb.ShareLinkContent;
*/

import flash.events.Event;


/*


 NOTE: We have two versions of this class - one for our mobile production projects and one for our
 desktop debugging project. Many ANEs don't support Windows/Mac, so we use a dummy methods
 for the desktop case.

 This is the Production version.


*/
public class Utils_ANEs {
   private static var _codeScanner:Barcode;
   private static var _codeScanCancelCallback:Function;
   private static var _codeScanResultCallback:Function;
   private static var _dialogAlert:DialogView;
   private static var _dialogCallback:Function;
   private static var _isDialogExtensionInitialized:Boolean;
   private static var _isFacebookExtensionInitialized:Boolean;
   private static var _isPermissionGranted_Camera:Boolean;
   private static var _isPermissionGranted_Microphone:Boolean;
   private static var _isRateMeExtensionInitialized:Boolean;

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
      _codeScanner.open([Barcode.QR], null, true);
   }

   /*public static function facebookShare():void {
      var content:ShareLinkContent = new ShareLinkContent();
      content.quote = Constant_AppConfiguration.SHARING__FACEBOOK_SHARE_TEXT;
      content.contentUrl = Constant_AppConfiguration.SHARING__FACEBOOK_SHARE_URL;
      Facebook.share.shareDialog(content, onFacebookShareDialogCallback);
   } */

   public static function initialize():void {
      //Facebook.init(Constant_Private.LANGMENTOR_FACEBOOK_APP_ID);
      //Facebook.listener.addEventListener(FacebookEvents.INIT, onFacebookANEInit);
      PermissionCheck.init();
   }

   public static function requestCameraPermission(callback:Function):void {
      if (_isPermissionGranted_Camera)
         callback(true);
      PermissionCheck.request(PermissionCheck.SOURCE_CAMERA, function(o:Object):void {
               if (o.state == PermissionCheck.PERMISSION_GRANTED) {
                  _isPermissionGranted_Camera = true;
                  callback(true);
               } else {
                  callback(false);
               }
            }
      );
   }

   public static function requestMicrophonePermission(callback:Function):void {
      if (_isPermissionGranted_Microphone)
         callback(true);
      PermissionCheck.request(PermissionCheck.SOURCE_MIC, function(o:Object):void {
               if (o.state == PermissionCheck.PERMISSION_GRANTED) {
                  _isPermissionGranted_Microphone = true;
                  callback(true);
               } else {
                  callback(false);
               }
            }
      );
   }

   public static function showAlert_OkayButton(alertText:String, callback:Function = null):void {
      _dialogCallback = callback;
      initializeDialogExtensionIfNeeded();
      if (Dialog.isSupported) {
         _dialogAlert = Dialog.service.create(
               new AlertBuilder(true)
                     .setTitle("")
                     .setMessage(alertText)
                     .setTheme(new DialogTheme(DialogTheme.LIGHT))
                     .addOption("OK")
                     .build()
         );
         _dialogAlert.addEventListener(DialogViewEvent.CLOSED, onDialogAlertClose);
         _dialogAlert.show();
      } else {
         MobileDialog.open(alertText, callback);
      }
   }

   public static function showAlert_Toast(alertText:String, useLongDisplay:Boolean = false):void {
      if (MainModel.getInstance().isAppRunningInBackground)  // We don't show toast alerts if the app is running in the background
            return;
      initializeDialogExtensionIfNeeded();
      if (Dialog.isSupported) {
         Dialog.service.toast(alertText, useLongDisplay ? Dialog.LENGTH_LONG : Dialog.LENGTH_SHORT, 0x9999FF, Gravity.MIDDLE, .8);
      } else {
         MobileAlert.open(alertText, true, 1000);
      }
   }

   public static function showRatingsPrompt():void {     ///// 20190116   This currently gets called after 25 lessons have been entered - but then it seems to keep getting called too often - every time we leave the lesson select screen?
      initializeRateMeIfNeeded();
      /////RateMe.api.promote();
   }

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   //
   //          Private Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   private static function initializeDialogExtensionIfNeeded():void {
      if (!_isDialogExtensionInitialized) {
         try {
            Dialog.init(Constant_AppConfiguration.ANE_KEY__DISTRIQT);
            _isDialogExtensionInitialized = true;
         }
         catch (e:Error) {
            Log.error("Utils_ANEs_Audio.initializeMediaPlayerIfNeeded(): " + e.message);
         }
      }
   }

   private static function initializeRateMeIfNeeded():void {      /////
      return;
      if (!_isRateMeExtensionInitialized) {
         RateMe.init();
         RateMe.api.addEventListener(RateMeEvents.ERROR, onRateMeError);
         RateMe.api.autoPromote = false;
         RateMe.api.daysUntilPrompt = 1000;
         RateMe.api.launchesUntilPrompt = 1000;
         RateMe.api.remindPeriod = 130;  // Number of days before next prompt, if user has clicked the "remind me later" button
         RateMe.api.title = "Please Rate " + Constant_AppConfiguration.CURRENT_MENTOR_TYPE__DISPLAY_NAME;
         RateMe.api.message = "This will take you to the " + Utils_System.getAppStoreName() + ". Proceed?";
         RateMe.api.remindBtnLabel = "Maybe Later";
         RateMe.api.cancelBtnLabel = "Don't Ask Again";
         RateMe.api.rateBtnLabel = "Yes";
         RateMe.api.promptForNewVersionIfUserRated = false;
         RateMe.api.onlyPromptIfLatestVersion = false;
         RateMe.api.useSKStoreReviewController = true;
         RateMe.api.storeType = RateMe.GOOGLEPLAY; // or RateMe.AMAZON  - only used on Android
         RateMe.api.monitor();
         _isRateMeExtensionInitialized = true;
      }
   }

   private static function onCodeScanCancel(event:BarcodeEvent):void {
      _codeScanCancelCallback();
   }

   private static function onCodeScanResult(event:BarcodeEvent):void {
      _codeScanResultCallback(event.param.data);
   }

   private static function onDialogAlertClose(event:DialogViewEvent):void {
      _dialogAlert.removeEventListener(DialogViewEvent.CLOSED, onDialogAlertClose);
      _dialogAlert.dispose();
      if (_dialogCallback is Function)
            _dialogCallback();
   }

   private static function onFacebookANEInit(e:Event):void {
      _isFacebookExtensionInitialized = true;
   }

   private static function onFacebookShareDialogCallback(isCanceled:Boolean, e:Error):void {
      if (e) {
         Log.error("Utils_ANEs.onFacebookShareDialogCallback() Error: " + e.message);
      }
   }

   private static function onRateMeError(e:RateMeEvents):void {
      Log.error("Utils_ANEs.onRateMeError() Error: " + e.msg);
   }

}
}



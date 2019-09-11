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
import com.brightworks.util.audio.Utils_Audio_Files;
import com.distriqt.extension.applicationrater.ApplicationRater;
import com.distriqt.extension.dialog.Dialog;
import com.distriqt.extension.dialog.DialogTheme;
import com.distriqt.extension.dialog.DialogView;
import com.distriqt.extension.dialog.Gravity;
import com.distriqt.extension.dialog.builders.AlertBuilder;
import com.distriqt.extension.dialog.events.DialogViewEvent;
import com.distriqt.extension.dialog.objects.DialogAction;
import com.distriqt.extension.dialog.objects.DialogParameters;
import com.distriqt.extension.scanner.AuthorisationStatus;
import com.distriqt.extension.scanner.Scanner;
import com.distriqt.extension.scanner.ScannerOptions;
import com.distriqt.extension.scanner.events.AuthorisationEvent;
import com.distriqt.extension.scanner.events.ScannerEvent;
import com.langcollab.languagementor.constant.Constant_MentorTypeSpecific;
import com.langcollab.languagementor.model.MainModel;

/*


 NOTE: We have two versions of this class - one for our mobile production projects and one for our
 desktop debugging project. Many ANEs don't support Windows/Mac, so we use a dummy methods
 for the desktop case.

 This is the Production version.


*/


public class Utils_ANEs {
   private static var _cameraPermissionCallback:Function;
   private static var _codeScanCancelCallback:Function;
   private static var _codeScanErrorCallback:Function;
   private static var _codeScanResultCallback:Function;
   private static var _dialogAlert:DialogView;
   private static var _dialogCallback:Function;
   private static var _isDialogExtensionInitialized:Boolean;

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   //
   //          Public Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   public static function activateCodeScanner(codeScanResultCallback:Function, codeScanCancelCallback:Function, codeScanFailureCallback:Function):void {
      if (!Scanner.isSupported) {
         codeScanFailureCallback();
         return;
      }
      _codeScanCancelCallback = codeScanCancelCallback;
      _codeScanErrorCallback = codeScanFailureCallback;
      _codeScanResultCallback = codeScanResultCallback;
      Scanner.service.addEventListener(ScannerEvent.CODE_FOUND, onCodeScanResult);
      Scanner.service.addEventListener(ScannerEvent.CANCELLED, onCodeScanCancel);
      Scanner.service.addEventListener(ScannerEvent.ERROR, onCodeScanError);
      var options:ScannerOptions = new ScannerOptions();
      options.singleResult = true;
      Scanner.service.startScan(options);
   }

   public static function initialize():void {
      initApplicationRater();
   }

   public static function requestCameraPermissionForScanner(callback:Function):void {
      if (Scanner.service.authorisationStatus() == com.distriqt.extension.scanner.AuthorisationStatus.AUTHORISED)
         callback(true);
      if (Scanner.service.authorisationStatus() == com.distriqt.extension.scanner.AuthorisationStatus.DENIED)
         callback(false);
      _cameraPermissionCallback = callback;
      Scanner.service.addEventListener(com.distriqt.extension.scanner.events.AuthorisationEvent.CHANGED, onCameraPermissionRequestResult);
      Scanner.service.requestAccess();
   }

   public static function showAlert_MultipleOptions(messageText:String, optionDisplayNames:Array, callback:Function):void {
      _dialogCallback = callback;
      initializeDialogExtensionIfNeeded();
      if (Dialog.isSupported) {
         var alertBuilder:AlertBuilder = new AlertBuilder();
         alertBuilder.setTitle("");
         alertBuilder.setMessage(messageText);
         alertBuilder.setTheme(new DialogTheme(DialogTheme.LIGHT));
         for (var i:uint = 0; i < optionDisplayNames.length; i++) {
            alertBuilder.addOption(optionDisplayNames[i], DialogAction.STYLE_DEFAULT, i);
         }
         alertBuilder.addOption("Cancel", DialogAction.STYLE_CANCEL, -1);
         var params:DialogParameters = alertBuilder.build();
         _dialogAlert = Dialog.service.create(params);
         _dialogAlert.addEventListener( DialogViewEvent.CLOSED, onMultiOptionDialogClose);
         _dialogAlert.show();
      }
   }

   public static function showAlert_OkayButton(alertText:String, callback:Function = null):void {
      _dialogCallback = callback;
      initializeDialogExtensionIfNeeded();
      if (Dialog.isSupported) {
         _dialogAlert = Dialog.service.create(
               new AlertBuilder()
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

   public static function showRatingsPromptIfAppropriate():void {
      if (ApplicationRater.service.hasMetConditions()) {
         if (ApplicationRater.service.review.isSupported) {
            ApplicationRater.service.review.requestReview();
            ApplicationRater.service.lastPromptDate = new Date();
            ApplicationRater.service.state = ApplicationRater.STATE_LATER;
         }
         else {
            var title:String = "Please Rate";
            var message:String = "\n" +
                  "Are you enjoying " + Constant_MentorTypeSpecific.APP_NAME__FULL + "?\n" +
                  "If so, could you please leave us a review?\n" +
                  "\n" +
                  "This will take you to the " + Utils_System.getAppStoreName() + ". Proceed?";
            var rateLabel:String = "Yes";
            var laterLabel:String = "Maybe Later";
            var declineLabel:String = "Don't Ask Again";
            ApplicationRater.service.setDialogTitle(title);
            ApplicationRater.service.setDialogMessage(message);
            ApplicationRater.service.setLabels(rateLabel, declineLabel, laterLabel);
            ApplicationRater.service.showRateDialog();
         }
      }
   }

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   //
   //          Private Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   private static function initApplicationRater():void {
      ApplicationRater.service.autoPrompt = false;
      ApplicationRater.service.setDaysUntilPrompt(-1);
      ApplicationRater.service.setLaunchesUntilPrompt(5);
      ApplicationRater.service.setTimeBeforeReminding(15);
      ApplicationRater.service.setApplicationId(Constant_MentorTypeSpecific.APPLE_APP_ID, ApplicationRater.IMPLEMENTATION_IOS);
      ApplicationRater.service.setApplicationId("air." + Utils_AIR.appId, ApplicationRater.IMPLEMENTATION_ANDROID);
      ApplicationRater.service.applicationLaunched();
   }

   private static function initializeDialogExtensionIfNeeded():void {
      if (!_isDialogExtensionInitialized) {
         try {
            Dialog.init(Constant_MentorTypeSpecific.ANE_KEY__DISTRIQT);
            _isDialogExtensionInitialized = true;
         }
         catch (e:Error) {
            Log.error("Utils_ANEs_Audio.initializeMediaPlayerIfNeeded(): " + e.message);
         }
      }
   }

   private static function onCameraPermissionRequestResult(e:com.distriqt.extension.scanner.events.AuthorisationEvent):void {
      _cameraPermissionCallback((e.status == com.distriqt.extension.scanner.AuthorisationStatus.AUTHORISED));
   }

   private static function onCodeScanCancel(event:ScannerEvent):void {
      _codeScanCancelCallback();
   }

   private static function onCodeScanError(event:ScannerEvent):void {
      _codeScanErrorCallback();
   }

   private static function onCodeScanResult(event:ScannerEvent):void {
      _codeScanResultCallback(event.data);
   }

   private static function onDialogAlertClose(event:DialogViewEvent):void {
      Utils_Audio_Files.playClick();
      _dialogAlert.removeEventListener(DialogViewEvent.CLOSED, onDialogAlertClose);
      _dialogAlert.dispose();
      if (_dialogCallback is Function)
            _dialogCallback();
   }

   private static function onMultiOptionDialogClose(event:DialogViewEvent):void {
      Utils_Audio_Files.playClick();
      _dialogAlert.removeEventListener(DialogViewEvent.CLOSED, onMultiOptionDialogClose);
      _dialogAlert.dispose();
      if (_dialogCallback is Function)
         _dialogCallback(event.index);
   }


}
}



/*
 Copyright 2008, 2009, 2010, 2011, 2012 Brightworks, Inc.

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
import com.brightworks.constant.Constant_Private;
import com.distriqt.extension.googleanalytics.GoogleAnalytics;
import com.distriqt.extension.googleanalytics.Tracker;
import com.distriqt.extension.googleanalytics.builders.EventBuilder;
import com.distriqt.extension.googleanalytics.builders.ItemBuilder;
import com.distriqt.extension.googleanalytics.builders.ScreenViewBuilder;
import com.distriqt.extension.googleanalytics.builders.TimingBuilder;
import com.distriqt.extension.googleanalytics.builders.TransactionBuilder;
/*
import com.milkmangames.nativeextensions.GATracker;
import com.milkmangames.nativeextensions.GAnalytics;
import com.milkmangames.nativeextensions.GoViral;
import com.milkmangames.nativeextensions.RateBox;
import com.milkmangames.nativeextensions.events.GVFacebookEvent;
import com.milkmangames.nativeextensions.events.GVTwitterEvent;
*/

import flash.events.Event;

// Note - If you're having problems with MyFlashLab extensions, ensure that the most recent versions of androidSupport and overrideAir 'common dependency extensions' are installed
import com.myflashlab.air.extensions.barcode.Barcode;
import com.myflashlab.air.extensions.barcode.BarcodeEvent;
import com.myflashlab.air.extensions.nativePermissions.PermissionCheck;

/*




 NOTE: This class has separate versions for our production project and our
 desktop debugging project. Many ANEs don't support
 Windows/Mac, so we use a dummy class/methods for that case.




 */
public class Utils_NativeExtensions {

   public static const GOOGLE_ANALYTICS_CATEGORY__APP_STARTUP:String = "App Startup";
   public static const GOOGLE_ANALYTICS_CATEGORY__LESSON_ENTERED:String = "Lesson Entered";
   public static const GOOGLE_ANALYTICS_CATEGORY__LESSON_LEARNED:String = "Lesson Learned";

   private static var _codeScanner:Barcode;
   private static var _codeScanCancelCallback:Function;
   private static var _codeScanResultCallback:Function;
   private static var _googleAnalyticsTracker:Tracker;
   private static var _isGoogleAnalyticsInitialized:Boolean;
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

   public static function facebookInvite(inviteText:String, resultCallbackFunc:Function):void {
      /*_facebookInviteText = inviteText;
      _facebookInviteResultFunc = resultCallbackFunc;
      initGoViral();
      if (!_goViralExtension.isFacebookAuthenticated()) {
         _goViralExtension.addEventListener(GVFacebookEvent.FB_LOGGED_IN, onFacebookResult_AuthenticateForInvite);
         _goViralExtension.addEventListener(GVFacebookEvent.FB_LOGIN_CANCELED, onFacebookResult_AuthenticateForInvite);
         _goViralExtension.addEventListener(GVFacebookEvent.FB_LOGIN_FAILED, onFacebookResult_AuthenticateForInvite);
         _goViralExtension.authenticateWithFacebook("");
      } else {
         onFacebookResult_AuthenticateForInvite();
      }*/
   }

   public static function googleAnalyticsTrackAppStartup(appName:String, extraParams:Object):void
   {
      googleAnalyticsTrackEvent(GOOGLE_ANALYTICS_CATEGORY__APP_STARTUP, appName, null, NaN, extraParams);
   }

   public static function googleAnalyticsTrackLessonEntered(lessonName:String, lessonId:String, lessonVersion:String, providerId:String):void
   {
      googleAnalyticsTrackEvent(GOOGLE_ANALYTICS_CATEGORY__LESSON_ENTERED, lessonName + " " + lessonVersion, null, NaN, {lessonId:lessonId, providerId:providerId});
   }

   public static function googleAnalyticsTrackLessonLearned(lessonName:String, lessonVersion:String):void
   {
      googleAnalyticsTrackEvent(GOOGLE_ANALYTICS_CATEGORY__LESSON_LEARNED, lessonName + " " + lessonVersion);
   }

   public static function isFacebookSupported():Boolean {
      initGoViral();
      return false;  //return _goViralExtension.isFacebookSupported();
   }

   // MyFlashLabs PermissionCheck needed for AIR 24 and later
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

   public static function showRatingsPrompt():void {
      /*if (!RateBox.isSupported())
         return;
      initRateBox();
      _rateBoxExtension.showRatingPrompt("Rate Language Mentor", "This will take you to the " + Utils_System.getAppStoreName() + ". Proceed?", "Yes!", "Maybe Later", "No");*/
   }

   public static function tweet(tweetText:String, resultCallbackFunc:Function):void {
      /*_tweetResultFunc = resultCallbackFunc;
      initGoViral();
      _goViralExtension.addEventListener(GVTwitterEvent.TW_DIALOG_CANCELED, onTweetResult);
      _goViralExtension.addEventListener(GVTwitterEvent.TW_DIALOG_FAILED, onTweetResult);
      _goViralExtension.addEventListener(GVTwitterEvent.TW_DIALOG_FINISHED, onTweetResult);
      _goViralExtension.showTweetSheet(tweetText);*/
   }

   public static function vibrate(duration:uint = 1):void {
   }

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   //
   //          Private Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   private static function googleAnalyticsTrackEvent(
         category:String,
         action:String,
         label:String = null,
         value:Number = NaN,
         extraParams:Object = null):void {
      if (!_isGoogleAnalyticsInitialized) {
         try {
            GoogleAnalytics.init("com.brightworks.LangMentor.standard");
            if (GoogleAnalytics.isSupported) {
               _googleAnalyticsTracker = GoogleAnalytics.service.getTracker("UA-370084-7");
               _googleAnalyticsTracker.setValue( "&uid", "com.brightworks.LangMentor.global.anonymous_user" );
            }
            _isGoogleAnalyticsInitialized = true;
         } catch (e:Error) {
            Log.error("Utils_NativeExtensions.googleAnalyticsTrackEvent(): ANE initialization failed: " + e.message);
            return;
         }
      }
      if (!GoogleAnalytics.isSupported)
         return;
      _googleAnalyticsTracker.send(
            new EventBuilder()
                  .setCategory(category)
                  .setAction(action)
                  .setValue(value)
                  .build() );
   }

   private static function initGoViral():void {
      /*if (!_goViralExtension) {
         _goViralExtension = GoViral.create();
         _goViralExtension.initFacebook(Constant_Private.LANGMENTOR_FACEBOOK_APP_ID);
      }
*/
   }

   private static function initRateBox():void {
      /*if (!_rateBoxExtension) {
         _rateBoxExtension = RateBox.create("", "", "");
         if (Utils_System.isIOS() && Utils_System.isAlphaOrBetaVersion())
            _rateBoxExtension.useTestMode();
         _rateBoxExtension.setAutoPrompt(false);
      }*/
   }

   private static function onFacebookResult_AuthenticateForInvite(event:Event):void {  //GVFacebookEvent = null):void {
      /*if ((event) && (_goViralExtension)) {
         _goViralExtension.removeEventListener(GVFacebookEvent.FB_LOGGED_IN, onFacebookResult_AuthenticateForInvite);
         _goViralExtension.removeEventListener(GVFacebookEvent.FB_LOGIN_CANCELED, onFacebookResult_AuthenticateForInvite);
         _goViralExtension.removeEventListener(GVFacebookEvent.FB_LOGIN_FAILED, onFacebookResult_AuthenticateForInvite);
      }
      var isSuccessfulAuthentication:Boolean = true;
      if ((event) &&
            ((event.type == GVFacebookEvent.FB_LOGIN_CANCELED) ||
            (event.type == GVFacebookEvent.FB_LOGIN_FAILED))) {
         isSuccessfulAuthentication = false;
      }
      if ((isSuccessfulAuthentication) && (_goViralExtension)) {
         _goViralExtension.addEventListener(GVFacebookEvent.FB_DIALOG_CANCELED, onFacebookResult_Invite);
         _goViralExtension.addEventListener(GVFacebookEvent.FB_DIALOG_FAILED, onFacebookResult_Invite);
         _goViralExtension.addEventListener(GVFacebookEvent.FB_DIALOG_FINISHED, onFacebookResult_Invite);
         _goViralExtension.showFacebookRequestDialog(
               _facebookInviteText,
               "Invite your Friends");
      } else {
         if (_facebookInviteResultFunc is Function) {
            _facebookInviteResultFunc(false);
            _facebookInviteResultFunc = null;
         }
      }*/
   }

   private static function onFacebookResult_Invite(event:Event):void {  //GVFacebookEvent):void {
      /*if (_facebookInviteResultFunc is Function) {
         _facebookInviteResultFunc(event.type == GVFacebookEvent.FB_DIALOG_FINISHED);
         _facebookInviteResultFunc = null;
      }
      if (_goViralExtension) {
         _goViralExtension.removeEventListener(GVFacebookEvent.FB_DIALOG_CANCELED, onFacebookResult_Invite);
         _goViralExtension.removeEventListener(GVFacebookEvent.FB_DIALOG_FAILED, onFacebookResult_Invite);
         _goViralExtension.removeEventListener(GVFacebookEvent.FB_DIALOG_FINISHED, onFacebookResult_Invite);
      }*/
   }

   private static function onCodeScanCancel(event:BarcodeEvent):void {
      _codeScanCancelCallback();
   }

   private static function onCodeScanResult(event:BarcodeEvent):void {
      _codeScanResultCallback(event.param.data);
   }

   private static function onTweetResult(event:Event):void {  //GVTwitterEvent):void {
      /*if (_goViralExtension) {
         _goViralExtension.removeEventListener(GVTwitterEvent.TW_DIALOG_CANCELED, onTweetResult);
         _goViralExtension.removeEventListener(GVTwitterEvent.TW_DIALOG_FAILED, onTweetResult);
         _goViralExtension.removeEventListener(GVTwitterEvent.TW_DIALOG_FINISHED, onTweetResult);
      }
      if (_tweetResultFunc is Function)
         _tweetResultFunc();*/
   }

}
}



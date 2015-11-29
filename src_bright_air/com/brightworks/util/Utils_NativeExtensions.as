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




NOTE: This class has separate versions for our production project and our
      desktop debugging project. Many ANEs don't support
      Windows, so we use a dummy class/methods for that case.




*/
package com.brightworks.util {
   import com.brightworks.constant.Constant_Private;
   import com.milkmangames.nativeextensions.GoViral;
   import com.milkmangames.nativeextensions.RateBox;
   import com.milkmangames.nativeextensions.events.GVFacebookEvent;
   import com.milkmangames.nativeextensions.events.GVTwitterEvent;
   import com.sbhave.nativeExtensions.zbar.Config;
   import com.sbhave.nativeExtensions.zbar.Scanner;
   import com.sbhave.nativeExtensions.zbar.ScannerEvent;
import com.sbhave.nativeExtensions.zbar.Size;
import com.sbhave.nativeExtensions.zbar.Symbology;

   public class Utils_NativeExtensions {
      private static var _codeScanEventCallback:Function;
      private static var _codeScanner:Scanner;
      private static var _facebookInviteResultFunc:Function;
      private static var _facebookInviteText:String;
      private static var _goViralExtension:GoViral;
      private static var _rateBoxExtension:RateBox;
      private static var _tweetResultFunc:Function;

      // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
      //
      //          Public Methods
      //
      // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

      public static function activateCodeScanner(size:int, scanEventCallback:Function):void {
         if (!(_codeScanner))
            _codeScanner = new Scanner();
         _codeScanEventCallback = scanEventCallback;
         _codeScanner.setDimensions(size, size);
         //_codeScanner.setTargetArea(size, "0xFF0000", "0x00FF00");
         _codeScanner.setConfig(Symbology.QRCODE, Config.ENABLE, 1);
         _codeScanner.addEventListener(ScannerEvent.SCAN, onScan);
         _codeScanner.startPreview();
      }

      public static function facebookInvite(inviteText:String, resultCallbackFunc:Function):void {
         _facebookInviteText = inviteText;
         _facebookInviteResultFunc = resultCallbackFunc;
         initGoViral();
         if (!_goViralExtension.isFacebookAuthenticated()) {
            _goViralExtension.addEventListener(GVFacebookEvent.FB_LOGGED_IN, onFacebookResult_AuthenticateForInvite);
            _goViralExtension.addEventListener(GVFacebookEvent.FB_LOGIN_CANCELED, onFacebookResult_AuthenticateForInvite);
            _goViralExtension.addEventListener(GVFacebookEvent.FB_LOGIN_FAILED, onFacebookResult_AuthenticateForInvite);
            _goViralExtension.authenticateWithFacebook("");
         } else {
            onFacebookResult_AuthenticateForInvite();
         }
      }

      public static function isFacebookSupported():Boolean {
         initGoViral();
         return _goViralExtension.isFacebookSupported();
      }

      public static function showRatingsPrompt():void {
         if (!RateBox.isSupported())
            return;
         initRateBox();
         _rateBoxExtension.showRatingPrompt("Rate Language Mentor", "This will take you to the " + Utils_System.getAppStoreName() + ". Proceed?", "Yes!", "Maybe Later", "No");
      }

      public static function tweet(tweetText:String, resultCallbackFunc:Function):void {
         _tweetResultFunc = resultCallbackFunc;
         initGoViral();
         _goViralExtension.addEventListener(GVTwitterEvent.TW_DIALOG_CANCELED, onTweetResult);
         _goViralExtension.addEventListener(GVTwitterEvent.TW_DIALOG_FAILED, onTweetResult);
         _goViralExtension.addEventListener(GVTwitterEvent.TW_DIALOG_FINISHED, onTweetResult);
         _goViralExtension.showTweetSheet(tweetText);
      }

      public static function vibrate(duration:uint = 1):void {
      }

      // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
      //
      //          Private Methods
      //
      // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

      private static function initGoViral():void {
         if (!_goViralExtension) {
            _goViralExtension = GoViral.create();
            _goViralExtension.initFacebook(Constant_Private.LANGMENTOR_FACEBOOK_APP_ID);
         }

      }

      private static function initRateBox():void {
         if (!_rateBoxExtension) {
            _rateBoxExtension = RateBox.create("", "", "");
            if (Utils_System.isIOS() && Utils_System.isAlphaOrBetaVersion())
               _rateBoxExtension.useTestMode();
            _rateBoxExtension.setAutoPrompt(false);
         }
      }

      private static function onFacebookResult_AuthenticateForInvite(event:GVFacebookEvent = null):void {
         if ((event) && (_goViralExtension)) {
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
         }
      }

      private static function onFacebookResult_Invite(event:GVFacebookEvent):void {
         if (_facebookInviteResultFunc is Function) {
            _facebookInviteResultFunc(event.type == GVFacebookEvent.FB_DIALOG_FINISHED);
            _facebookInviteResultFunc = null;
         }
         if (_goViralExtension) {
            _goViralExtension.removeEventListener(GVFacebookEvent.FB_DIALOG_CANCELED, onFacebookResult_Invite);
            _goViralExtension.removeEventListener(GVFacebookEvent.FB_DIALOG_FAILED, onFacebookResult_Invite);
            _goViralExtension.removeEventListener(GVFacebookEvent.FB_DIALOG_FINISHED, onFacebookResult_Invite);
         }
      }

      private static function onScan(event:ScannerEvent):void {
         if (_codeScanner) {
            _codeScanner.stopPreview();
            _codeScanner.removeEventListener(ScannerEvent.SCAN, _codeScanEventCallback);
         }
         _codeScanEventCallback(event.data);
      }

      private static function onTweetResult(event:GVTwitterEvent):void {
         if (_goViralExtension) {
            _goViralExtension.removeEventListener(GVTwitterEvent.TW_DIALOG_CANCELED, onTweetResult);
            _goViralExtension.removeEventListener(GVTwitterEvent.TW_DIALOG_FAILED, onTweetResult);
            _goViralExtension.removeEventListener(GVTwitterEvent.TW_DIALOG_FINISHED, onTweetResult);
         }
         if (_tweetResultFunc is Function)
            _tweetResultFunc();
      }

   }
}






























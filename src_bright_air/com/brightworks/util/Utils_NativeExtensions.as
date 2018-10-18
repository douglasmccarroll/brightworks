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
import com.distriqt.extension.mediaplayer.MediaInfo;
import com.distriqt.extension.mediaplayer.MediaPlayer;
import com.distriqt.extension.mediaplayer.audio.AudioPlayer;
import com.distriqt.extension.mediaplayer.audio.AudioPlayerOptions;
import com.distriqt.extension.mediaplayer.events.AudioPlayerEvent;
import com.distriqt.extension.mediaplayer.events.MediaErrorEvent;
import com.distriqt.extension.mediaplayer.events.RemoteCommandCenterEvent;
import com.langcollab.languagementor.constant.Constant_AppConfiguration;
import com.myflashlab.air.extensions.barcode.Barcode;
import com.myflashlab.air.extensions.barcode.BarcodeEvent;
import com.myflashlab.air.extensions.nativePermissions.PermissionCheck;
import com.myflashlab.air.extensions.rateme.RateMe;
import com.myflashlab.air.extensions.rateme.RateMeEvents;

import flash.filesystem.File;

//import com.myflashlab.air.extensions.fb.AccessToken;
//import com.myflashlab.air.extensions.fb.Facebook;
//import com.myflashlab.air.extensions.fb.FacebookEvents;
//import com.myflashlab.air.extensions.fb.ShareLinkContent;
/*




 NOTE: We have two versions of this class - one for our production projects and one for our
 desktop debugging project. Many ANEs don't support Windows/Mac, so we use a dummy methods
 for the desktop case.

 This is the production version.


*/
public class Utils_NativeExtensions {
   private static var _audioCallback:Function;
   private static var _audioPlayer:AudioPlayer;
   private static var _codeScanner:Barcode;
   private static var _codeScanCancelCallback:Function;
   private static var _codeScanResultCallback:Function;
   //private static var _facebookShareResultCallback:Function;
   //private static var _isFacebookExtensionInitialized:Boolean;
   private static var _isMediaPlayerExtensionInitialized:Boolean;
   private static var _isRateMeExtensionInitialized:Boolean;
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
                                             
   public static function audioPlay(file:File, volume:Number):void {
      initializeAudioPlayerIfNeeded();
      _audioPlayer.setVolume(volume);
      _audioPlayer.addEventListener(AudioPlayerEvent.COMPLETE, onAudioPlayerComplete);
      _audioPlayer.addEventListener(MediaErrorEvent.ERROR, onAudioPlayerError);
      _audioPlayer.addEventListener(AudioPlayerEvent.LOADED, onAudioPlayerLoaded);
      _audioPlayer.addEventListener(AudioPlayerEvent.LOADING, onAudioPlayerLoading);
      _audioPlayer.loadFile(file);
   }

   public static function audioStopMediaPlayer():void {
      if (!_audioPlayer)
         return;
      _audioPlayer.removeEventListener(AudioPlayerEvent.COMPLETE, onAudioPlayerComplete);
      _audioPlayer.removeEventListener(MediaErrorEvent.ERROR, onAudioPlayerError);
      _audioPlayer.removeEventListener(AudioPlayerEvent.LOADED, onAudioPlayerLoaded);
      _audioPlayer.removeEventListener(AudioPlayerEvent.LOADING, onAudioPlayerLoading);
      _audioPlayer.stop();
   }

   public static function isMediaPlayerSupported():Boolean {
      initializeMediaPlayerIfNeeded();
      return MediaPlayer.isSupported;
   }

   /*public static function facebookShare(resultCallback:Function):void {
      _facebookShareResultCallback = resultCallback;
      initializeFacebookIfNeeded();
      // Facebook.auth.login(true, [], onFacebookLoginCallback);
      var content:ShareLinkContent = new ShareLinkContent();
      content.quote = Constant_AppConfiguration.SHARING__FACEBOOK_SHARE_TEXT;
      content.contentUrl = Constant_AppConfiguration.SHARING__FACEBOOK_SHARE_URL;
      Facebook.share.shareDialog(content, onFacebookShareDialogCallback);
   }

   public static function isFacebookSupported():Boolean {
      return true;
   }*/

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

   public static function setAudioPlayerCallbackFunction(f:Function):void {
      _audioCallback = f;
   }

   public static function showRatingsPrompt():void {
      initializeRateMeIfNeeded();
      RateMe.api.promote();
   }

   public static function showRatingsPromptIfEnoughLaunches():void {
      initializeRateMeIfNeeded();
      if (RateMe.api.shouldPromote) {
         RateMe.api.promote();
      }
   }

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   //
   //          Private Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   /*private static function initializeFacebookIfNeeded():void {
      if (!_isFacebookExtensionInitialized) {
         Facebook.init(Constant_Private.LANGMENTOR_FACEBOOK_APP_ID);
         _isFacebookExtensionInitialized = true;
      }
   }*/

   private static function initializeAudioPlayerIfNeeded():void {
      initializeMediaPlayerIfNeeded();
      if (!_audioPlayer) {
         try {
            var options:AudioPlayerOptions = new AudioPlayerOptions();
            options.enableBackgroundAudio(true);
            options.enablePlaybackSpeed(true);
            _audioPlayer = MediaPlayer.service.createAudioPlayer(options);
         } catch (e:Error) {
            Log.error("Utils_NativeExtensions.initializeAudioPlayerIfNeeded(): " + e.message);
         }
      }
   }

   private static function initializeMediaPlayerIfNeeded():void {
      if (_isMediaPlayerExtensionInitialized)
         return;
      try {
         MediaPlayer.init(Constant_AppConfiguration.APP_ID);
         MediaPlayer.service.remoteCommandCenter.registerForControlEvents();
         var info:MediaInfo = new MediaInfo();
         info.setTitle("foo");
         info.setArtist("artist");
         info.setCurrentTime(16);
         info.setDuration(160);
         MediaPlayer.service.remoteCommandCenter.setNowPlayingInfo(info);
         MediaPlayer.service.remoteCommandCenter.addEventListener(RemoteCommandCenterEvent.PAUSE, onMediaPlayerUserInput_Pause);
         MediaPlayer.service.remoteCommandCenter.addEventListener(RemoteCommandCenterEvent.PLAY, onMediaPlayerUserInput_Play);
         _isMediaPlayerExtensionInitialized = true;
      } catch (e:Error) {
         Log.error("Utils_NativeExtensions.initializeMediaPlayerIfNeeded(): " + e.message);
      }
   }

   private static function initializeRateMeIfNeeded():void {
      if (!_isRateMeExtensionInitialized) {
         RateMe.init();
         RateMe.api.addEventListener(RateMeEvents.ERROR, onRateMeError);
         RateMe.api.autoPromote = false;
         RateMe.api.daysUntilPrompt = 1000;
         RateMe.api.launchesUntilPrompt = 10;
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

   private static function onAudioPlayerComplete(e:AudioPlayerEvent):void {
      if (!(_audioCallback is Function))
         return;
      _audioCallback(e);
   }

   private static function onAudioPlayerError(e:MediaErrorEvent):void {
      if (!(_audioCallback is Function))
         return;
      _audioCallback(e);
   }

   private static function onAudioPlayerLoaded(e:AudioPlayerEvent):void {
      _audioPlayer.play();
   }

   private static function onAudioPlayerLoading(e:AudioPlayerEvent):void {
   }

   private static function onCodeScanCancel(event:BarcodeEvent):void {
      _codeScanCancelCallback();
   }

   private static function onCodeScanResult(event:BarcodeEvent):void {
      _codeScanResultCallback(event.param.data);
   }

   /*private static function onFacebookLoginCallback(isCanceled:Boolean, e:Error, accessToken:AccessToken, recentlyDeclined:Array, recentlyGranted:Array):void {
      if(e) {
         Log.error("Utils_NativeExtensions.onFacebookLoginCallback() Error: " + e.message);
         _facebookShareResultCallback();
      } else {
         if (isCanceled) {
            _facebookShareResultCallback();
         } else {
            // We assume here that we want to share content because that's the only thing we do w/ FB at present - if we start doing other things we'll need to modify this code
            var content:ShareLinkContent = new ShareLinkContent();
            content.quote = Constant_AppConfiguration.SHARING__FACEBOOK_SHARE_TEXT;
            content.contentUrl = Constant_AppConfiguration.SHARING__FACEBOOK_SHARE_URL;
            Facebook.share.shareDialog(content, onFacebookShareDialogCallback);
         }
      }
   }

   private static function onFacebookShareDialogCallback(isCanceled:Boolean, e:Error):void {
      if (e) {
         Log.error("Utils_NativeExtensions.onFacebookShareDialogCallback() Error: " + e.message);
      }
      _facebookShareResultCallback();
   }*/

   private static function onMediaPlayerUserInput_Pause(e:RemoteCommandCenterEvent):void {
      if (!(_audioCallback is Function))
         return;
      _audioCallback(e);
   }

   private static function onMediaPlayerUserInput_Play(e:RemoteCommandCenterEvent):void {
      if (!(_audioCallback is Function))
         return;
      _audioCallback(e);
   }

   private static function onRateMeError(e:RateMeEvents):void {
      Log.error("Utils_NativeExtensions.onRateMeError() Error: " + e.msg);
   }

}
}



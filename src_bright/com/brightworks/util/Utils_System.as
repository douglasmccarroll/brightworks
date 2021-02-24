/*
    Copyright 2021 Brightworks, Inc.

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
import com.brightworks.constant.Constant_PlatformName;
import com.brightworks.constant.Constant_ReleaseType;

import flash.system.Capabilities;

public class Utils_System {
   public static var appReleaseType:String; // This can be set by each app that uses this class, using a constant from Constant_ReleaseTypes

   private static var _isInitialized:Boolean;
   private static var _isMobileDevice:Boolean;

   // ****************************************************
   //
   //          Getters / Setters
   //
   // ****************************************************

   private static var _appHeight:int;

   public static function get appHeight():int {
      init();
      return _appHeight;
   }

   private static var _appWidth:int;

   public static function get appWidth():int {
      init();
      return _appWidth;
   }

   private static var _dpi:int;

   public static function get dpi():int {
      init();
      return _dpi;
   }

   private static var _isGeneration7OrGreaterIOS:Boolean;

   public static function get isGeneration7OrGreaterIOS():Boolean {
      return _isGeneration7OrGreaterIOS;
   }

   private static var _isIPad:Boolean;

   public static function get isIPad():Boolean {
      return _isIPad;
   }

   private static var _platformName:String;

   public static function get platformName():String {
      return _platformName;
   }

   // ****************************************************
   //
   //          Public Methods
   //
   // ****************************************************

   public static function isAlphaOrBetaVersion():Boolean {
      var result:Boolean = false;
      switch (appReleaseType) {
         case Constant_ReleaseType.ALPHA:
         case Constant_ReleaseType.BETA:
            result = true;
            break;
         default:
            result = false;
      }
      return result;
   }

   public static function isAlphaVersion():Boolean {
      var result:Boolean = false;
      switch (appReleaseType) {
         case Constant_ReleaseType.ALPHA:
            result = true;
            break;
         default:
            result = false;
      }
      return result;
   }

   public static function isAndroid():Boolean {
      return (platformName == Constant_PlatformName.ANDROID);
   }

   public static function isBetaVersion():Boolean {
      var result:Boolean = false;
      switch (appReleaseType) {
         case Constant_ReleaseType.BETA:
            result = true;
            break;
         default:
            result = false;
      }
      return result;
   }

   public static function getAppStoreName():String {
      if (isAndroid())
         return "Play Store";
      return "App Store";
   }

   public static function isInDebugMode():Boolean {
      return Capabilities.isDebugger;
   }

   public static function isIOS():Boolean {
      return (platformName == Constant_PlatformName.IOS);
   }

   public static function isMobilePlatform():Boolean {
      return (isAndroid() || isIOS());
   }

   public static function isScreenResolutionHighEnough(requiredX:uint, requiredY:uint, isMobile:Boolean):Boolean {
      init();
      if ((isMobile) && (!Utils_System._isMobileDevice)) {
         // We're testing on the desktop, and can't check screen size
         return true;
      }
      if (Capabilities.screenResolutionX < requiredX)
         return false;
      if (Capabilities.screenResolutionY < requiredY)
         return false;
      return true;
   }

   public static function isRunningOnDesktop():Boolean {
      init();
      return !_isMobileDevice;
   }

   // ****************************************************
   //
   //          Private Methods
   //
   // ****************************************************

   private static function init():void {
      // _isInitialized is true, without being set to true (?!) when running on Mac desktop
      // In this case, we just init every time this method is called
      var isMac:Boolean = ((Capabilities.os is String) && (Capabilities.os.indexOf("Mac") != -1));
      if (_isInitialized && (!isMac))
         return;
      _isInitialized = true;
      _isMobileDevice = true;
      var operatingSystem:String = Capabilities.os;
      if (operatingSystem.indexOf("Windows") != -1) {
         switch (operatingSystem) {
            case "Windows XP":
            case "Windows 2000":
            case "Windows NT":
            case "Windows 7": {
               _isMobileDevice = false;
               _platformName = Constant_PlatformName.WINDOWS_DESKTOP;
               break;
            }
            default: {
               _platformName = Constant_PlatformName.UNKNOWN;
               Log.fatal("Application does not currently support this operating system. (" + operatingSystem + ")");
            }
         }
      } else if ((operatingSystem.indexOf("iPad") != -1) ||
            (operatingSystem.indexOf("iPhone") != -1) ||
            (operatingSystem.indexOf("iPod") != -1)) {
         _isMobileDevice = true;
         _platformName = Constant_PlatformName.IOS;
         _isIPad = (operatingSystem.indexOf("iPad") != -1);
         setIsGeneration7OrGreaterIOS();
      } else if (operatingSystem.indexOf("Mac") != -1) {
         _isMobileDevice = false;
         _platformName = Constant_PlatformName.MAC;
      } else if (operatingSystem.indexOf("Linux") != -1) {
         // This won't work properly if developing on Linux, but I've spent multiple minutes
         // trying to find out how to differentiate Android from other Linux versions, and
         // haven't found anything that I'm confident will work for future versions of Android.
         // Currently I get "Linux 2.6.32.9-g34b306d". I suspect that the "g" indicates "Google"
         // but have found nothing to support this idea.
         _isMobileDevice = true;
         _platformName = Constant_PlatformName.ANDROID;
      }
      if (_isMobileDevice) {
         _appHeight = Capabilities.screenResolutionY;
         _appWidth = Capabilities.screenResolutionX;
      } else {
         _appHeight = 220;
         _appWidth = 360;
      }
      _dpi = Capabilities.screenDPI;
   }

   private static function setIsGeneration7OrGreaterIOS():void {
      var falseMatchList:Array =
            [
               "iPad1",
               "iPad2",
               "iPad3",
               "iPad4",
               "iPad5",
               "iPad6",
               "iPhone1",
               "iPhone2",
               "iPhone3",
               "iPhone4",
               "iPhone5",
               "iPhone6",
               "iPod1",
               "iPod2",
               "iPod3",
               "iPod4",
               "iPod5",
               "iPod6"];
      for each (var s:String in falseMatchList) {
         if (Capabilities.os.indexOf(s) != -1) {
            _isGeneration7OrGreaterIOS = false;
            return;
         }
      }
      _isGeneration7OrGreaterIOS = true;
   }

}
}

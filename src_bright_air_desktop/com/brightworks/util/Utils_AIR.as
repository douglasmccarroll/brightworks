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


package com.brightworks.util {
import flash.desktop.NativeApplication;
import flash.desktop.SystemIdleMode;
import flash.filesystem.File;
import flash.system.System;

public class Utils_AIR {
   private static var _isAppInfoPropsSet:Boolean = false;

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   //
   //          Getters & Setters
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   private static var _appFileName:String;

   public static function get appFileName():String {
      Utils_AIR.ensureAppInfoPropsAreSet();
      return Utils_AIR._appFileName;
   }

   public static function get appId():String {
      var result:String = NativeApplication.nativeApplication.applicationID;
      return result;
   }

   private static var _appName:String;

   public static function get appName():String {
      Utils_AIR.ensureAppInfoPropsAreSet();
      return Utils_AIR._appName;
   }

   private static var _appVersionLabel:String;

   public static function get appVersionLabel():String {
      Utils_AIR.ensureAppInfoPropsAreSet();
      return Utils_AIR._appVersionLabel;
   }

   private static var _appVersionNumber:Number;

   public static function get appVersionNumber():Number {
      Utils_AIR.ensureAppInfoPropsAreSet();
      return Utils_AIR._appVersionNumber;
   }

   public static function get documentStorageDirectoryURL():String {
      return File.documentsDirectory.nativePath + File.separator + Utils_AIR.appId;
   }

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   //
   //          Public Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   public function Utils_AIR() {
   }

   public static function keepSystemAwake(b:Boolean = true):void {
      if (b) {
         NativeApplication.nativeApplication.systemIdleMode = SystemIdleMode.KEEP_AWAKE;
      } else {
         NativeApplication.nativeApplication.systemIdleMode = SystemIdleMode.NORMAL;
      }
   }

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   //
   //          Private Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   private static function convertVersionNumberToDecimalFormat(numberString:String):Number {
      // This method is needed because, in some cases, AIR converts a version number such as "0.17" to "0.17.0".
      // We prefer to use version numbers that actually convert to a Number. Our solution is simple - remove the
      // second dot and anything that comes after it, then convert what remains into a Number.
      switch (Utils_String.getCountOfSubstringInString(numberString, ".")) {
         case 0:
         case 1:
            // Do nothing - these cases convert to Number
            break;
         case 2:
            var secondDotIndex:uint = numberString.lastIndexOf(".");
            numberString = numberString.substr(0, secondDotIndex);
            break;
         default:
            Log.error("Utils_AIR.convertVersionNumberToDecimalFormat(): version number string has more than two 'dot' characters. This is Very Wrong.");
            return -1;
      }
      var result:Number =
            Utils_DataConversionComparison.isANumberString(numberString) ?
                  Number(numberString) :
                  -1;
      return result;
   }

   private static function ensureAppInfoPropsAreSet():void {
      // We use _isAppInfoPropsSet, and set props once, for two reasons:
      //   1. Obviously, this is better for performance.
      //   2. Less obviously, the second (and subsequent?) time we read
      //      applicationDescriptor all of its nodes are empty.
      if (!Utils_AIR._isAppInfoPropsSet) {
         var descriptor:XML = NativeApplication.nativeApplication.applicationDescriptor;
         var ns:Namespace = descriptor.namespaceDeclarations()[0];
         Utils_AIR._appFileName = descriptor.ns::fileName;
         Utils_AIR._appName = descriptor.ns::name;
         Utils_AIR._appVersionNumber = Utils_AIR.convertVersionNumberToDecimalFormat(descriptor.ns::versionNumber);
         Utils_AIR._appVersionLabel = descriptor.ns::versionLabel;
         Utils_AIR._isAppInfoPropsSet = true;
         System.disposeXML(descriptor);
      }
   }

}
}

class SingletonEnforcer {
}

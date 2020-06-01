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
/*

This class uses the term 'info' in two different ways:
- The standard logging level of 'info', along with 'warn', 'error', etc.
- The 'info' that will get shown to the developer and/or user. This info is collected in
_detailedInfoList and may also be traced to the console.

This dual definition is unfortunate, but I haven't come up with a better term for the
second meaning....   /// Change name for second meaning to "details"? "data"?

*/

import com.brightworks.component.mobilealert.MobileAlert;
import com.brightworks.constant.Constant_PlatformName;
import com.brightworks.constant.Constant_Private;
import com.brightworks.interfaces.ILoggingConfigProvider;
import com.brightworks.interfaces.IManagedSingleton;
import com.brightworks.util.audio.Utils_Audio_Files;
import com.brightworks.util.singleton.SingletonManager;
import com.brightworks.constant.Constant_AppConfiguration;

import flash.desktop.Clipboard;
import flash.desktop.ClipboardFormats;
import flash.events.Event;
import flash.events.UncaughtErrorEvent;
import flash.filesystem.File;
import flash.geom.Point;
import flash.system.Capabilities;
import flash.system.System;
import flash.utils.Dictionary;

import mx.core.SoundAsset;
import mx.rpc.AsyncToken;
import mx.rpc.Responder;
import mx.rpc.http.HTTPService;
import mx.utils.ArrayUtil;

public class Log implements IManagedSingleton {
   public static const LOG_LEVEL__ALWAYS:uint = 6;
   public static const LOG_LEVEL__DEBUG:uint = 1;
   public static const LOG_LEVEL__ERROR:uint = 4;
   public static const LOG_LEVEL__FATAL:uint = 5;
   public static const LOG_LEVEL__INFO:uint = 2;
   public static const LOG_LEVEL__NEVER:uint = 0;
   public static const LOG_LEVEL__WARN:uint = 3;
   public static const LOG_LEVEL_STRING__ALWAYS:String = "Always";
   public static const LOG_LEVEL_STRING__DEBUG:String = "Debug";
   public static const LOG_LEVEL_STRING__ERROR:String = "Error";
   public static const LOG_LEVEL_STRING__FATAL:String = "Fatal";
   public static const LOG_LEVEL_STRING__INFO:String = "Info";
   public static const LOG_LEVEL_STRING__NEVER:String = "Never";
   public static const LOG_LEVEL_STRING__WARN:String = "Warn";

   private static const _COPY_TO_CLIPBOARD_STRING__MAX_LENGTH__ANDROID:Number = 50000;
   private static const _COPY_TO_CLIPBOARD_STRING__MAX_LENGTH__IOS:Number = 50000;
   private static const _COPY_TO_CLIPBOARD_STRING__MAX_LENGTH__WINDOWS_DESKTOP:Number = Number.MAX_VALUE;
   private static const _CURRENT_BREAKPOINT_LEVEL:uint = LOG_LEVEL__WARN;
   private static const _CURRENT_TRACE_LEVEL:uint = LOG_LEVEL__INFO;
   private static const _DETAILED_INFO_LIST__CAPACITY__ALPHA:uint = 300;
   private static const _DETAILED_INFO_LIST__CAPACITY__STANDARD:uint = 3000;

   public static var hasFatalErrorBeenLogged:Boolean;
   public static var inAppLogLevelOverrideLevel:int = LOG_LEVEL__NEVER;
   public static var index_LogLevel_to_LogLevelString:Dictionary;

   private static var _appName:String;
   private static var _configProvider:ILoggingConfigProvider;
   private static var _detailedInfoList:Array; // An array of strings
   private static var _detailedInfoListCapacity:uint;
   private static var _displayDiagnosticsScreenFunction:Function;
   private static var _errorLogUserFeedbackFunction:Function;
   private static var _fatalLogUserFeedbackFunction:Function;
   private static var _httpService:HTTPService;
   private static var _inAppTracingFunction:Function;
   private static var _instance:Log;
   private static var _isDebugMode:Boolean;
   private static var _isInitialized:Boolean;
   private static var _isThrowErrorIfRunningOnDesktopMode:Boolean;
   private static var _summaryStringAppenderCallback:Function;

   private var _performanceAnalyzer:PerformanceAnalyzer;


   public static function debugModeBreakpointHolderMethod():void {
      if (_isThrowErrorIfRunningOnDesktopMode && Utils_System.isRunningOnDesktop()) {
         // Let's throw an error, just in case no breakpoint is set, as has happened repeatedly (and unfortunately)
         // Of course, this will also create an infinite loop as uncaught errors cause Log.warn() to be called....
         var o:Object = Point(new Object());
      }
   }


   // ****************************************************
   //
   //          Public Instance Methods
   //
   // ****************************************************

   public function Log(manager:SingletonManager):void {
      _instance = this;
      Log._detailedInfoListCapacity =
            Utils_System.isAlphaVersion() ?
                  Log._DETAILED_INFO_LIST__CAPACITY__ALPHA :
                  Log._DETAILED_INFO_LIST__CAPACITY__STANDARD;
   }

   // ****************************************************
   //
   //          Public Static Methods
   //
   // ****************************************************

   public static function copyRecentInfoToClipboard():void {
      var s:String = createLogInfoSummaryString() + "\n";
      var maxLength:Number;
      switch (Utils_System.platformName) {
         case Constant_PlatformName.ANDROID:
            maxLength = _COPY_TO_CLIPBOARD_STRING__MAX_LENGTH__ANDROID;
            break;
         case Constant_PlatformName.IOS:
            maxLength = _COPY_TO_CLIPBOARD_STRING__MAX_LENGTH__IOS;
            break;
         case Constant_PlatformName.MAC:
         case Constant_PlatformName.WINDOWS_DESKTOP:
            maxLength = _COPY_TO_CLIPBOARD_STRING__MAX_LENGTH__WINDOWS_DESKTOP;
            break;
         default:
            maxLength = 5000;
            Log.warn("Log.copyRecentInfoToClipboard(): no case for Utils_System.platformName: " + Utils_System.platformName);
      }
      var index:int = _detailedInfoList.length;
      while (true) {
         index--;
         if (index < 0)
            break;
         s += _detailedInfoList[index] + "\n";
         if (s.length >= maxLength)
            break;
      }
      Clipboard.generalClipboard.clear();
      Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, s);
   }

   public static function createLogInfoSummaryString():String {
      var result:String = "";
      result += Utils_DateTime.getCurrentDateTimeIn_YYYYMMDDdotHHMMcolonTimeZoneOffset_Format() + "\n";
      result += _appName + " " + "\n";
      result += Capabilities.manufacturer + "\n";
      result += Capabilities.os + "\n";
      result +=
            Capabilities.screenResolutionX +
            "x" +
            Capabilities.screenResolutionY +
            " " +
            Capabilities.screenDPI +
            "dpi\n";
      result += "loops/ms: " + Log._instance._performanceAnalyzer.loopsPerMS + "\n";
      var docsFolder:File = File.documentsDirectory;
      var cacheFolder:File = File.cacheDirectory;
      result += "Logs: " + _detailedInfoList.length + "/" + _detailedInfoListCapacity + "\n";
      result +=
            "Docs/Cache space: " +
            Math.round(docsFolder.spaceAvailable / (1024 * 1024)) + "MB" +
            "/";
      if (cacheFolder) {
         result += Math.round(cacheFolder.spaceAvailable / (1024 * 1024)) + "MB";
      } else {
         result += "NA";
      }
      result += "\n";
      if (_summaryStringAppenderCallback is Function)
         result = _summaryStringAppenderCallback(result) + "\n";
      result += "mb key: air in-use mb / air total mb / app mb\n";
      return result;
   }

   public static function debug(info:Object):void {
      if (!Log._isInitialized)
         return;
      doLoggingStuffSharedByAllLoggingLevels(info, LOG_LEVEL__DEBUG);
   }

   public static function disableInAppTracing():void {
      _inAppTracingFunction = null;
   }

   public static function displayDiagnosticsScreen():void {
      if (_displayDiagnosticsScreenFunction is Function) {
         _displayDiagnosticsScreenFunction();
      }
   }

   public static function enableInAppTracing(traceFunction:Function):void {
      _inAppTracingFunction = traceFunction;
   }

   public static function error(info:Object, allowLogToServer:Boolean = true):void {
      if (!Log._isInitialized)
         return;
      doLoggingStuffSharedByAllLoggingLevels(info, LOG_LEVEL__ERROR, allowLogToServer);
      if (_errorLogUserFeedbackFunction is Function)
         _errorLogUserFeedbackFunction();
   }

   public static function fatal(info:Object, allowLogToServer:Boolean = true):void {
      if (!Log._isInitialized)
         return;
      Log.hasFatalErrorBeenLogged = true;
      doLoggingStuffSharedByAllLoggingLevels(info, LOG_LEVEL__FATAL, allowLogToServer);
      copyRecentInfoToClipboard();
      _fatalLogUserFeedbackFunction();
   }

   public static function frameLength(length:Number):void {
      if (!Log._isInitialized)
         return;
      /////addMessageToDetailedInfoList("frame ms:" + length + "\n");
   }

   public static function getLengthLimitedInfoString(maxStringLength:Number):String {
      var result:String = createLogInfoSummaryString();
      var currentLength:Number = 0;
      var delimiter:String = "\n";
      var tempResult:String;
      var maxLengthExceeded:Boolean = false;
      var truncatedDataLength:uint = 0;
      var truncationInfoString:String = " ...\nData has been truncated. Truncated characters: ~";
      var truncationInfoStringLength:uint = truncationInfoString.length + 12; // We allow extra spaces for truncated char count
      var totalDataLength:uint = 0;
      var currIndex:uint = Log._detailedInfoList.length;
      while (true) {
         if (currIndex == 0)
            break;
         currIndex--;
         tempResult = Log._detailedInfoList[currIndex];
         if (maxLengthExceeded) {
            truncatedDataLength += tempResult.length;
         } else if ((currentLength + delimiter.length + tempResult.length + truncationInfoStringLength) > maxStringLength) {
            maxLengthExceeded = true;
            if ((currentLength + delimiter.length + truncationInfoStringLength) < maxStringLength) {
               var unusedAllowedCharCount:uint =
                     maxStringLength - (currentLength + delimiter.length + truncationInfoStringLength);
               var partialString:String = tempResult.substring(0, unusedAllowedCharCount - 1);
               result += partialString;
            }
         } else {
            if (result.length > 0) {
               result += delimiter;
               currentLength += delimiter.length;
            }
            result += tempResult;
            currentLength += tempResult.length;
         }
      }
      if (maxLengthExceeded)
         result += (truncationInfoString + truncatedDataLength);
      return result;
   }

   public static function getLogInfoForClipboard():String {
      var result:String = "";
      switch (Utils_System.platformName) {
         case Constant_PlatformName.ANDROID:
            result = getLengthLimitedInfoString(_COPY_TO_CLIPBOARD_STRING__MAX_LENGTH__ANDROID);
            break;
         case Constant_PlatformName.IOS:
            result = getLengthLimitedInfoString(_COPY_TO_CLIPBOARD_STRING__MAX_LENGTH__IOS);
            break;
         case Constant_PlatformName.MAC:
         case Constant_PlatformName.WINDOWS_DESKTOP:
            result = getLengthLimitedInfoString(_COPY_TO_CLIPBOARD_STRING__MAX_LENGTH__WINDOWS_DESKTOP);
            break;
         default:
            Log.error("Log.getLogInfoForClipboard(): No case for: " + Utils_System.platformName);

      }
      return result;
   }

   public static function getLogInfoForInAppViewing():String {
      var result:String = "";
      var currIndex:uint = Log._detailedInfoList.length;
      while (true) {
         if (currIndex == 0)
            break;
         currIndex--;
         if (result.length > 0) {
            result += "\n";
         }
         result += Log._detailedInfoList[currIndex];
      }
      return result;
   }

   public static function info(info:Object, allowLogToServer:Boolean = true):void {
      if (!Log._isInitialized)
         return;
      doLoggingStuffSharedByAllLoggingLevels(info, LOG_LEVEL__INFO, allowLogToServer);
   }

   public static function init(
         appName:String,
         fatalLogUserFeedbackFunction:Function,
         errorLogUserFeedbackFunction:Function = null,
         displayDiagnosticsScreenFunction:Function = null,
         summaryStringAppenderCallback:Function = null,
         isThrowErrorIfRunningOnDesktopMode:Boolean = false):void {
      if (Log._isInitialized) {
         Log.error("Log.init(): Log is already initialized");
         return;
      }
      Log._appName = appName;
      Log._detailedInfoList = [];
      Log._displayDiagnosticsScreenFunction = displayDiagnosticsScreenFunction;
      Log._errorLogUserFeedbackFunction = errorLogUserFeedbackFunction;
      Log._fatalLogUserFeedbackFunction = fatalLogUserFeedbackFunction;
      Log._isDebugMode = Utils_System.isInDebugMode();
      Log._httpService = new HTTPService();
      Log._httpService.useProxy = false;
      Log._isInitialized = true;
      Log._isThrowErrorIfRunningOnDesktopMode = isThrowErrorIfRunningOnDesktopMode;
      Log._summaryStringAppenderCallback = summaryStringAppenderCallback;
      index_LogLevel_to_LogLevelString = new Dictionary();
      index_LogLevel_to_LogLevelString[LOG_LEVEL__ALWAYS] = LOG_LEVEL_STRING__ALWAYS;
      index_LogLevel_to_LogLevelString[LOG_LEVEL__DEBUG] = LOG_LEVEL_STRING__DEBUG;
      index_LogLevel_to_LogLevelString[LOG_LEVEL__ERROR] = LOG_LEVEL_STRING__ERROR;
      index_LogLevel_to_LogLevelString[LOG_LEVEL__FATAL] = LOG_LEVEL_STRING__FATAL;
      index_LogLevel_to_LogLevelString[LOG_LEVEL__INFO] = LOG_LEVEL_STRING__INFO;
      index_LogLevel_to_LogLevelString[LOG_LEVEL__NEVER] = LOG_LEVEL_STRING__NEVER;
      index_LogLevel_to_LogLevelString[LOG_LEVEL__WARN] = LOG_LEVEL_STRING__WARN;
   }

   public function initSingleton():void {
      _performanceAnalyzer = PerformanceAnalyzer.getInstance();
   }

   public static function get isDebugMode():Boolean {
      return Log._isDebugMode;
   }

   public static function isLoggingEnabled(logLevel:int):Boolean {
      if (!Log._configProvider)
         return (logLevel > LOG_LEVEL__DEBUG);
      if (_configProvider.isLoggingEnabled(logLevel)) {
         return true;
      } else if (logLevel >= inAppLogLevelOverrideLevel) {
         return true;
      }
      return false;
   }

   public static function setConfigProvider(cp:ILoggingConfigProvider):void {
      Log._configProvider = cp;
   }

   public static function userInitiatedLogToServer(info:Object, logToServerCallbackFunction:Function = null):void {
      if (!Log._isInitialized)
         return;
      var infoArray:Array = ArrayUtil.toArray(info);
      infoArray.unshift(createVisualMarkerString() + "User Initiated Message:");
      var messageInfo:String = convertInfoDataToHumanReadableString(infoArray);
      Log.addMessageToDetailedInfoList(messageInfo);
      logToServerIfEnabledForLogLevel(LOG_LEVEL__ALWAYS, logToServerCallbackFunction);
   }

   public static function warn(info:Object, allowLogToServer:Boolean = true):void {
      if (!Log._isInitialized)
         return;
      doLoggingStuffSharedByAllLoggingLevels(info, LOG_LEVEL__WARN, allowLogToServer);
   }

   // ****************************************************
   //
   //          Private Methods
   //
   // ****************************************************

   private static function addMessageToDetailedInfoList(message:String):void {
      Log._detailedInfoList.push(message);
      if (Log._detailedInfoList.length > _detailedInfoListCapacity) {
         Log._detailedInfoList = Log._detailedInfoList.slice(Math.round(_detailedInfoListCapacity * .2));
      }
   }

   private static function convertInfoDataToHumanReadableString(info:Object):String {
      var result:String = ""
      result += getElapsedTimeAndMemoryString() + "\n";
      var infoArray:Array = ArrayUtil.toArray(info);
      for each (var infoItem:Object in infoArray) {
         if (infoItem is String) {
            result += String(infoItem) + "\n";
         } else if (infoItem is XML) {
            result += XML(infoItem).toXMLString() + "\n";
         } else if (infoItem is UncaughtErrorEvent) {
            result += "Uncaught Error: ";
            var error:* = UncaughtErrorEvent(infoItem).error;
            if (error is Error)
               result += Error(error).message + "\n";
            else
               result += error + "\n";
         } else {
            try {

               /*if (infoItem.hasOwnProperty("publishedLessonVersionId") && (infoItem.publishedLessonVersionId == "info.xiaina.eng.cmn.newbie_017_go_to_restaurant_2")) {
                  var a:int = 0;
               }*/

               var stateInfo:String = Utils_Object.getInstanceStateInfo(infoItem) + "\n";
            } catch (error:Error) {
               stateInfo = "######### Log.convertInfoDataToHumanReadableString(): Utils_Object.getInstanceStateInfo() throws error for: " + infoItem.toString();
            }
            result += stateInfo;
         }
      }
      return result;
   }

   private static function createLogLevelString(logLevel:int):String {
      var result:String = "";
      if (logLevel >= LOG_LEVEL__WARN)
         result += createVisualMarkerString();
      result += index_LogLevel_to_LogLevelString[logLevel] + ":";
      return result;
   }

   private static function createVisualMarkerString():String {
      return "\n\n     ###    \n\n\n";
   }

   private static function doLoggingStuffSharedByAllLoggingLevels(info:Object, logLevel:int, allowLogToServer:Boolean = true):void {
      var doDebugModeTracing:Boolean = ((Log.isDebugMode) && (logLevel >= Log._CURRENT_TRACE_LEVEL));
      var doDebugModeBreakpoint:Boolean = ((Log.isDebugMode) && (logLevel >= Log._CURRENT_BREAKPOINT_LEVEL));
      var messageInfo:String;
      if (isLoggingEnabled(logLevel) ||
            isInAppTracingEnabled(logLevel) ||
            doDebugModeTracing) {
         var infoArray:Array = ArrayUtil.toArray(info);
         if (logLevel >= LOG_LEVEL__WARN) {
            playAudioToneIfInStagingMode(logLevel);
         }
         infoArray.unshift(createLogLevelString(logLevel));
         try {
            messageInfo = convertInfoDataToHumanReadableString(infoArray);
         } catch (error:Error) {
            messageInfo = "######### Log.doLoggingStuffSharedByAllLoggingLevels(): convertInfoDataToHumanReadableString() throws error";
         }
         Log.addMessageToDetailedInfoList(messageInfo);
      }
      if ((isLoggingEnabled(logLevel)) && allowLogToServer) {
         logToServerIfEnabledForLogLevel(logLevel);
      }
      if (isInAppTracingEnabled(logLevel)) {
         _inAppTracingFunction(messageInfo);
      }
      if (doDebugModeTracing) {
         trace(messageInfo);
      }
      if (doDebugModeBreakpoint) {
         debugModeBreakpointHolderMethod();
      }
   }

   private static function getElapsedMSString():String {
      var result:String = String(Utils_DateTime.getCurrentMS_AppActive());
      return result;
   }

   private static function getElapsedTensOfSecondsString():String {
      var elapsedTensOfSeconds:int = Math.floor(Utils_DateTime.getCurrentMS_AppActive() / 10000);
      var result:String = Utils_String.padBeginning(String(elapsedTensOfSeconds), 4, "0");
      return result;
   }

   private static function getElapsedTimeAndMemoryString():String {
      var result:String = "";
      var elapsedSeconds:Number = Utils_DateTime.getCurrentMS_AppActive() / 1000;
      var elapsedSecondsString:String = Utils_DataConversionComparison.convertNumberToString(elapsedSeconds, 1);
      var airOrPlayerInUseBytes:Number = System.totalMemoryNumber; // Docs: "memory ... in use ... directly allocated by Flash Player or AIR
      var airOrPlayerUnusedBytes:int = System.freeMemory; // Docs: "allocated ... not in use ... fluctuates as garbage collection takes place.
      var airOrPlayerTotalBytes:Number = airOrPlayerInUseBytes + Number(airOrPlayerUnusedBytes);
      var totalAppBytes:int = Math.round(System.privateMemory); // Total memory used by application
      var airOrPlayerInUseMB:Number = airOrPlayerInUseBytes / (1024 * 1024);
      var airOrPlayerTotalMB:Number = airOrPlayerTotalBytes / (1024 * 1024);
      var totalAppMB:int = totalAppBytes / (1024 * 1024);
      var airOrPlayerInUseMBString:String = Utils_DataConversionComparison.convertNumberToString(airOrPlayerInUseMB, 2);
      var airOrPlayerTotalMBString:String = Utils_DataConversionComparison.convertNumberToString(airOrPlayerTotalMB, 1);
      var totalAppMBString:String = Utils_DataConversionComparison.convertNumberToString(totalAppMB);
      result += "secs:" + elapsedSecondsString + "  ";
      result += "mb:" + airOrPlayerInUseMBString + "/";
      result += airOrPlayerTotalMBString + "/";
      result += totalAppMBString;
      return result;
   }

   private static function isInAppTracingEnabled(logLevel:int):Boolean {
      return (_inAppTracingFunction is Function);
   }

   private static function logToServerIfEnabledForLogLevel(logLevel:uint, logToServerCallbackFunction:Function = null):void {
      if (Log._configProvider) {
         if (!Log._configProvider.isLogToServerEnabled(logLevel))
            return;
      }
      else {
         // This happens at startup, until config files are downloaded, etc.
         if (logLevel < LOG_LEVEL__ERROR)
            return;
      }
      var maxStringLength:Number;
      var serverURL:String;
      if (_configProvider) {
         maxStringLength = _configProvider.getLogToServerMaxStringLength(logLevel);
         serverURL = _configProvider.getLogToServerURL(logLevel);
      }
      else {
         maxStringLength = Constant_AppConfiguration.DEFAULT_CONFIG_INFO__LOG_TO_SERVER_MAX_STRING_LENGTH;
         serverURL = Constant_Private.DEFAULT_CONFIG_INFO__LOG_URL;
      }
      var logText:String = Log.getLengthLimitedInfoString(maxStringLength);
      var o:Object = new Object();
      o["subject"] = "LangMentor Log Message";
      o["message"] = logText;
      var jsonText:String = JSON.stringify(o);
      Utils_AWS.sendLogMessage(serverURL, jsonText, logToServerCallbackFunction);
   }

   private static function playAudioToneIfInStagingMode(logLevel:uint):void {
      if (!Utils_System.isAlphaOrBetaVersion())
         return;
      switch (logLevel) {
         case LOG_LEVEL__WARN: {
            Utils_Audio_Files.playLogToneWarn();
            break;
         }
         case LOG_LEVEL__ERROR: {
            Utils_Audio_Files.playLogToneError();
            break;
         }
         case LOG_LEVEL__FATAL: {
            Utils_Audio_Files.playLogToneFatal();
            break;
         }
      }
   }
}
}

class SingletonEnforcer {
}


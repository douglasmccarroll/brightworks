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
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;

import mx.core.FlexGlobals;

public class Utils_File {
   public static const BYTES_IN_GIGABYTE:int = 1024 * 1024 * 1024;
   public static const BYTES_IN_MEGABYTE:int = 1024 * 1024;

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   //
   //          Getters / Setters
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   public static function get applicationDirectoryURL():String {
      return File.applicationDirectory.nativePath;
   }

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   //
   //          Public Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   public static function createEmptyFile(file:File, overwrite:Boolean):Boolean {
      if (file.exists && !overwrite) {
         return false;
      } else if (file.exists && overwrite) {
         file.deleteFile();
         if (file.exists)
            return false;
      }
      // File either doesn't exist, or has been successfully deleted
      var fileStream:FileStream = new FileStream();
      fileStream.open(file, FileMode.WRITE);
      fileStream.close();
      return file.exists;
   }

   public static function deleteDirectory(directoryPath:String):Boolean {
      var dir:File = new File(directoryPath);
      if (dir.exists) {
         try {
            dir.deleteDirectory(true);
         } catch (error:Error) {
            Log.info(["Utils_File.deleteDirectory(): Cannot delete folder", error]);
            return false;
         }
         return true;
      } else {
         return true;
      }
   }

   public static function doesFolderContainSubfolders(folder:File):Boolean {
      if (!folder.isDirectory) {
         Log.error("Utils_File.doesFolderContainSubfolders(): Passed File instance is not a directory");
         return false;
      }
      return (getCountOfFoldersInFolder(folder) > 0);
   }

   public static function ensureDirectoryExists(directoryPath:String):Boolean {
      var dir:File = new File(directoryPath);
      if (dir.exists) {
         return true;
      } else {
         try {
            dir.createDirectory();
         } catch (e:Error) {
            trace (e.message);
            return false;
         }
         return dir.exists;
      }
   }

   public static function getAppBaseFileName():String {
      var url:String = FlexGlobals.topLevelApplication.url;
      var s:String = getBaseFileNameFromURL(url);
      return s;
   }

   public static function getAvailableFileSystemSpace(directoryPath:String):Number {
      var dir:File = new File(directoryPath);
      var bytes:Number = dir.spaceAvailable;
      return bytes;
   }

   public static function getBaseFileNameFromURL(url:String):String {
      // I'm defining "base file name" as the file name, minus:
      //        - the file name extension, e.g. ".swf"
      //        - the string "-debug", if any
      //
      // Thus file:///C:/_Projects/bw_011_configurator_demo/build/Main-debug.swf
      // will get converted to "Main"
      //
      // Note that the URL http://www.abc.net/.xyz would return "", as .xyz would
      // be considered to be the file extension.
      var fileName:String = getFileNameFromURL(url);
      var s:String = removeFileExtensionFromFileName(fileName);
      if (s == null)
         return null;
      s = removeDebugSuffixFromBaseFileName(s);
      return s;
   }

   public static function getCountOfFilesInFolder(folder:File, includeFilesInSubfolders:Boolean, countHiddenFiles:Boolean = false):uint {
      if (!folder.isDirectory) {
         Log.error("Utils_File.getCountOfFilesInFolder((): Passed File instance is not a directory");
         return 0;
      }
      var result:uint = 0;
      for each (var f:File in folder.getDirectoryListing()) {
         if ((f.isHidden) && (!countHiddenFiles))
            continue;
         if (f.isDirectory && includeFilesInSubfolders)
            result += getCountOfFilesInFolder(f, true)
         else
            result++
      }
      return result;
   }

   public static function getCountOfFoldersInFolder(folder:File):uint {
      if (!folder.isDirectory) {
         Log.error("Utils_File.getCountOfFoldersInFolder((): Passed File instance is not a directory");
         return 0;
      }
      var result:uint = 0;
      for each (var f:File in folder.getDirectoryListing()) {
         if (f.isDirectory)
            result++
      }
      return result;
   }

   public static function getFileListFromFolderByFileNameExtension(folder:File, extension:String):Array {
      var result:Array = [];
      if (!folder.isDirectory)
         return result;
      for each (var f:File in folder.getDirectoryListing()) {
         if ((!f.isDirectory) && (getFileNameExtensionFromFileName(f.name) == extension))
            result.push(f);
      }
      return result;
   }

   public static function getFileNameExtensionFromFileName(fileName:String):String {
      var lastDotsIndex:int = fileName.lastIndexOf(".");
      if (fileName.indexOf(".") == -1)
         return null;
      if ((lastDotsIndex == -1) || (lastDotsIndex == fileName.length - 1))
         return null;
      var s:String = fileName.slice(lastDotsIndex + 1, fileName.length - 1);
      return s;

   }

   public static function getFileNameFromURL(url:String):String {
      // Should only be used with URLs that actually have a file name
      // We test for this by checking for a 1-4 char file name extension, so
      // an extension is required as well.
      url = getPostDomainFilePathFromURL(url);
      if (url == null) {
         Log.warn("dlm0912021510");
         return null;
      }
      var a:Array = url.split("/");
      var s:String = a[a.length - 1];
      if (s.indexOf(".") == -1) {
         Log.warn("dlm0705311718");
         return null;
      }
      var extLength:int = (s.length - s.lastIndexOf(".")) - 1;
      if ((extLength < 1) || (extLength > 4)) {
         Log.warn("dlm0705311717 " + url);
         return null;
      }
      return s;
   }

   public static function getPostDomainFilePathFromURL(url:String):String {
      var lastIndex:int = url.lastIndexOf("//");
      if (lastIndex != -1) {
         if (lastIndex + 1 == url.length) {
            Log.warn("dlm0705311743 " + url);
            return null;
         }
         url = url.slice(lastIndex + 2);
      }
      var firstIndex:int = url.indexOf("/");
      // Confirm that there's a / char in url, and chars after it
      if (firstIndex == -1)
         return null;
      if (firstIndex + 1 == url.length)
         return null;
      if (url.indexOf(".") == -1)
         return null;
      if (url.indexOf(".") > firstIndex)
         return null;
      url = url.slice(firstIndex + 1);
      return url;
   }

   public static function getSingleFileInFolder(folder:File, countHiddenFiles:Boolean = false):File {
      if (getCountOfFilesInFolder(folder, false, countHiddenFiles) != 1) {
         Log.error("Utils_String.getSingleFileInFolder(): Folder does not contain exactly one file")
      }
      var result:File;
      for each (var f:File in folder.getDirectoryListing()) {
         if (f.isDirectory)
            continue;
         if ((!countHiddenFiles) && (f.isHidden))
            continue;
         result = f;
         break;
      }
      return result;
   }

   public static function getSubfolderFromFolderByName(folder:File, name:String):File {
      var result:File;
      if (!folder.isDirectory)
         return null;
      for each (var f:File in folder.getDirectoryListing()) {
         if ((f.isDirectory) && (f.name == name))
            return f;
      }
      return null;
   }

   public static function readTextFile(f:File):String {
      var fs:FileStream = new FileStream();
      fs.open(f, FileMode.READ);
      var result:String = fs.readUTFBytes(fs.bytesAvailable);
      fs.close();
      return result;
   }

   public static function removeDebugSuffixFromBaseFileName(fileName:String):String {
      // If "-debug" isn't present, we return fileName as-is
      var suffixIndex:int = fileName.indexOf("-debug");
      if (suffixIndex == 0) {
         return null;
      }
      if (suffixIndex == -1) {
         return fileName;
      }
      if (!(suffixIndex == (fileName.length - 6))) {
         return null;
      }
      var s:String = fileName.substr(0, suffixIndex);
      if (s.indexOf("/") != -1)
         s = null;
      return s;
   }

   public static function removeFileExtensionFromFileName(fileName:String):String {
      // Requires at least one "."
      var lastDotsIndex:int = fileName.lastIndexOf(".");
      if (fileName.indexOf(".") == -1) {
         return null;
      }
      var s:String = fileName.slice(0, lastDotsIndex);
      return s;
   }

   public static function writeTextFile(f:File, s:String):void {
      var fs:FileStream = new FileStream();
      fs.open(f, FileMode.WRITE);
      fs.writeUTFBytes(s);
      fs.close();
   }
}
}


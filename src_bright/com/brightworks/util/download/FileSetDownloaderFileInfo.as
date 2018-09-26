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
package com.brightworks.util.download {
import com.brightworks.interfaces.IDisposable;

import flash.utils.ByteArray;

public class FileSetDownloaderFileInfo implements IDisposable {
   public var fileData:ByteArray;
   public var fileFolderURL:String;
   public var fileNameBody:String;
   public var fileNameExtension:String;

   private var _isDisposed:Boolean = false;

   public function FileSetDownloaderFileInfo() {
   }

   public function dispose():void {
      if (_isDisposed)
         return;
      _isDisposed = true;
      if (fileData) {
         fileData.clear();
         fileData = null;
      }
   }
}
}

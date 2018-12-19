/*
 *  Copyright 2018 Brightworks, Inc.
 *
 *  This file is part of Language Mentor.
 *
 *  Language Mentor is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  Language Mentor is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with Language Mentor.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

package com.brightworks.util.persistence {

import com.brightworks.util.Log;
import com.langcollab.languagementor.constant.Constant_LangMentor_Misc;

import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.net.registerClassAlias;
import flash.utils.ByteArray;
import flash.utils.Dictionary;

public class ByteArrayPersistenceManager {

   private var _initialized:Boolean;
   private var _persistenceDict:Dictionary;

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   //
   //     Public Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   public function ByteArrayPersistenceManager() {
      initializeIfNeeded();
   }

   public function setProperty(key:String, value:Object):void {
      initializeIfNeeded();
      if (_persistenceDict != null)
         _persistenceDict[key] = value;
   }

   public function getProperty(key:String):Object {
      initializeIfNeeded();
      if (_persistenceDict != null) {
         if (_persistenceDict.hasOwnProperty(key)) {
            return _persistenceDict[key];
         }
         else {
            return null;
         }
      }
      else {
         return null;
      }
   }

   public function save():Boolean {
      if (_initialized) {
         try {
            var fs:FileStream = new FileStream();
            var file:File = File.applicationStorageDirectory.resolvePath(getFilePath());
            fs.open(file, FileMode.WRITE);
            var byteArray:ByteArray = new ByteArray();
            byteArray.writeObject(_persistenceDict);
            fs.writeBytes(byteArray);
            fs.close()
         }
         catch (e:Error) {
            Log.error("ByteArrayPersistenceManager.save() - save failed: " + e.message);
            return false;
         }
         return true;
      }
      else {
         Log.error("ByteArrayPersistenceManager.save() - instance not initialized");
         return false;
      }
   }

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   //
   //     Private Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   private function initializeIfNeeded():void {
      if (!_initialized)
         load();
   }

   private function getFilePath():String {
      var result:String = Constant_LangMentor_Misc.FILEPATHINFO__PERSISTENCE_FOLDER_NAME + File.separator + Constant_LangMentor_Misc.FILEPATHINFO__PERSISTENCE_FILE_FILE_NAME;
      return result;
   }

   private function load():Boolean {
      try {
         var file:File = File.applicationStorageDirectory.resolvePath(getFilePath());
         if (file.exists) {
            var fs:FileStream = new FileStream();
            fs.open(file, FileMode.READ);
            var byteArray:ByteArray = new ByteArray();
            fs.readBytes(byteArray);
            fs.close();
            _persistenceDict = Dictionary(byteArray.readObject());
         }
         else {
            _persistenceDict = new PersistenceDict();
         }
         _initialized = true;
      }
      catch (e:Error) {
         Log.error("ByteArrayPersistenceManager.load() - load failed: " + e.message);
      }
      return _initialized;
   }


}
}

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
import com.brightworks.error.BwError;

import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.utils.Dictionary;

public class Utils_XML {
   public function Utils_XML() {
   }

   public static function doesNodeEvaluateToBoolean(node:XML):Boolean {
      if (!node)
         return false;
      return Utils_DataConversionComparison.isABooleanString(node.toString());
   }

   // "Fractional" = ((>=0) && (<=1))
   public static function doesNodeEvaluateToFractionalNumber(node:XML):Boolean {
      if (!node)
         return false;
      if (!Utils_XML.doesNodeEvaluateToNumber(node))
         return false;
      var num:Number = Utils_XML.readNumberNode(node);
      if ((num < 0) || (num > 1))
         return false
      return true;
   }

   public static function doesNodeEvaluateToInt(node:XML):Boolean {
      return Utils_DataConversionComparison.isAnIntegerString(node.toString());
   }

   public static function doesNodeEvaluateToNumber(node:XML):Boolean {
      if (!node)
         return false;
      return Utils_DataConversionComparison.isANumberString(node.toString());
   }

   public static function doesNodeEvaluateToURL(node:XML):Boolean {
      if (!node)
         return false;
      return Utils_URL.isUrlProperlyFormed(node.toString());
   }

   public static function getCharacterToCharacterEntityReferenceIndex():Dictionary {
      var result:Dictionary = new Dictionary();
      result['"'] = "&quot;";
      result["&"] = "&amp;";
      result["'"] = "&apos;";
      result["<"] = "&lt;";
      result[">"] = "&gt;";
      return result;
   }

   public static function isNodeNonNullAndSingleSubnodeExistsInNode(node:XML, subnodeName:String):Boolean {
      if (!node)
         return false;
      if (XMLList(node[subnodeName]).length() != 1)
         return false;
      return true;
   }

   public static function readBooleanNode(node:XML):Boolean {
      if ((!node) || (!Utils_XML.doesNodeEvaluateToBoolean(node)))
         return false
      if (node.toString().toLowerCase() == "true")
         return true;
      return false;
   }

   public static function readIntegerNode(node:XML):int {
      if ((!node) || (!Utils_XML.doesNodeEvaluateToInt(node)))
         throw new BwError("Utils_XML.readIntegerNode(): Node doesn't evaluate to int", node);
      var result:int = int(node.toString());
      return result;
   }

   public static function readNumberNode(node:XML):Number {
      if ((!node) || (!Utils_XML.doesNodeEvaluateToNumber(node)))
         throw new BwError("Utils_XML.readNumberNode(): Node doesn't evaluate to Number", node);
      var result:Number = Number(node.toString());
      return result;
   }

   public static function replaceCharacterEntityReferencesWithCharacters(s:String):String {
      var index:Dictionary = getCharacterToCharacterEntityReferenceIndex();
      for (var char:String in index) {
         var ref:String = index[char];
         s = Utils_String.replaceAll(s, ref, char);
      }
      return s;
   }

   public static function synchronousLoadXML(f:File, logErrorOnParseFailure:Boolean):XML {
      var result:XML;
      var fs:FileStream = new FileStream();
      fs.open(f, FileMode.READ);
      try {
         var utfBytes:String = fs.readUTFBytes(fs.bytesAvailable);
         result = new XML(utfBytes);
      } catch (error:Error) {
         if (logErrorOnParseFailure)
            Log.error("Utils_XML.synchronousLoadXML(): Problem reading " + f.nativePath + " - " + error.message);
      }
      return result;
   }

}
}

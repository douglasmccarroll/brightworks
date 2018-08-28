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
import flash.utils.ByteArray;

import mx.collections.ArrayCollection;

public class Utils_ByteArray {
   public static function copyItems(copyFromAC:ArrayCollection, copyToAC:ArrayCollection):void {
      copyToAC.addAll(copyFromAC);
   }

   public static function getAverageAbsoluteValueFromByteArrayOfFloats(ba:ByteArray):Number {
      var runningTotal:Number = 0;
      var currPosition:uint = 0;
      ba.position = 0;
      while (true) {
         if (ba.bytesAvailable > 0) {
            currPosition++;
            runningTotal += Math.abs(ba.readFloat());
         }
         else {
            break;
         }
      }
      var result:Number = runningTotal / currPosition;
      return result;
   }

   public static function getFractionOfAbsoluteValuesInByteArrayOfFloatsThatAreAtOrAboveNumber(ba:ByteArray, floorNumber:Number):Number {
      var countOfValuesAtOrAboveFloorNumber:Number = 0;
      var currPosition:uint = 0;
      ba.position = 0;
      while (true) {
         if (ba.bytesAvailable > 0) {
            currPosition++;
            if (Math.abs(ba.readFloat()) >= floorNumber)
               countOfValuesAtOrAboveFloorNumber++;
         }
         else {
            break;
         }
      }
      var result:Number = countOfValuesAtOrAboveFloorNumber / currPosition;
      return result;
   }

   public static function getHighestAbsoluteValueFromByteArrayOfFloats(ba:ByteArray):Number {
      var result:Number = 0;
      ba.position = 0;
      while (true) {
         if (ba.bytesAvailable > 0) {
            var value:Number = ba.readFloat();
            //trace(value)
            result = Math.max(result, Math.abs(value));
         }
         else {
            break;
         }
      }
      return result;
   }
}
}




























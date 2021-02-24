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
public class Utils_Math {
   public static function computePercentageInteger_RoundDown(numerator:Number, denominator:Number):int {
      if (numerator < 0) {
         Log.warn(["Utils_Math.computePercentageInteger_RoundDown(): numerator arg is a negative number - not supported by this method", "numerator:", numerator]);
         return -1;
      }
      if (denominator < 0) {
         Log.warn(["Utils_Math.computePercentageInteger_RoundDown(): denominator arg is a negative number - not supported by this method", "denominator:", denominator]);
         return -1;
      }
      if (denominator == 0) {
         Log.warn(["Utils_Math.computePercentageInteger_RoundDown(): denominator arg is zero", "denominator:", denominator]);
         return -1;
      }
      var temp:Number = (numerator / denominator) * 100;
      var result:int = Math.floor(temp);
      return result;
   }

   public static function isNMultipleOfN(multiple:int, multipleOf:int):Boolean {
      return ((multiple % multipleOf) == 0);
   }

   public static function roundToNthPower(n:Number, power:int):int {
      var remainder:Number = n % power;
      var roundedDown:int = Math.round(n - remainder);
      var result:int = (remainder > (power / 2)) ? roundedDown + power : roundedDown;
      return result;
   }

   public static function roundToPrecision(n:Number, precision:int):Number {
      var s:String = Utils_DataConversionComparison.convertNumberToString(n, precision);
      var result:Number = Number(s);
      return result;
   }
}
}

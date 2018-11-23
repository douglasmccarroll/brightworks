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
import mx.collections.ArrayCollection;
import mx.collections.Sort;
import mx.collections.SortField;
import mx.formatters.NumberBase;
import mx.formatters.NumberBaseRoundType;

public class Utils_DataConversionComparison {
   public static function convertArrayToDelimitedString(a:Array, delimiter:String = ","):String {
      return a.join(delimiter);
   }

   public static function convertArrayToDelimitedStringInReverseOrder(a:Array, delimiter:String = ",", maxStringLength:Number = Number.MAX_VALUE):String {
      var result:String = "";
      var currentLength:Number = 0;
      var tempResult:String;
      for (var i:int = (a.length - 1); i >= 0; i--) {
         tempResult = a[i];
         if ((currentLength + delimiter.length + tempResult.length) > maxStringLength) {
            if ((currentLength + delimiter.length) < maxStringLength) {
               var unusedAllowedCharCount:uint = maxStringLength - (currentLength + delimiter.length);
               var partialString:String = tempResult.substring(0, unusedAllowedCharCount - 1);
               result += partialString;
            }
            break;
         }
         if (result.length > 0) {
            result += delimiter;
            currentLength += delimiter.length;
         }
         result += tempResult;
         currentLength += tempResult.length;
      }
      return result;
   }

   /**
    *     For now this method returns a string in this format: "YYYY,MM,DD,HH,MM,SS"
    *     At some later point we may want to add a stringFormat parameter
    */
   public static function convertDateToString(d:Date):String {
      var year:String = String(d.fullYear);
      var month:String = Utils_String.padBeginning(String(d.month), 2, "0");
      var day:String = Utils_String.padBeginning(String(d.date), 2, "0");
      var hour:String = Utils_String.padBeginning(String(d.hours), 2, "0");
      var minute:String = Utils_String.padBeginning(String(d.minutes), 2, "0");
      var second:String = Utils_String.padBeginning(String(d.seconds), 2, "0");
      var result:String = year + "," + month + "," + day + "," + hour + "," + minute + "," + second;
      return result;
   }

   public static function convertNumberToString(n:Number, precision:int = -1, pad:Boolean = false, paddedLength:uint = 0, paddingChar:String = " ", padBeginning:Boolean = true):String {
      var s:String = String(n);
      if (precision < -1) {
         Log.warn("Utils_DataConversionComparison.convertNumberToString(): dlm0705291849");
         return null;
      } else if (precision == -1) {
         // Do nothing - leave as-is
      } else {
         var nb:NumberBase = new NumberBase();
         s = nb.formatRoundingWithPrecision(s, NumberBaseRoundType.NEAREST, precision);
         if (precision > 0) {
            // Unfortunately, 'precision' as used by formatRoundingWithPrecision would
            // be better named 'maxPrecision' - for example, if we are rounding 3.98 to a
            // precision of 1, it will return "4", not "4.0".
            s = Utils_String.ensureNumberStringsMinimumPrecision(s, precision);
         }
      }
      if (pad) {
         if (padBeginning) {
            s = Utils_String.padBeginning(s, paddedLength, paddingChar);
         } else {
            s = Utils_String.padEnd(s, paddedLength, paddingChar);
         }
      }
      return s;
   }

   public static function convertObjectPropertiesToDelimitedString(instance:Object, delimiter:String = ","):String {
      var result:String = "";
      for (var prop:String in instance) {
         if (result.length) {
            result = result + delimiter;
         }
         result = result + prop;
      }
      return result;
   }

   public static function convertObjectToArrayConsistingOfValuesSortedByPropertyNames(o:Object, caseInsensitive:Boolean, descending:Boolean, numeric:Boolean):Array {
      /*
      In other words, this:
      {
      b: "valueOfBProp",
      a: "valueOfAProp"
      }

      Would be converted to this: ["valueOfAProp", "valueOfBProp"]
      */
      var result:Array = [];
      var tempArrayCollection:ArrayCollection = new ArrayCollection();
      var sort:Sort = new Sort()
      var sortFieldList:Array = [new SortField("propName", caseInsensitive, descending, numeric)];
      sort.fields = sortFieldList;
      tempArrayCollection.sort = sort;
      tempArrayCollection.refresh();
      var propName:Object;
      var propValue:Object;
      for (propName in o) {
         propValue = o[propName];
         tempArrayCollection.addItem({propName: propName, propValue: propValue});
      }
      var infoObject:Object;
      for each (infoObject in tempArrayCollection) {
         result.push(infoObject.propValue);
      }
      return result;
   }

   public static function convertObjectValuesToDelimitedString(instance:Object, delimiter:String = ","):String {
      var result:String = "";
      for each (var val:String in instance) {
         if (result.length) {
            result = result + delimiter;
         }
         result = result + val;
      }
      return result;
   }

   public static function convertStringToArrayBasedOnDelimiter(s:String, delimiter:String, stripWhiteSpaceFromStringEnds:Boolean = true):Array {
      if (stripWhiteSpaceFromStringEnds)
         s = Utils_String.removeWhiteSpaceIncludingLineReturnsFromBeginningAndEndOfString(s)
      var result:Array = s.split(delimiter);
      return result;
   }

   public static function convertStringToArrayOfLineStrings(s:String, stripWhiteSpaceFromLineEnds:Boolean = false):Array {
      s = Utils_String.removeSubstringFromString("\r", s);
      var tempResult:Array = s.split("\n");
      var result:Array;
      if (stripWhiteSpaceFromLineEnds) {
         result = [];
         for each (var line:String in tempResult) {
            result.push(Utils_String.removeWhiteSpaceIncludingLineReturnsFromBeginningAndEndOfString(line));
         }
      } else {
         result = tempResult;
      }
      return result;
   }

   public static function convertToArrayIfNotAnArray(o:Object):Array {
      if (o is Array)
         return (o as Array);
      return [o];
   }

   public static function convertYYYYMMDDStringToUTCDate(s:String):Date {
      if (!Utils_DataConversionComparison.isAYYYYMMDDDateFormatString(s))
         return null;
      var d:Date = new Date();
      d.fullYearUTC = int(s.substr(0, 4));
      d.monthUTC = int(s.substr(4, 2)) - 1;
      d.dateUTC = int(s.substr(6, 2));
      return d;
   }

   public static function createRandomBooleanBasedOnProbabilityFraction(fraction:Number):Boolean {
      if ((fraction < 0) || (fraction > 1)) {
         Log.error("Utils_DataConversionComparison.createRandomBooleanBasedOnProbabilityFraction(): Fraction must be between 0 and 1. Passed value is: " + fraction);
         return false;
      }
      if (fraction == 1)
         return true;
      if (fraction == 0)
         return false;
      var randomFraction:Number = Math.random();
      var result:Boolean = (fraction >= randomFraction);
      return result;
   }

   public static function isABooleanString(s:String):Boolean {
      var result:Boolean = false;
      switch (s.toLowerCase()) {
         case "true":
         case "false": {
            result = true;
         }
      }
      return result;
   }

   public static function isANumberString(s:String):Boolean {
      var result:Boolean = true;
      var acceptableChars:String = "+-.1234567890";
      for (var i:int = 0; i < s.length; i++) {
         if (acceptableChars.indexOf(s.charAt(i)) == -1) {
            result = false;
            break;
         }
      }
      var nonRepeatableChars:Array = ["+", "-", "."];
      for each (var charToCheck:String in nonRepeatableChars) {
         if (Utils_String.getCountOfSubstringInString(s, charToCheck) > 1) {
            result = false;
            break;
         }
      }
      var zeroIndexChars:Array = ["+", "-"];
      for each (charToCheck in zeroIndexChars) {
         if (s.indexOf(charToCheck) > 0) {
            result = false;
            break;
         }
      }
      return result;
   }

   public static function isAnArrayContainingOnlyIntegerStrings(a:Array):Boolean {
      for each (var val:* in a) {
         if (!val is String)
            return false;
         if (!isAnIntegerString(val))
            return false;
      }
      return true;
   }

   public static function isAnIntegerString(s:String):Boolean {
      var pattern:RegExp = /\D/;
      return (s.search(pattern) == -1)
   }

   public static function isAYYYYMMDDDateFormatString(s:String):Boolean {
      if (s.length != 8)
         return false;
      if (!Utils_DataConversionComparison.isAnIntegerString(s))
         return false;
      if (int(s.substr(4, 2)) < 1)
         return false;
      if (int(s.substr(4, 2)) > 12)
         return false;
      if (int(s.substr(6, 2)) < 1)
         return false;
      if (int(s.substr(6, 2)) > 31)
         return false;
      return true;
   }
}
}








/*
Copyright 2020 Brightworks, Inc.

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

public class Utils_String {
   public static const UNICODE_CHARACTER_RANGE__COMMON_CHINESE_CHARACTERS:Array = [0x4e00, 0x9fff];
   public static const UNICODE_CHARACTER_SET__EAST_ASIAN_PUNCTUATION_CHARACTERS:Array = [0x3000, 0x3001, 0x3002, 0x3005, 0x3008, 0x3009, 0x300A, 0x300B, 0x300C, 0x300D, 0x3013, 0x30FB, 0xFF01, 0xFF08, 0xFF09, 0xFF0C, 0xFF0D, 0xFF0E, 0xFF0F, 0xFF1A, 0xFF1B, 0xFF1F, 0xFF3B, 0xFF3D];

   public static function addChar(s:String, char:String, addlChars:uint):String {
      if (char.length != 1)
         return null;
      for (var i:int = 0; i < addlChars; i++) {
         s = s + char;
      }
      return s;
   }

   public static function convertCharCodeToChar(charCode:int):String {
      if (charCode > 47 && charCode < 58) {
         var strNums:String = "0123456789";
         return strNums.charAt(charCode - 48);
      } else if (charCode > 64 && charCode < 91) {
         var strCaps:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
         return strCaps.charAt(charCode - 65);
      } else if (charCode > 96 && charCode < 123) {
         var strLow:String = "abcdefghijklmnopqrstuvwxyz";
         return strLow.charAt(charCode - 97);
      } else {
         return charCode.toString();
      }
   }

   public static function convertFromUnderscoresToCamelCase(s:String):String {
      var result:String = "";
      var currChar:String = null;
      var prevCharWasUnderscore:Boolean = false;
      for (var i:int = 0; i < s.length; i++) {
         currChar = s.charAt(i);
         if (currChar == "_") {
            prevCharWasUnderscore = true;
         } else {
            if (prevCharWasUnderscore) {
               currChar = currChar.toUpperCase();
            } else {
               currChar = currChar.toLowerCase();
            }
            result = result + currChar;
            prevCharWasUnderscore = false;
         }
      }
      return result;
   }

   public static function doesStringBeginWithWhiteSpace(s:String):Boolean {
      return (Utils_String.removeWhiteSpaceAtBeginningsOfLines(s) != s);
   }

   public static function doesStringContainSubstringSurroundedByLineBreaks_WhiteSpace_Or_Punctuation(s:String, subString:String):Boolean {
      for (var i:uint; i < s.length; i++) {
         if ((i + subString.length) > s.length)
            continue;
         if (s.substr(i, subString.length) == subString) {
            // We have a match, but is it surrounded correctly?
            var precedingCharIndex:int = i - 1;
            var followingCharIndex:uint = i + subString.length;
            if (((precedingCharIndex < 0) || (isCharAtIndexLineBreak_WhiteSpace_Or_Punctuation(s, precedingCharIndex))) &&
                  ((followingCharIndex >= s.length) || (isCharAtIndexLineBreak_WhiteSpace_Or_Punctuation(s, followingCharIndex))))
               return true;
         }
      }
      return false;
   }

   public static function doesStringEndWithString(s:String, stringOrStringsToMatch:Object):Boolean {
      var checkStrings:Array;
      if (!s) {
         Log.fatal("Utils_String.doesStringEndWithChar(): 'to check' value is null");
      }
      if (stringOrStringsToMatch is String) {
         checkStrings = [stringOrStringsToMatch];
      } else if (stringOrStringsToMatch is Array) {
         checkStrings = (stringOrStringsToMatch as Array);
      } else {
         Log.fatal("Utils_String.doesStringEndWithChar(): 'to match' value is neither string nor array");
      }
      var result:Boolean = false;
      for each (var checkString:String in checkStrings) {
         if (checkString.length > s.length) {
            continue;
         }
         if (s.substring(s.length - checkString.length, s.length) == checkString) {
            result = true;
            break;
         }
      }
      return result;
   }

   public static function ensureNumberStringsMinimumPrecision(s:String, precision:uint):String {
      if (getCountOfSubstringInString(s, ".") > 1)
         return null;
      if (precision == 0)
         return s;
      if (getCountOfSubstringInString(s, ".") == 0)
         s = s + ".";
      if (getCharCountAfterChar(s, ".") < precision) {
         var addlZeroes:int = precision - getCharCountAfterChar(s, ".");
         s = addChar(s, "0", addlZeroes);
      }
      return s;
   }

   // Currently, if we pass "abcdef" and "efghi", this method will conclude that "abcdef" doesn't end with 
   // "efghi" and will add it, resulting in "abcdefefghi". It's possible that this method could be 'improved'
   // so that it notices such overlaps and only adds the chars necessary to ensure that the new string ends
   // with the endString... but, do we really want this? Pro: Method name would be more accurate.  :)
   public static function ensureStringEndsWith(s:String, endString:String):String {
      var startIndex:int = (s.length - endString.length);
      if (s.substr(startIndex, endString.length) != endString)
         s += endString;
      return s;
   }

   public static function extractCharsFromString(charsToExtract:Array, s:String):String {
      var result:String = "";
      for (var i:int = 0; i < s.length; i++) {
         if (charsToExtract.indexOf(s.charAt(i)) != -1)
            result += s.charAt(i);
      }
      return result;
   }

   public static function getCharCountAfterChar(s:String, char:String):int {
      var result:int;
      // For simplicity, we require that there only be 0 or 1 instances of char in s
      var instancesOfChar:int = getCountOfSubstringInString(s, char);
      switch (instancesOfChar) {
         case 0: {
            result = -1;
            break;
         }
         case 1: {
            result = s.length - (s.indexOf(char) + 1);
            break;
         }
         default: {
            Log.fatal("Utils_String.getCharCountAfterChar(): dlm07052004");
         }
      }
      return result;
   }

   public static function getCharsAfterSubstring(s:String, sub:String):String {
      // Precisely one instance of sub is required
      var index:int = s.indexOf(sub);
      // Check for 0 instances
      if (index == -1) {
         return null;
      }
      var newFirstChar:int = index + sub.length;
      var result:String = s.slice(newFirstChar);
      // Check for >1 instances
      if ((result).indexOf(sub) != -1)
         result = null;
      return result;
   }

   public static function getCommonChineseCharacterCount(s:String, bIncludeChinesePunctuationCharacters:Boolean = false):int {
      var minCommonCharacterCharCode:int = UNICODE_CHARACTER_RANGE__COMMON_CHINESE_CHARACTERS[0];
      var maxCommonCharacterCharCode:int = UNICODE_CHARACTER_RANGE__COMMON_CHINESE_CHARACTERS[1];
      var charCount:int = s.length;
      var charCode:int;
      var result:int = 0;
      for (var i:int = 0; i < s.length; i++) {
         charCode = s.charCodeAt(i);
         if ((charCode >= minCommonCharacterCharCode) && (charCode <= maxCommonCharacterCharCode))
            result++;
         if (bIncludeChinesePunctuationCharacters) {
            if (UNICODE_CHARACTER_SET__EAST_ASIAN_PUNCTUATION_CHARACTERS.indexOf(charCode) != -1)
               result++;
         }
      }
      return result;
   }

   public static function getCountOfSubstringInString(string:String, subString:String):int {
      var splitString:Array = string.split(subString);
      var result:int = splitString.length - 1;
      return result;
   }

   public static function getCountOfCharsInString(chars:Array, s:String):int {
      var result:int = 0;
      for (var i:int = 0; i < s.length; i++) {
         if (chars.indexOf(s.charAt(i)) != -1)
            result++;
      }
      return result;
   }

   public static function getFirstCharInStringThatIsNotOtherSpecifiedChars(s:String, otherSpecifiedChars:Array):String {
      var result:String;
      for (var i:int; i < s.length; i++) {
         if (otherSpecifiedChars.indexOf(s.charAt(i)) == -1) {
            result = s.charAt(i);
            break;
         }
      }
      return result;
   }

   public static function getListOfIndexesOfAllMatchesForSubstring(s:String, substring:String, caseSensitive:Boolean):Array {
      if (!caseSensitive) {
         s = s.toLowerCase();
         substring = substring.toLowerCase();
      }
      var result:Array = [];
      var deletedCharCount:uint = 0;
      while (true) {
         var matchIndex:int = s.indexOf(substring);
         if (matchIndex == -1)
            break;
         result.push(matchIndex + deletedCharCount);
         s = s.substr(matchIndex + 1);
         deletedCharCount += matchIndex + 1;
      }
      return result;
   }

   public static function getNumericCharacterCount(s:String):int {
      var result:int = getCountOfCharsInString(["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"], s);
      return result;
   }

   public static function getWordCountForString(s:String):uint {
      if (!(s is String))
         Log.fatal("Utils_String.getWordCountForString(): passed value isn't a String");
      var result:uint;
      s = removeWhiteSpaceIncludingLineReturnsFromBeginningAndEndOfString(s);
      if (s.length > 0) {
         var wordList:Array = s.split(/\s+/g);
         result = wordList.length;
      } else {
         result = 0;
      }
      return result;
   }

   public static function isCharAtIndexLineBreak_WhiteSpace_Or_Punctuation(s:String, index:uint):Boolean {
      var char:String = s.charAt(index);
      var result:Boolean = (String("\t\n\r `~!@#$%^&*()_-=+;:'\",<.>/?，！？；：（ ）【】［］。「」﹁﹂、‧《》﹏…—～").indexOf(char) != -1);
      return result;
   }

   public static function isCharUpperCase(s:String):Boolean {
      if (s.length != 1)
         Log.fatal("Utils_String.isCharUpperCase(): passed string's length != 1");
      var regExp:RegExp = new RegExp("[A-Z]");
      var regExpResult:String = regExp.exec(s);
      var result:Boolean = (regExpResult is String);
      return result;
   }

   public static function isStringEndsWith(s:String, sEndsWith:String):Boolean {
      if (s.length < sEndsWith.length)
         return false;
      var sEnd:String = s.substring(s.length - sEndsWith.length, s.length);
      return (sEnd == sEndsWith);
   }

   public static function padBeginning(s:String, length:uint, padChar:String = " "):String {
      // Note that if s is longer than length, we return null
      if (s.length >= length)
         return s;
      if (padChar.length > 1) {
         Log.warn("Utils_String.padBeginning(): string to be padded is longer than desired length");
         return null;
      }
      var paddingNeeded:int = length - s.length;
      s = addChar("", padChar, paddingNeeded) + s;
      return s;
   }

   public static function padEnd(s:String, length:uint, padChar:String = " "):String {
      // Note that if s is longer than length, we simply return s
      if (s.length >= length)
         return s;
      if (padChar.length > 1) {
         Log.warn("Utils_String.padEnd():  string to be padded is longer than desired length");
         return null;
      }
      var paddingNeeded:int = length - s.length;
      s = addChar(s, padChar, paddingNeeded);
      return s;
   }

   public static function removeCharsFromEndOfString(s:String, howManyChars:int):String {
      if (s.length < howManyChars) {
         Log.warn("Utils_String.removeCharsFromEndOfString():  string to be modified is longer than the number of chars that we're deleting");
         return null;
      }
      var result:String = s.substring(0, s.length - howManyChars);
      return result;
   }

   public static function removeLineBreaks(s:String):String {
      var regExp:RegExp = /[\n\r]/gm;
      var result:String = s.replace(regExp, "");
      return result;
   }

   public static function removeSubstringFromEndOfString(sSubstring:String, s:String):String {
      if (!isStringEndsWith(s, sSubstring)) {
         Log.warn("Utils_String.removeSubstringFromEndOfString(): String '" + s + "' doesn't end with substring '" + sSubstring + "'");
         return null;
      }
      var result:String = s.substring(0, s.length - (sSubstring.length));
      return result;
   }

   public static function removeSubstringFromString(regExpPatternString:String, s:String):String {
      var myPattern:RegExp = new RegExp(regExpPatternString, "g");
      var result:String = (s.replace(myPattern, ""));
      return result;
   }

   public static function removeWhiteSpace(s:String):String {
      // This method deletes lines if they only consist of white space and \r and/or \n  - as the 's' in the regex matches both
      var regExp:RegExp = /\s+/gm;
      var result:String = s.replace(regExp, "");
      return result;
   }

   public static function removeWhiteSpaceAtBeginningsOfLines(s:String):String {
      var result:String = "";
      var lineList:Array = Utils_DataConversionComparison.convertStringToArrayOfLineStrings(s, false);
      for each (var line:String in lineList) {
         result += removeWhiteSpaceNotIncludingLineReturnsFromBeginningOfString(line) + "\n";
      }
      return result;
   }

   public static function removeWhiteSpaceNotIncludingLineReturnsFromBeginningOfString(s:String):String {
      if (s == "")
         return "";
      var currChar:String;
      while (true) {
         currChar = s.charAt(0);
         if ((currChar == " ") || (currChar == "\t")) {
            s = s.substring(1, s.length);
         } else {
            break;
         }
      }
      return s;
   }

   public static function removeWhiteSpaceIncludingLineReturnsFromBeginningAndEndOfString(s:String):String {
      s = removeWhiteSpaceIncludingLineReturnsFromBeginningOfString(s);
      s = removeWhiteSpaceIncludingLineReturnsFromEndOfString(s);
      return s;
   }

   public static function removeWhiteSpaceIncludingLineReturnsFromBeginningOfString(s:String):String {
      if (s == "")
         return "";
      var currChar:String;
      while (true) {
         currChar = s.charAt(0);
         // ToDo: Extract isCharWhiteSpace() from these two methods
         if (
               (currChar == " ") ||
               (currChar == "\f") ||     // form feed
               (currChar == "\n") ||     // new line
               (currChar == "\r") ||     // carriage return
               (currChar == "\t") ||     // tab
               (currChar == "\u00A0") || // non-breaking space
               (currChar == "\u2028") || // line separator
               (currChar == "\u2029") || // paragraph separator
               (currChar == "\u3000")    // ideographic separator
         ) {
            s = s.substring(1, s.length);
         } else {
            break;
         }
      }
      return s;
   }

   public static function removeWhiteSpaceIncludingLineReturnsFromEndOfString(s:String):String {
      if (s == "")
         return "";
      var charCount:int = s.length;
      for (var i:int = charCount - 1; i >= 0; i--) {
         // ToDo: Extract isCharWhiteSpace() from these two methods
         if (
               (s.charAt(i) == " ") ||
               (s.charAt(i) == "\f") ||     // form feed
               (s.charAt(i) == "\n") ||     // new line
               (s.charAt(i) == "\r") ||     // carriage return
               (s.charAt(i) == "\t") ||     // tab
               (s.charAt(i) == "\u00A0") || // non-breaking space
               (s.charAt(i) == "\u2028") || // line separator
               (s.charAt(i) == "\u2029") || // paragraph separator
               (s.charAt(i) == "\u3000")    // ideographic separator
         ) {
            s = s.substring(0, i);
         } else {
            break;
         }
      }
      return s;
   }

   public static function replaceAll(s:String, substringToReplace:String, replacementString:String):String {
      var regExp:RegExp = new RegExp(substringToReplace, "g");
      var result:String = s.replace(regExp, replacementString);
      return result;
   }

   public static function trimStringEnd(s:String, stringToTrim:String):String {
      if (!s) {
         Log.fatal("Utils_String.trimStringEnd(): string is null");
      }
      while (true) {
         if (Utils_String.doesStringEndWithString(s, stringToTrim)) {
            s = Utils_String.removeCharsFromEndOfString(s, stringToTrim.length);
         } else {
            break;
         }
      }
      return s;
   }
}
}












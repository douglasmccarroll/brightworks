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
import flash.system.Capabilities;
import flash.text.TextField;
import flash.text.TextFormat;

public class Utils_Text {

   public static function createSimpleTextField(fontSize:uint = 0, fontFamily:String = "", selectable:Boolean = false):TextField {
      if (fontSize == 0)
         fontSize = getStandardFontSize();
      if (fontFamily == "")
         fontFamily = "_sans";
      var textField:TextField = new TextField();
      var textFormat:TextFormat = new TextFormat();
      textFormat.font = fontFamily;
      textFormat.size = fontSize;
      textField.defaultTextFormat = textFormat;
      textField.selectable = selectable;
      return textField;
   }

   public static function getDefaultFont():String {
      return "segoeui";
   }

   public static function getStandardFontSize():int {
      if (Utils_System.isRunningOnDesktop())
         return 14;
      //
      // Note that while this is named "standard *font* size", we also use this metric for other things.
      // For examples, do a "Find Usages" search.
      //
      // Old method:
      // var dpi:Number = Capabilities.screenDPI;
      // var result:int = Math.round(dpi / 12);
      // In iPhone 4-6 (but not 6+) this was 326/12 = 27
      // Which worked out to the following numbers of square characters fitting onto the screen:
      //    iPhone 4: 843, iPhone 5: 997, iPhone 6: 1372
      // In iPhone 6+, due to a much higher screen resolution, this formula allowed 1904 square
      //    characters to fit onto the screen.
      //
      // Goal: Compute an integer that will allow ~1000 square characters to fit onto the screen
      var screenPixels:Number = Capabilities.screenResolutionX * Capabilities.screenResolutionY;
      var charPixels:Number = screenPixels / 1000;
      var squareRoot:Number = Math.sqrt(charPixels);
      var result:int = Math.round(squareRoot);
      return result;
   }


}
}

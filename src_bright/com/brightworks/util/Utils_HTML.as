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
import flash.text.StyleSheet;

public class Utils_HTML {

   public static function createHTML_Break():String {
      return "<b>&nbsp;</b>";
   }

   public static function createHTML_CreditsPart_Hyperlink(partXML:XML):String {
      var result:String = "";
      result += createHTML_CreditsPartTitle(partXML.title[0].toString());
      result += createHTML_Spacer();
      if (hasSingleTextElement(partXML)) {
         var linkText:String;
         var linkURL:String;
         if (partXML.text.length() > 0)
            linkText = partXML.text[0].toString();
         if (partXML.url.length() > 0)
            linkURL = partXML.url[0].toString();
         result += createHTML_CreditsPartHyperlinkParagraph(linkText, linkURL);
         result += createHTML_Spacer();
      }
      if (hasSingleNoteElement(partXML)) {
         result += createHTML_CreditsPart_Note(partXML);
         result += createHTML_Spacer();
      }
      result += createHTML_Spacer();
      return result;
   }

   public static function createHTML_CreditsPart_HyperlinkList(partXML:XML):String {
      var result:String = "";
      result += createHTML_CreditsPartTitle(partXML.title[0].toString());
      result += createHTML_Spacer();
      result += createHTML_UnorderedListStart();
      var listNode:XML = partXML.list[0];
      var partNodeList:XMLList = listNode.part;
      for each (var subPartXML:XML in partNodeList) {
         result += createHTML_CreditsPart_HyperlinkListItem(subPartXML);
      }
      result += createHTML_UnorderedListEnd();
      result += createHTML_Spacer();
      if (hasSingleNoteElement(partXML)) {
         result += createHTML_CreditsPart_Note(partXML);
         result += createHTML_Spacer();
      }
      return result;
   }

   public static function createHTML_CreditsPart_HyperlinkListItem(partXML:XML):String {
      var result:String = "";
      result += createHTML_ListItemStart();
      result += createHTML_CreditsPart_HyperlinkListItemTitle(partXML.title[0].toString());
      var linkText:String;
      var linkURL:String;
      if (partXML.text.length() > 0)
         linkText = partXML.text[0].toString();
      if (partXML.url.length() > 0)
         linkURL = partXML.url[0].toString();
      result += createHTML_CreditsPartHyperlink(linkText, linkURL);
      result += createHTML_ListItemEnd();
      return result;
   }

   public static function createHTML_CreditsPart_HyperlinkListItemTitle(title:String):String {
      return '<font size="' + getHTMLFontSize_Text() + '"><b>' + title + ':&nbsp;&nbsp;</b></font>';
   }

   public static function createHTML_CreditsPart_TextSection(partXML:XML):String {
      var result:String = "";
      result += createHTML_CreditsPartTitle(partXML.title[0].toString());
      result += createHTML_Spacer();
      var listNode:XML = partXML.list[0];
      var paragraphNodeList:XMLList = listNode.paragraph;
      for each (var paragraphXML:XML in paragraphNodeList) {
         result += createHTML_CreditsPart_TextSectionParagraph(paragraphXML);
         result += createHTML_Spacer();
      }
      result += createHTML_Spacer();
      return result;
   }

   public static function createHTML_CreditsPart_TextSectionParagraph(paragraphNode:XML):String {
      var nodeText:String = paragraphNode.toString();
      nodeText = replaceLinkTokensWithHtmlLinks(nodeText);
      var result:String = '<p><font size="' + getHTMLFontSize_Text() + '">' + nodeText + '</font></p>';
      return result;
   }

   public static function createHTML_CreditsPartHyperlink(text:String, url:String):String {
      var result:String;
      if (url) {
         result = '<font size="' + getHTMLFontSize_Text() + '"><a href="event:' + url + '">' + text + '</a></font>';
      } else {
         result = '<font size="' + getHTMLFontSize_Text() + '">' + text + '</font>';
      }
      return result;
   }

   public static function createHTML_CreditsPartHyperlinkParagraph(text:String, url:String):String {
      var result:String = "<p>" + createHTML_CreditsPartHyperlink(text, url) + "</p>";
      return result;
   }

   public static function createHTML_CreditsPart_Note(partXML:XML):String {
      var result:String = "";
      var noteNode:XML = partXML.note[0];
      result += '<p><font size="' + getHTMLFontSize_Text() + '">' + noteNode.toString() + '</font></p>';
      return result;
   }

   public static function createHTML_CreditsPartTitle(title:String):String {
      var result:String = "";
      result += '<p><font size="' + getHTMLFontSize_PartTitle() + '"><b>';
      result += title;
      result += "</b></font></p>";
      return result;
   }

   public static function createHTML_CreditsTitle(text:String):String {
      var result:String = "";
      result += '<p><font size="' + getHTMLFontSize_Title() + '"><b>';
      result += text;
      result += "</b></font></p>";
      return result;
   }

   public static function createHTML_ListItemEnd():String {
      return "</li>";
   }

   public static function createHTML_ListItemStart():String {
      return "<li>";
   }

   public static function createHTML_Spacer():String {
      var result:String = "";
      result += '<p><font size="' + getHTMLFontSize_Spacer() + '">&nbsp;</font></p>';
      return result;
   }

   public static function createHTML_UnorderedListEnd():String {
      return "</ul>";
   }

   public static function createHTML_UnorderedListStart():String {
      return "<ul>";
   }

   public static function getHTMLFontSize_PartTitle():int {
      return (Math.round(Utils_Text.getStandardFontSize() * 1.25));
   }

   public static function getHTMLFontSize_Spacer():int {
      return (Math.round(Utils_Text.getStandardFontSize() / 3));
   }

   public static function getHTMLFontSize_Text():int {
      return (Math.round(Utils_Text.getStandardFontSize()));
   }

   public static function getHTMLFontSize_Title():int {
      return (Math.round(Utils_Text.getStandardFontSize() * 1.5));
   }

   public static function getHTMLStyleSheet():StyleSheet {
      var styles:String = "a { color: #5c2a83; text-decoration: underline; } a:hover { color: #8f4aa6; text-decoration: underline; }";
      var myStyleSheet:StyleSheet = new StyleSheet();
      myStyleSheet.parseCSS(styles);
      return myStyleSheet;
   }

   public static function hasSingleNoteElement(xmlNode:XML):Boolean {
      return (XMLList(xmlNode.note).length() == 1);
   }

   public static function hasSingleTextElement(xmlNode:XML):Boolean {
      return (XMLList(xmlNode.text).length() == 1);
   }

   // Links are indicated like [+this+http://someURL.com+].
   public static function replaceLinkTokensWithHtmlLinks(s:String):String {
      var result:String = "";
      var remainingInput:String = s;
      while (true) {
         if (remainingInput.indexOf("[+") != -1) {
            var beginIndex:int = remainingInput.indexOf("[+");
            var endIndex:int = remainingInput.indexOf("+]") + 1;
            if ((endIndex - beginIndex) < 16)
               break;
            var linkString:String = remainingInput.substr(beginIndex + 2, ((endIndex - beginIndex) - 3));
            var dividerIndexWithinLinkString:int = linkString.indexOf("+");
            if (dividerIndexWithinLinkString == -1)
               break;
            if (beginIndex > 0)
               result += remainingInput.substr(0, beginIndex);
            var linkText:String = linkString.substr(0, dividerIndexWithinLinkString);
            var url:String = linkString.substr(dividerIndexWithinLinkString + 1);
            if (url.indexOf("http") != 0)
               break;
            if (url.indexOf(".") < 8)
               break;
            result += '<a href="event:' + url + '">' + linkText + '</a>';
            remainingInput = remainingInput.substr(endIndex + 1);
         } else {
            break;
         }
      }
      result += remainingInput;
      return result;
   }
}
}


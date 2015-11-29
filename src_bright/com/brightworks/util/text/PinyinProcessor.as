package com.brightworks.util.text {
    import com.brightworks.util.Log;
import com.brightworks.util.Utils_DataConversionComparison;
import com.brightworks.util.Utils_String;
import com.brightworks.util.Utils_XML;

    import flash.filesystem.File;
import flash.utils.Dictionary;

public class PinyinProcessor {

        private static var _index_NumberToToneConversions:Dictionary;
        private static var _stringsToReplaceList:Array; // Needed for ordering - the Dictionary doesn't do that

        public static function convertNumberToneIndicatorsToToneMarks(s:String):String {
            loadNumberToneToToneMarkConversions();
            var result:String = s;
            for each (var key:String in _stringsToReplaceList) {
                var replacementValue:String = _index_NumberToToneConversions[key];
                result = Utils_String.replaceAll(result, key, replacementValue);
            }
            return result;
        }

        private static function loadNumberToneToToneMarkConversions():void {
            if (_index_NumberToToneConversions)
                return;
            _index_NumberToToneConversions = new Dictionary();
            _stringsToReplaceList = [];
            var appDir:File = File.applicationDirectory;
            var f:File;
            var filePathString:String = "assets" + File.separator + "xml" + File.separator + "pinyin_replacements.xml";
            f = appDir.resolvePath(filePathString);
            if (!f.exists) {
                Log.error("MainModel.loadNumberToneToToneMarkConversions(): pinyin replacements file is missing: " + filePathString);
                return;
            }
            var xml:XML = Utils_XML.synchronousLoadXML(f, true);
            var itemNodes:XMLList = xml.items[0].item;
            for each (var itemNode:XML in itemNodes) {
                var stringsToBeReplacedCommaDelimitedString:String = itemNode.search[0].toString();
                var replacementStringsCommaDelimitedString:String = itemNode.replace[0].toString();
                var stringsToBeReplacedList:Array = stringsToBeReplacedCommaDelimitedString.split(",");
                var replacementStringsList:Array = replacementStringsCommaDelimitedString.split(",");
                if (stringsToBeReplacedList.length != replacementStringsList.length) {
                    Log.error("MainModel.loadNumberToneToToneMarkConversions(): number of search and replace strings doesn't match")
                    continue;
                }
                var count:uint = stringsToBeReplacedList.length;
                for (var i:uint = 0; i < count; i++) {
                    var stringToReplace:String = String(stringsToBeReplacedList[i]);
                    var replacementString:String = String(replacementStringsList[i])
                    _index_NumberToToneConversions[stringToReplace] = replacementString;
                    _stringsToReplaceList.push(stringToReplace);
                }
            }
        }




    }
}

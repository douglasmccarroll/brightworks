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
import com.brightworks.vo.IVO;

import flash.utils.Dictionary;

import mx.collections.ArrayCollection;

public class Utils_ArrayVectorEtc {

   public static function copyArray(a:Array):Array {
      return a.slice();
   }

   public static function copyArrayItemsToArray(copyFromArray:Array, copyToArray:Array):void {
      for each (var item:Object in copyFromArray) {
         copyToArray.push(item);
      }
   }

   public static function createArrayContainingSequenceOfIntegers(endInteger:int, startInteger:int = 0):Array {
      if (startInteger > endInteger) {
         Log.warn("com.brightworks.util.Utils_ArrayVectorEtc.createArrayContainingSequenceOfIntegers(): startInteger (" + startInteger + ") is greater than endInteger (" + endInteger + ")");
         return null;
      }
      var result:Array = new Array();
      var elementCount:int = (endInteger - startInteger) + 1;
      var currentValue:int = startInteger;
      for (var i:int = 0; i < elementCount; i++) {
         result[i] = currentValue;
         currentValue++;
      }
      return result;
   }

   public static function createArrayContainingFirstNValuesFromArray(a:Array, numberOfValues:uint):Array {
      var valuesToCopy:uint = Math.min(numberOfValues, a.length);
      var result:Array = [];
      for (var i:uint = 0; i > numberOfValues; i++) {
         result[i] = a[i];
      }
      return result
   }

   public static function createArrayContainingValuesFromSpecifiedPropForPassedArrayItems(passedArray:Array, propName:String, enforceAllItemsHaveProp:Boolean):Array {
      if ((enforceAllItemsHaveProp) && (!doAllItemsHaveSpecifiedProp(passedArray, propName))) {
         Log.fatal(["Utils_ArrayVectorEtc.createArrayContainingValuesFromSpecifiedPropForPassedArrayItems(): enforceAllItemsHaveProp is true, but some items don't have prop '" + propName + "'", passedArray]);
      }
      var result:Array = [];
      for each (var item:Object in passedArray) {
         if (item.hasOwnProperty(propName))
            result.push(item[propName]);
      }
      return result;
   }

   public static function createStringArrayContainingStringsInOneArrayContainedBySecondStringArray(firstArray:Array, secondArray:Array):Array {
      var result:Array = [];
      for (var propName:String in firstArray) {
         if (secondArray.indexOf(propName) != -1)
            result.push(propName);
      }
      return result;
   }

   // delete item from Dictionary: delete myDict[itemKey];

   public static function doAllItemsHaveSpecifiedProp(array:Array, propName:String):Boolean {
      for each (var item:Object in array) {
         if (!item.hasOwnProperty(propName))
            return false;
      }
      return true;
   }

   public static function doesArrayContainObjectWithSpecifiedValueForSpecifiedProp(a:Array, value:Object, propName:String):Boolean {
      if (!((value is String) || (value is int) || (value is Number)))
         Log.fatal(["Utils_ArrayVectorEtc.doesArrayContainObjectWithSpecifiedValueForSpecifiedProp(): Value argument isn't a String, int, or Number - other types haven't been implemented for this method yet", "Value:", value]);
      var item:Object;
      for each (item in a) {
         if (!item.hasOwnProperty(propName))
            continue;
         if (item[propName] == value)
            return true;
      }
      return false;
   }

   public static function doesArrayContainSingleObjectWithSpecifiedValueForSpecifiedProp(a:Array, value:Object, propName:String):Boolean {
      if (!((value is String) || (value is int) || (value is Number)))
         Log.fatal(["Utils_ArrayVectorEtc.doesArrayContainSingleObjectWithSpecifiedValueForSpecifiedProp(): Value argument isn't a String, int, or Number - other types haven't been implemented for this method yet", "Value:", value]);
      var item:Object;
      var matchCount:int = 0;
      for each (item in a) {
         if (!item.hasOwnProperty(propName))
            continue;
         if (item[propName] == value)
            matchCount++;
      }
      return (matchCount == 1);
   }

   public static function doesArrayContainZeroOrOneObjectWithSpecifiedValueForSpecifiedProp(a:Array, value:Object, propName:String):Boolean {
      if (!((value is String) || (value is int) || (value is Number)))
         Log.fatal(["Utils_ArrayVectorEtc.doesArrayContainZeroOrOneObjectWithSpecifiedValueForSpecifiedProp(): Value argument isn't a String, int, or Number - other types haven't been implemented for this method yet", "Value:", value]);
      var item:Object;
      var matchCount:int = 0;
      for each (item in a) {
         if (!item.hasOwnProperty(propName))
            continue;
         if (item[propName] == value)
            matchCount++;
      }
      return (matchCount <= 1);
   }

   public static function doesDictionaryContainKey(d:Dictionary, o:Object):Boolean {
      return (o in d);
   }

   public static function getDictionaryLength(d:Dictionary):uint {
      var result:uint = 0;
      for each (var o:Object in d) {
         result++;
      }
      return result;
   }

   public static function getSingleObjectWithSpecifiedValueForSpecifiedPropFromArray(value:Object, propName:String, a:Array):Object {
      if (!((value is String) || (value is int) || (value is Number)))
         Log.fatal(["Utils_ArrayVectorEtc.getSingleObjectWithSpecifiedValueForSpecifiedPropFromArray(): Value argument isn't a String, int, or Number - other types haven't been implemented for this method yet", "Value:", value]);
      var item:Object;
      var result:Object;
      var multipleMatches:Boolean = false;
      for each (item in a) {
         if (!item.hasOwnProperty(propName))
            continue;
         if (item[propName] == value) {
            if (result) {
               multipleMatches = true;
               break;
            }
            else {
               result = item;
            }
         }
      }
      if (multipleMatches)
         return null;
      return result;
   }

   public static function isArrayCollectionsContainEqualItemsInSameOrder(ac1:ArrayCollection, ac2:ArrayCollection, inconsistencyList:Array):Boolean {
      // inconsistencyList should be an empty Array
      if (ac1.length != ac2.length)
         return false;
      var itemCount:uint = ac1.length;
      for (var i:uint = 0; i < itemCount; i++) {
         if (ac1[i] != ac2[i]) {
            inconsistencyList.push(ac1[i]);
            inconsistencyList.push(ac2[i]);
            return false;
         }
      }
      return true;
   }

   public static function removeFirstInstanceOfInstanceFromArray(o:Object, a:Array):void {
      if (a.indexOf(o) == -1)
         throw new Error("Utils_ArrayVectorEtc.removeFirstInstanceOfInstanceFromArray(): instance isn't in array");
      a.splice(a.indexOf(o), 1);
   }

   public static function removePropsFromDictionary(propKeyList:Array, dict:Dictionary):void {
      for each (var o:Object in propKeyList) {
         delete dict[o];
      }
   }

   // removeItemFromArrayAtIndex:   a.splice(index, 1);

   public static function reorderArrayCollectionBasedOnNewFirstItem(ac:ArrayCollection, item:Object):void {
      var tempAC:ArrayCollection = new ArrayCollection();
      var itemIndex:int = ac.getItemIndex(item);
      if (itemIndex == -1) {
         Log.warn("Utils_ArrayVectorEtc.reorderArrayCollectionBasedOnNewFirstItem(): passed item isn't in passed array");
         return;
      }
      for (var i:int = itemIndex; i < ac.length; i++) {
         tempAC.addItem(ac[i]);
      }
      for (i = 0; i < itemIndex; i++) {
         tempAC.addItem(ac[i]);
      }
      ac.removeAll();
      ac.addAll(tempAC);
   }

   public static function useVoEqualsFunctionToDeleteFirstMatchingItemInArray(passedVo:IVO, array:Array, requireMatch:Boolean):void {
      var voIndex:int = useVoEqualsFunctionToGetIndexOfVoInArray(passedVo, array);
      if (voIndex == -1) {
         if (requireMatch)
            throw new Error("Utils_ArrayVectorEtc.useVoEqualsFunctionToDeleteFirstMatchingItemInArray(): VO isn't in array");
      }
      else {
         array.splice(voIndex, 1);
      }
   }

   public static function useVoEqualsFunctionToDeleteMatchingPropInDictionary(passedVo:IVO, dict:Dictionary, requireMatch:Boolean):void {
      var keyProp:IVO = useVoEqualsFunctionToGetKeyPropVOInDictionary(passedVo, dict);
      if (keyProp) {
         delete dict[keyProp];
      }
      else {
         if (requireMatch)
            throw new Error("Utils_ArrayVectorEtc.useVoEqualsFunctionToDeleteMatchingPropInDictionary(): no matching VO key prop in Dictionary");
      }
   }

   public static function useVoEqualsFunctionToGetItemFromDictionary(passedVo:IVO, dict:Dictionary, requireMatch:Boolean):Object {
      var result:Object;
      var keyPropVO:IVO = useVoEqualsFunctionToGetKeyPropVOInDictionary(passedVo, dict);
      if (keyPropVO) {
         result = dict[keyPropVO];
      }
      else {
         if (requireMatch)
            throw new Error("Utils_ArrayVectorEtc.useVoEqualsFunctionToGetItemFromDictionary(): no matching VO key prop in Dictionary");
      }
      return result;
   }

   public static function useVoEqualsFunctionToGetIndexOfVoInArray(passedVo:IVO, array:Array):int {
      for (var i:uint = 0; i < array.length; i++) {
         var voFromList:IVO = array[i];
         if (voFromList.equals(passedVo))
            return i;
      }
      return -1;
   }

   public static function useVoEqualsFunctionToGetIndexOfVoInArrayCollection(passedVo:IVO, ac:ArrayCollection):int {
      for (var i:uint = 0; i < ac.length; i++) {
         var voFromList:IVO = ac[i];
         if (voFromList.equals(passedVo))
            return i;
      }
      return -1;
   }

   public static function useVoEqualsFunctionToGetKeyPropVOInDictionary(passedVO:IVO, dict:Dictionary):IVO {
      for (var o:Object in dict) {
         var vo:IVO = IVO(o);
         if (vo.equals(passedVO))
            return vo;
      }
      return null;
   }

}
}
















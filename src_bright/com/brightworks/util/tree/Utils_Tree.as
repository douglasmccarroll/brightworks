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
package com.brightworks.util.tree {
import com.brightworks.component.treelist.TreeItem;
import com.brightworks.component.treelist.TreeListLevelInfo;
import com.brightworks.constant.Constant_ReleaseType;
import com.brightworks.util.Log;
import com.langcollab.languagementor.vo.LessonVersionVO;

import mx.collections.ArrayCollection;
import mx.collections.Sort;
import mx.collections.SortField;

public class Utils_Tree {
   public static function createDataSourceObject(sourceObjects:ArrayCollection, treeHierarchyInfo:Array, parentItem:TreeItem = null):ArrayCollection {
      if (treeHierarchyInfo.length < 1) {
         Log.fatal("Utils_Tree.createDataSourceObject(): zero-length treeHierarchyInfo argument");
         return null;
      }
      var levelInfo:TreeListLevelInfo = treeHierarchyInfo[0]
      var result:ArrayCollection = new ArrayCollection();
      // Set up Sort for the result ArrayCollection
      var levelSortingField:String = levelInfo.customSort ? "sortInfo" : "label";
      var isNumericSort:Boolean = (levelInfo.customSort && levelInfo.customSortDataIsNumeric);
      var sort:Sort = new Sort();
      var sortField:SortField = new SortField(levelSortingField, true, false, isNumericSort);
      sort.fields = [sortField];
      result.sort = sort;
      result.refresh();

      var currentSourceObject:Object = null;
      var currentSourceObjectDisplayAndGroupingValue:String = null;
      if (treeHierarchyInfo.length > 1) {
         // This is a non-final "branch" level
         var sortedData:Object = new Object();
         for each (currentSourceObject in sourceObjects) {
            currentSourceObjectDisplayAndGroupingValue = currentSourceObject[levelInfo.displayAndGroupingProp];
            if (!sortedData.hasOwnProperty(currentSourceObjectDisplayAndGroupingValue)) {
               sortedData[currentSourceObjectDisplayAndGroupingValue] = new Object();
               sortedData[currentSourceObjectDisplayAndGroupingValue].sourceObjectList = new ArrayCollection();
               if (levelInfo.customSort)
                  sortedData[currentSourceObjectDisplayAndGroupingValue].sortInfo = currentSourceObject[levelInfo.sortInfoProp];
            }
            ArrayCollection(sortedData[currentSourceObjectDisplayAndGroupingValue].sourceObjectList).addItem(currentSourceObject);
         }
         var currentSortedListLevelGroupingValue:String = null;
         for (currentSortedListLevelGroupingValue in sortedData) {
            var branchItem:TreeItem = new TreeItem();
            branchItem.parent = parentItem;
            branchItem.levelDisplayName = levelInfo.levelDisplayName;
            branchItem.label = currentSortedListLevelGroupingValue;
            branchItem.children = createDataSourceObject(sortedData[currentSortedListLevelGroupingValue].sourceObjectList, treeHierarchyInfo.slice(1, treeHierarchyInfo.length), branchItem);
            if (levelInfo.customSort) {
               branchItem.sortInfo = sortedData[currentSortedListLevelGroupingValue].sortInfo;
            }
            result.addItem(branchItem);
         }
      }
      else {
         // This is the final "leaf" level
         var leafItem:TreeItem;
         for each (currentSourceObject in sourceObjects) {
            leafItem = new TreeItem();
            leafItem.data = currentSourceObject;
            leafItem.isLeaf = true;
            leafItem.label = currentSourceObject[levelInfo.displayAndGroupingProp];
            if (LessonVersionVO(currentSourceObject.lessonVersionVO).releaseType == Constant_ReleaseType.BETA) {
               leafItem.label += " (Beta)";
            }
            if (levelInfo.customSort)
               leafItem.sortInfo = currentSourceObject[levelInfo.sortInfoProp];
            leafItem.levelDisplayName = levelInfo.levelDisplayName;
            leafItem.parent = parentItem;
            result.addItem(leafItem);
         }
      }
      return result;
   }
}
}


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
package com.brightworks.vo {
import flash.utils.Dictionary;

public interface IVO {
   function equals(vo:IVO):Boolean

   function getPropInfoList():Dictionary

   function getAssociatedTableName():String

   function getClass():Class

   function getPropNameList_KeyProps():Array

   // dmccarroll 200908
   //  This is inherantly error-prone, as it requires that we remember to write
   //  getter/setter code in all VO subclasses for all props where the props
   //  type is such that that != null if not set (e.g. number types & Boolean).
   //  I'm doing it for two reasons:
   //            1. It will allow simpler code when creating
   //               SQLiteQueryData instances.
   //            2. Simpler code there will be less error prone
   //  I'm making a judgment that the tradeoffs are worthwhile, but I'm not sure. :)
   function getPropNameList_SetProps():Array

   function isReferencingInstance(vo:VO):Boolean

}
}

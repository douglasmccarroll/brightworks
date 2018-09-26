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







Singletons that have mutual dependencies with other singletons should be managed by this class.

This class ensures that managed singletons are all instantiated before any properties which contain references to
other managed singletons are set.

If we don't do this, and simply use getInstance() to set properties that reference other singletons, and do this when our
singletons are instantiated, we end up in a loop due to mutual interdepedencies.

Set singletonClassList in your subclass's override of populateClassList()





*/
package com.brightworks.util.singleton {
import com.brightworks.interfaces.IManagedSingleton;

public class SingletonManager {
   protected var singletonClassList:Array;
   protected var singletonInstanceList:Vector.<IManagedSingleton> = new Vector.<IManagedSingleton>();

   public function SingletonManager() {
      populateClassList();
      initializeSingletons();
   }

   protected function populateClassList():void {
      // Override in subclass
   }

   private function initializeSingletons():void {
      for each (var c:Class in singletonClassList) {
         var ms:IManagedSingleton = IManagedSingleton(new c(this));
         singletonInstanceList.push(ms);
      }
      for each (var s:IManagedSingleton in singletonInstanceList) {
         s.initSingleton();
      }
   }
}
}

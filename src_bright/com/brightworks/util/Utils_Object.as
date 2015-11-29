/*
Copyright 2008 - 2013 Brightworks, Inc.

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
package com.brightworks.util
{
    import flash.system.System;
    import flash.utils.ByteArray;
    import flash.utils.Dictionary;
    import flash.utils.describeType;
    import flash.utils.getDefinitionByName;
    import flash.utils.getQualifiedClassName;

    import mx.collections.ArrayCollection;
    import mx.collections.Sort;
    import mx.collections.SortField;
    import mx.utils.ObjectUtil;

    public class Utils_Object
    {
        // --------------------------------------------
        //
        //           Public Methods
        //
        // --------------------------------------------

        public static function cloneInstance(o:Object):*
        {
            var result:*;
            // For some reason, this doesn't work with Dictionaries
            // Also, at least for my purposes, I don't really want a complete clone - I want
            // to clone the values but not the props
            if (o is Dictionary)
            {
                Log.warn("Utils_Object.cloneFunction(): Can't handle Dictionary instances");
                return null;
            }
            var byteArray:ByteArray = new ByteArray();
            byteArray.writeObject(o);
            byteArray.position = 0;
            result = byteArray.readObject();
            byteArray.clear();
            return result;
        }

        public static function createNewDictionaryWithClonedProps(d:Dictionary):Dictionary
        {
            var result:Dictionary = new Dictionary();
            var dictProp:Object;
            var dictVal:Object;
            for (dictProp in d)
            {
                dictVal = d[dictProp];
                if (dictVal is Dictionary)
                {
                    result[dictProp] = createNewDictionaryWithClonedProps(Dictionary(dictVal));
                }
                else
                {
                    result[dictProp] = cloneInstance(dictVal);
                }
            }
            return result;
        }

        public static function doInstancesPropNamesConsistOfSequenceOfIntegers(instance:Object, startInteger:int=0):Boolean
        {
            var propNames:ArrayCollection = new ArrayCollection();
            var sort:Sort = new Sort();
            sort.fields = [new SortField(null, false, false, true)];
            propNames.sort = sort;
            propNames.refresh();
            for (var propName:Object in instance)
            {
                if (!(propName is int))
                    return false;
                propNames.addItem(propName);
            }
            if (propNames.length == 0)
            {
                Log.warn("Utils_Object.doInstancesPropNamesConsistOfSequenceOfIntegers(): instance contains no props.");
                return false;
            }
            var currentInteger:int = propNames[0];
            if (startInteger)
            {
                if (currentInteger != startInteger)
                    return false;
            }
            for each (var name:int in propNames)
            {
                if (name != currentInteger)
                    return false;
                currentInteger++;
            }
            return true;
        }

        /**
         * Returns a <code>Class</code> object that corresponds with the given
         * instance. If no correspoding class was found, a
         * <code>ClassNotFoundError</code> will be thrown.
         *
         * @param instance the instance from which to return the class
         * @return the <code>Class</code> that corresponds with the given instance
         * @see org.pranaframework.errors.ClassNotFoundError
         */
        // From Prana framework, see Prana license at bottom of file
        public static function getClassForInstance(instance:*):Class
        {
            var classInfo:Object = getClassInfoForInstance(instance);
            return getClassForName(classInfo.name);
        }

        /**
         * Returns a <code>Class</code> object that corresponds with the given
         * name. If no correspoding class was found, a
         * <code>ClassNotFoundError</code> will be thrown.
         *
         * @param name the name from which to return the class
         * @return the <code>Class</code> that corresponds with the given name, or null if none is found
         */
        // From Prana framework, see Prana license at bottom of file
        public static function getClassForName(name:String):Class
        {
            var result:Class;
            try
            {
                result = getDefinitionByName(name) as Class;
            }
            catch (e:ReferenceError)
            {
                return null;
            }
            return result;
        }

        /**
         * Wraps mx.utils.ObjectUtil.getClassInfo() and adds support for the following
         * primitive types: String, Number, int, uint, Boolean, Date and Array.
         */
        // From Prana framework, see Prana license at bottom of file
        public static function getClassInfoForInstance(object:Object):Object
        {
            var result:Object = {};
            var isPrimitive:Boolean = ObjectUtil.isSimple(object);

            if (isPrimitive)
            {
                var type:String = typeof(object);
                switch (type)
                {
                    case "number":
                        if (object is uint)
                        {
                            result.name = "uint";
                        }
                        else if (object is int)
                        {
                            result.name = "int";
                        }
                        else if (object is Number)
                        {
                            result.name = "Number";
                        }
                        break;
                    case "string":
                        result.name = "String";
                        break;
                    case "boolean":
                        result.name = "Boolean";
                        break;
                    case "object":
                        if (object is Date)
                            result.name = "Date";
                        if (object is Array)
                            result.name = "Array";
                        break;
                }
            }
            else
            {
                result = ObjectUtil.getClassInfo(object);
            }
            return result;
        }

        public static function getClassNameForInstance(instance:Object):String
        {
            var xml:XML = describeType(instance);
            var fullName:String = xml.@name.toString();
            var className:String;
            switch (fullName)
            {
                case "Object":
                    className = fullName;
                    break;
                default:
                    if (fullName.indexOf("::") == -1)
                    {
                        if (fullName.indexOf(".") != -1)
                            Log.fatal("Utils_Object.getClassNameForInstance(): fullName contains '.' but not '::'");
                        className = fullName;
                    }
                    else
                    {
                        className = String(fullName).split("::")[1];
                    }
            }
            System.disposeXML(xml);
            return className;
        }

        public static function getDynamicVariableCount(instance:Object):int
        {
            var count:int = 0;
            for (var propName:Object in instance)
            {
                count++;
            }
            return count;
        }

        public static function getFullyQualifiedClassNameForInstance(instance:Object):String
        {
            var xml:XML = describeType(instance);
            var className:String = String(xml.@name.toString()).replace("::", ":");
            System.disposeXML(xml);
            return className;
        }

        public static function getInstancePropInfoList(instance:Object):Dictionary
        {
            var result:Dictionary = new Dictionary();
            var xml:XML = describeType(instance);
            var element:XML;
            var elements:XMLList = xml.accessor; // public props defined by getter and/or setter
            for each (element in elements)
            {
                result[element.@name.toString()] = element.@type.toString();
            }
            elements = xml.variable; // public props
            for each (element in elements)
            {
                result[element.@name.toString()] = element.@type.toString();
            }
            System.disposeXML(xml);
            return result;
        }

        public static function getInstancePropNamesArrayListForNonNullProps(instance:Object):Array
        {
            // I'm leaving this function here to document the fact that this is a Bad Idea
            //   - int props are zero when not set
            //   - bool props are false when not set
            //   - there is no practical way to determine whether these props have ever been set
            return [];
        }

        // Creates a formatted string displaying public props and their values
        public static function getInstanceStateInfo(o:Object, recursionLevel:int = -1):String
        {
            // We don't want to use describeType() or do any of the other complex stuff that this method does 
            // if o is a simple literal.
            if ((o is String) ||
                (o is int) ||
                (o is uint) ||
                (o is Number) ||
                (o is Boolean))
            {
                return o.toString();
            }
            recursionLevel++
            var indentString:String = "";
            var i:int;
            for (i = 0; i <= recursionLevel; i++)
            {
                indentString += "- ";
            }
            var xml:XML = describeType(o);
            var className:String = String(xml.@name.toString()).replace("::", ":");
            if (o is Class)
            {
                System.disposeXML(xml);
                return indentString + "Class: " + className;
            }
            // First, create arrays of property names and their data types, and find length of longest property name
            var propertyInfoList:ArrayCollection = new ArrayCollection();
            var sort:Sort = new Sort();
            sort.fields = [new SortField("propDisplayName", true)];
            propertyInfoList.sort = sort;
            propertyInfoList.refresh();
            var longestNameLength:int = 0;
            var propDataType:String;
            var propDisplayName:String;
            var propOrArrayElementNumber:Object;
            var propVal:Object;
            var propValDataType:String;
            if (className == "flash.utils:Dictionary")
                var ccc:int = 0; // debug
            if (className.indexOf("Vector.<") != -1)
                className = "Vector";
            switch (className)
            {
                case "Array":
                case "Vector":
                    var length:uint = 0;
                    if (className == "Array")
                        length = (o as Array).length;
                    if (className == "Vector")
                    {
                        for (var tempobj:Object in o)
                        {
                            length ++;
                        }
                    }
                    if (length == 0)
                        className += " - 0 elements"
                    for (i = 0; i < length; i++)
                    {
                        propDisplayName = "[" + String(i) + "]";
                        propOrArrayElementNumber = i;
                        propVal = o[i];
                        propValDataType = getClassNameForInstance(propVal);
                        if (!propValDataType)
                        {
                            Log.fatal("Utils_Object.getInstanceStateInfo(): propValDataType is null");
                        }
                        propertyInfoList.addItem(
                            {
                                propDisplayName:propDisplayName, 
                                propOrArrayElementNumber:propOrArrayElementNumber,
                                propValDataType:propValDataType
                            });
                        longestNameLength = Math.max(longestNameLength, propDisplayName.length);
                    }
                    break;
                case "flash.utils:Dictionary":
                case "Object":
                    for (propOrArrayElementNumber in o)
                    {
                        propDataType = getClassNameForInstance(propOrArrayElementNumber);
                        propVal = o[propOrArrayElementNumber];
                        propValDataType = getClassNameForInstance(propVal);
                        if (!propDataType)
                        {
                            Log.fatal("Utils_Object.getInstanceStateInfo(): propDataType is null");
                        }
                        if (!propValDataType)
                        {
                            Log.fatal("Utils_Object.getInstanceStateInfo(): propValDataType is null");
                        }
                        switch (propDataType)
                        {
                            case "int":
                            case "String":
                                propDisplayName = String(propOrArrayElementNumber);
                                break;
                            default:
                                // This means that if this is a Dictionary, and the prop is
                                // something other than a String or an int, we'll just show 
                                // the name of the class as its name, and of the details of the
                                // instance. (For now.  :)
                                propDisplayName = propDataType;
                        }
                        propertyInfoList.addItem(
                            {
                                propDisplayName:propDisplayName, 
                                propOrArrayElementNumber:propOrArrayElementNumber,
                                propValDataType:propValDataType
                            });
                        longestNameLength = Math.max(longestNameLength, propDisplayName.length);
                    }
                    break;
                default:
                    var accessorElements:XMLList = xml.accessor;
                    var variableElements:XMLList = xml.variable;
                    for each (var list:XMLList in[accessorElements, variableElements])
                    {
                        for each (var element:XML in list)
                        {
                            propOrArrayElementNumber = element.@name.toString();
                            propValDataType = element.@type.toString();
                            propertyInfoList.addItem(
                                {
                                    propDisplayName:propOrArrayElementNumber, 
                                    propOrArrayElementNumber:propOrArrayElementNumber,
                                    propValDataType:propValDataType
                                });
                            longestNameLength = Math.max(longestNameLength, propOrArrayElementNumber.length);
                        }
                    }
            }
            var propertyInfoString:String = "";
            for each (var propertyInfo:Object in propertyInfoList)
            {
                propVal = o[propertyInfo.propOrArrayElementNumber];
                propertyInfoString += "\n" + indentString;
                propertyInfoString += Utils_String.padEnd(propertyInfo.propDisplayName, longestNameLength + 1);
                propertyInfoString += ": ";
                switch (propertyInfo.propValDataType)
                {
                    case "String":
                        propertyInfoString += ' "' + propVal + '"';
                        break;
                    case "Boolean":
                    case "int":
                    case "Number":
                    case "uint":
                        propertyInfoString += " " + propVal.toString();
                        break;
                    case "null":
                        propertyInfoString += " null";
                        break;
                    case "void":
                        propertyInfoString += " void";
                        break;
                    default:
                        // Property is an Object - recursive call - up to a point - we have to 
                        // limit this - at least until we start checking to make sure that we
                        // don't get into a loop where instances reference each other.
                        var recursionLimit:int = 20;
                        if (recursionLevel <= 20)
                        {
                            propertyInfoString += " " + getInstanceStateInfo(propVal, recursionLevel);
                        }
                        else
                        {
                            propertyInfoString += " " + propertyInfo.propValDataType + " instance (beyond recursion limit of " + recursionLimit + " recursions)";
                        }
                }
            }
            var result:String = className + propertyInfoString;
            recursionLevel--;
            System.disposeXML(xml);
            return result;
        }

        /**
         * Returns the class that the passed in clazz extends. If no parent class
         * was found, in case of Object, null is returned.
         * @param clazz the class to get the parent class from
         * @returns the parent class or null if no parent class was found
         */
        // From Prana framework, see Prana license at bottom of file
        public static function getParentClassOf(clazz:Class):Class
        {
            if (clazz == null)
            {
                Log.warn("Utils_Object.getParentClassOf(): null param passed");
                return null;
            }
            var result:Class;
            var classDescription:XML = describeType(clazz) as XML;
            var parentClasses:XMLList = classDescription.factory.extendsClass;
            if (parentClasses.length() > 0)
                result = getClassForName(parentClasses[0].@type);
            System.disposeXML(classDescription);
            return result;
        }

        /**
         * Returns whether the passed in Class object is a subclass of the
         * passed in parent Class.
         */
        // From Prana framework, see Prana license at bottom of file
        public static function isClassSubclassOf(clazz:Class, parentClass:Class):Boolean
        {
            if (clazz == null)
                Log.fatal("Utils_Object.isClassSubclassOf(): clazz param is null");
            if (parentClass == null)
                Log.fatal("Utils_Object.isClassSubclassOf(): parentClass param is null");
            var classDescription:XML = describeType(clazz) as XML;
            var parentName:String = getQualifiedClassName(parentClass);
            System.disposeXML(classDescription);
            return (classDescription.factory.extendsClass.(@type == parentName).length() != 0);
        }

        /**
         * Returns whether the passed in <code>Class</code> object implements
         * the given interface.
         *
         * @param clazz the class to check for an implemented interface
         * @param interfaze the interface that the clazz argument should implement
         * @return true if the clazz object implements the given interface; false if not
         */
        // From Prana framework, see Prana license at bottom of file
        public static function isImplementationOf(clazz:Class, interfaze:Class):Boolean
        {
            var result:Boolean;
            if (clazz == null)
            {
                result = false;
            }
            else
            {
                var classDescription:XML = describeType(clazz) as XML;
                result = (classDescription.factory.implementsInterface.(@type == getQualifiedClassName(interfaze)).length() != 0);
                System.disposeXML(classDescription);
            }
            return result;
        }

        // --------------------------------------------
        //
        //           Private Methods
        //
        // --------------------------------------------
    }
}

// Methods marked above as "from Prana framework" are subject to this license:

/**
 * Copyright (c) 2007, the original author(s)
 *
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *     * Redistributions of source code must retain the above copyright notice,
 *       this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *     * Neither the name of the Prana Framework nor the names of its contributors
 *       may be used to endorse or promote products derived from this software
 *       without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */











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
    public class Utils_Color
    {
        public static function separateColors(color:uint):Object
        {
            var o:Object = new Object();
            if (color > 0xFFFFFF)
            {
                // Color is 32 bit color
                o.alpha  = (color >>> 24);
                o.red    = (color >>> 16) & 0xFF;
            }
            else
            {
                // Color is 24 bit color
                o.alpha  = null;
                o.red    = (color >>> 16) & 0xFF;
            }
            o.green  = (color >>> 8) & 0xFF;
            o.blue   = color & 0xFF;
            return o;
        }
    }
}
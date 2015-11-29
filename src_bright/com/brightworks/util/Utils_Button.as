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
    import flash.geom.Rectangle;
    
    import spark.components.Button;
    import spark.components.SkinnableContainer;
    import spark.core.SpriteVisualElement;

    public class Utils_Button
    {
        public static function addHitArea(button:Button, rect:Rectangle, parentComp:SkinnableContainer):void
        {
            var newHitArea:SpriteVisualElement = new SpriteVisualElement();
            newHitArea.visible = false;
            newHitArea.mouseEnabled=false;
            newHitArea.graphics.clear();
            newHitArea.graphics.beginFill(0x000000, 1.0);
            newHitArea.graphics.drawRect(rect.x, rect.y, rect.width, rect.height);
            newHitArea.graphics.endFill();
            parentComp.addElement(newHitArea);
            button.hitArea = newHitArea;
            button.validateDisplayList();
        }    }
}
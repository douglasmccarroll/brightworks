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
package com.brightworks.component.itemrenderer
{
    // This class is a modified version of code written by Nahuel Foronda for this article:
    // http://www.asfusion.com/blog/entry/mobile-itemrenderer-in-actionscript-part-4

    import com.brightworks.component.core.StyleClientSpriteVisualElement;
    
    import spark.components.IItemRenderer;

    public class ItemRenderer_Mobile_Base extends StyleClientSpriteVisualElement implements IItemRenderer
    {
        //--------------------------------------------------------------------------
        //
        //  Setters and Getters
        //
        //--------------------------------------------------------------------------

        private var _data:Object;

        public function set data(value:Object):void
        {
            if (_data == value)
                return;

            _data = value;
            // if the elements has been created we set the values
            if (creationComplete)
                setValues();
        }

        public function get data():Object
        {
            return _data;
        }

        //Property not used but it is required by the interface IItemRenderer
        private var _dragging:Boolean;

        public function set dragging(value:Boolean):void
        {
            _dragging = value;
        }

        public function get dragging():Boolean
        {
            return _dragging;
        }

        private var _itemIndex:int;

        public function set itemIndex(value:int):void
        {
            _itemIndex = value;
        }

        public function get itemIndex():int
        {
            return _itemIndex;
        }

        private var _label:String;

        public function get label():String
        {
            return _label;
        }

        public function set label(value:String):void
        {
            _label = value;
        }

        private var _selected:Boolean = false;

        public function get selected():Boolean
        {
            return _selected;
        }

        public function set selected(value:Boolean):void
        {
            if (value != _selected)
            {
                _selected = value;
                updateSkin();
            }
        }

        // Property not used but it is required by the interface IItemRenderer
        private var _showsCaret:Boolean;

        public function set showsCaret(value:Boolean):void
        {
            _showsCaret = value;
        }

        public function get showsCaret():Boolean
        {
            return _showsCaret;
        }

        //--------------------------------------------------------------------------
        //
        //  Protected Methods
        //
        //--------------------------------------------------------------------------

        protected function setValues():void
        {
            // To be implemented in children
        }

        protected function updateSkin():void
        {
            // To be implemented in children
        }

    }
}

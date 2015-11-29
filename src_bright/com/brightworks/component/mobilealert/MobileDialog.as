package com.brightworks.component.mobilealert
{
    import com.brightworks.component.button.NormalButton;
    import com.brightworks.util.Utils_Layout;

    import flash.display.DisplayObjectContainer;
    import flash.events.MouseEvent;

    import mx.controls.Spacer;
    import mx.core.FlexGlobals;
    import mx.events.ResizeEvent;
    import mx.graphics.SolidColor;
    import mx.managers.PopUpManager;

    import spark.components.Group;
    import spark.components.Label;
    import spark.components.VGroup;
    import spark.filters.DropShadowFilter;
    import spark.primitives.Rect;

    public class MobileDialog extends Group
    {
        private static const _UI_VALUE__ALPHA:Number = .9;
        private static const _UI_VALUE__BACKGROUND__COLOR:uint = 0x333355;
        private static const _UI_VALUE__BACKGROUND__CORNER_RADIUS:uint = 5;
        private static const _UI_VALUE__BACKGROUND__INSET:uint = 8;
        private static const _UI_VALUE__BORDER__COLOR:uint = 0xF9F9F9;
        private static const _UI_VALUE__BORDER__CORNER_RADIUS:uint = 10;
        private static const _UI_VALUE__BORDER__INSET:uint = 0;
        private static const _UI_VALUE__DROP_SHADOW__ALPHA:Number = .3;
        private static const _UI_VALUE__DROP_SHADOW__ANGLE:uint = 45;
        private static const _UI_VALUE__DROP_SHADOW__BLUR_OFFSET:uint = 15;
        private static const _UI_VALUE__DROP_SHADOW__COLOR:uint = 0;
        private static const _UI_VALUE__DROP_SHADOW__DISTANCE:uint = 0;
        private static const _UI_VALUE__LABEL__TEXT_COLOR:uint = 0xFFFFFF;

        private static var _instance:MobileDialog;

        public var callback:Function;

        private var _backgroundRect:Rect;
        private var _borderRect:Rect;
        private var _button:NormalButton;
        private var _componentGroup:VGroup;
        private var _dropShadow:DropShadowFilter;
        private var _textLabel:Label;

        // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        //
        //          Getters / Setters
        //
        // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

        private static var _isDisplayed:Boolean;

        public static function get isDisplayed():Boolean
        {
            return _isDisplayed;
        }

        private var _text:String;
        private var _textChanged:Boolean;

        public function get text():String
        {
            return _text;
        }

        public function set text(value:String):void
        {
            if (value == _text)
                return;
            _text = value;
            _textChanged = true;
        }

        // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        //
        //          Public Methods
        //
        // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

        public function MobileDialog(enforcer:SingletonEnforcer)
        {
            super();
            alpha = _UI_VALUE__ALPHA;
            owner = DisplayObjectContainer(FlexGlobals.topLevelApplication);
            width = computeWidth();
            FlexGlobals.topLevelApplication.addEventListener(ResizeEvent.RESIZE, onAppResize);
            buildUI();
        }

        public static function close(delay:Number = 0):void
        {
            if (!(_instance))
                return;
            _instance.undisplay();
        }

        public static function open(alertText:String, callback:Function = null):void
        {
            if (!(_instance))
            {
                _instance = new MobileDialog(new SingletonEnforcer());
            }
            _instance.callback = callback;
            _instance.text = alertText;
            if (!_isDisplayed)
            {
                PopUpManager.addPopUp(_instance, _instance.owner);
                PopUpManager.centerPopUp(_instance);
                _isDisplayed = true;
            }
        }

        public function undisplay():void
        {
            PopUpManager.removePopUp(this);
            _isDisplayed = false;
            callback = null;
        }

        // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        //
        //          Protected Methods
        //
        // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

        override protected function commitProperties():void
        {
            super.commitProperties();
            if (_textChanged)
            {
                _textLabel.text = _text;
                _textChanged = false;
            }
        }

        // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        //
        //          Private Methods
        //
        // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

        private function buildUI():void
        {
            _dropShadow = new DropShadowFilter(
                _UI_VALUE__DROP_SHADOW__DISTANCE, 
                _UI_VALUE__DROP_SHADOW__ANGLE, 
                _UI_VALUE__DROP_SHADOW__COLOR, 
                _UI_VALUE__DROP_SHADOW__ALPHA, 
                _UI_VALUE__DROP_SHADOW__BLUR_OFFSET, 
                _UI_VALUE__DROP_SHADOW__BLUR_OFFSET);
            filters= [_dropShadow];
            _borderRect = new Rect();
            _borderRect.fill = new SolidColor(_UI_VALUE__BORDER__COLOR);
            _borderRect.top = _UI_VALUE__BORDER__INSET;
            _borderRect.bottom = _UI_VALUE__BORDER__INSET;
            _borderRect.left = _UI_VALUE__BORDER__INSET;
            _borderRect.right = _UI_VALUE__BORDER__INSET;
            _borderRect.radiusX = _UI_VALUE__BORDER__CORNER_RADIUS;
            _borderRect.radiusY = _UI_VALUE__BORDER__CORNER_RADIUS;
            addElement(_borderRect);
            _backgroundRect = new Rect();
            _backgroundRect.fill = new SolidColor(_UI_VALUE__BACKGROUND__COLOR);
            _backgroundRect.top = _UI_VALUE__BACKGROUND__INSET;
            _backgroundRect.bottom = _UI_VALUE__BACKGROUND__INSET;
            _backgroundRect.left = _UI_VALUE__BACKGROUND__INSET;
            _backgroundRect.right = _UI_VALUE__BACKGROUND__INSET;
            _backgroundRect.radiusX = _UI_VALUE__BACKGROUND__CORNER_RADIUS;
            _backgroundRect.radiusY = _UI_VALUE__BACKGROUND__CORNER_RADIUS;
            addElement(_backgroundRect);
            _componentGroup = new VGroup();
            _componentGroup.horizontalAlign = "center";
            _componentGroup.top = Utils_Layout.getStandardPadding() * 2;
            _componentGroup.bottom = Utils_Layout.getStandardPadding() * 2;
            _componentGroup.left = Utils_Layout.getStandardPadding() * 2;
            _componentGroup.right = Utils_Layout.getStandardPadding() * 2;
            _componentGroup.paddingTop = Utils_Layout.getStandardPadding() * 2;
            _componentGroup.paddingBottom = Utils_Layout.getStandardPadding() * 2;
            _componentGroup.paddingLeft = Utils_Layout.getStandardPadding() * 2;
            _componentGroup.paddingRight = Utils_Layout.getStandardPadding() * 2;
            _textLabel = new Label();
            _textLabel.percentWidth = 100;
            _textLabel.setStyle("textAlign", "center");
            _textLabel.setStyle("color", _UI_VALUE__LABEL__TEXT_COLOR);
            _textLabel.text = _text;
            _componentGroup.addElement(_textLabel);
            var spacer:Spacer;
            spacer = new Spacer();
            spacer.height = Utils_Layout.getStandardPadding() * 2;
            _componentGroup.addElement(spacer);
            _button = new NormalButton();
            _button.label = "OK";
            _button.percentWidth = 70;
            _button.addEventListener(MouseEvent.CLICK, onButtonClick);
            _componentGroup.addElement(_button);
            addElement(_componentGroup);
        }

        private function computeWidth():uint
        {
            var smallerDimension:uint = Math.abs(Math.min(
                DisplayObjectContainer(FlexGlobals.topLevelApplication).height,
                DisplayObjectContainer(FlexGlobals.topLevelApplication).width));
            var result:uint = Math.round(smallerDimension * .75);
            return result;
        }

        private function onAppResize(event:ResizeEvent):void
        {
            if (MobileDialog._isDisplayed)
                PopUpManager.centerPopUp(this);
        }

        private function onButtonClick(event:MouseEvent):void
        {
            if (callback is Function)
                callback();
            undisplay();
        }

    }
}

class SingletonEnforcer
{
}

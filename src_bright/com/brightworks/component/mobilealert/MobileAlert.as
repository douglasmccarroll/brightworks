package com.brightworks.component.mobilealert {
import com.brightworks.constant.Constant_Misc;

import flash.display.DisplayObjectContainer;
import flash.events.TimerEvent;
import flash.utils.Timer;

import mx.core.FlexGlobals;
import mx.events.ResizeEvent;
import mx.graphics.SolidColor;
import mx.managers.PopUpManager;

import spark.components.Group;
import spark.components.Label;
import spark.filters.DropShadowFilter;
import spark.primitives.Rect;

public class MobileAlert extends Group {
   private static const _UI_VALUE__ALPHA:Number = .7;
   private static const _UI_VALUE__BACKGROUND__COLOR:uint = 0;
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
   private static const _UI_VALUE__LABEL__INSET:uint = 35;
   private static const _UI_VALUE__LABEL__TEXT_COLOR:uint = 0xFFFFFF;

   private static var _instance:MobileAlert;
   private static var _isDisplayed:Boolean;

   private var _backgroundRect:Rect;
   private var _borderRect:Rect;
   private var _dropShadow:DropShadowFilter;
   private var _textLabel:Label;
   private var _textLabelGroup:Group;

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   //
   //          Getters / Setters
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   private var _autoCloseTimer:Timer;
   private var _text:String;
   private var _textChanged:Boolean;

   public function get text():String {
      return _text;
   }

   public function set text(value:String):void {
      if (value == _text)
         return;
      _text = value;
      _textChanged = true;
      invalidateProperties();
   }

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   //
   //          Public Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   public function MobileAlert(enforcer:SingletonEnforcer, alertText:String) {
      super();
      _text = alertText;
      alpha = _UI_VALUE__ALPHA;
      owner = DisplayObjectContainer(FlexGlobals.topLevelApplication);
      width = computeWidth();
      FlexGlobals.topLevelApplication.addEventListener(ResizeEvent.RESIZE, onAppResize);
      buildUI();
   }

   public static function close(delay:Number = 0):void {
      if (!(_instance))
         return;
      if (delay == 0)
         _instance.undisplay();
      else
         _instance.setAutoCloseInfo(true, delay);
   }

   public function setAutoCloseInfo(autoClose:Boolean, duration:Number):void {
      if (autoClose)
         startOrRestartAutoCloseTimer(duration);
      else
         stopAutoCloseTimer();
   }

   public static function open(alertText:String, autoClose:Boolean, duration:Number = 1000):void {
      if (!(_instance)) {
         _instance = new MobileAlert(new SingletonEnforcer(), alertText);
      }
      else {
         _instance.text = alertText;
      }
      _instance.setAutoCloseInfo(autoClose, duration);
      if (!_isDisplayed) {
         PopUpManager.addPopUp(_instance, _instance.owner);
         PopUpManager.centerPopUp(_instance);
         _isDisplayed = true;
      }
   }

   public function undisplay():void {
      PopUpManager.removePopUp(this);
      stopAutoCloseTimer();
      _isDisplayed = false;
   }

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   //
   //          Protected Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   override protected function commitProperties():void {
      super.commitProperties();
      if (_textChanged) {
         _textLabel.text = _text;
         _textChanged = false;
      }
   }

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   //
   //          Private Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   private function buildUI():void {
      _dropShadow = new DropShadowFilter(
            _UI_VALUE__DROP_SHADOW__DISTANCE,
            _UI_VALUE__DROP_SHADOW__ANGLE,
            _UI_VALUE__DROP_SHADOW__COLOR,
            _UI_VALUE__DROP_SHADOW__ALPHA,
            _UI_VALUE__DROP_SHADOW__BLUR_OFFSET,
            _UI_VALUE__DROP_SHADOW__BLUR_OFFSET);
      filters = [_dropShadow];
      //addElement(_dropShadow);
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
      _textLabelGroup = new Group();
      _textLabelGroup.top = _UI_VALUE__LABEL__INSET;
      _textLabelGroup.bottom = _UI_VALUE__LABEL__INSET;
      _textLabelGroup.left = _UI_VALUE__LABEL__INSET;
      _textLabelGroup.right = _UI_VALUE__LABEL__INSET;
      addElement(_textLabelGroup);
      _textLabel = new Label();
      _textLabel.percentWidth = 100;
      _textLabel.setStyle("textAlign", "center");
      _textLabel.setStyle("color", _UI_VALUE__LABEL__TEXT_COLOR);
      _textLabel.text = _text;
      _textLabelGroup.addElement(_textLabel);
   }

   private function computeWidth():uint {
      var smallerDimension:uint = Math.abs(Math.min(
            DisplayObjectContainer(FlexGlobals.topLevelApplication).height,
            DisplayObjectContainer(FlexGlobals.topLevelApplication).width));
      var result:uint = Math.round(smallerDimension * .6);
      return result;
   }

   private function onAppResize(event:ResizeEvent):void {
      if (MobileAlert._isDisplayed)
         PopUpManager.centerPopUp(this);
   }

   private function onAutoCloseTimer(event:TimerEvent):void {
      stopAutoCloseTimer();
      undisplay();
   }

   private function startOrRestartAutoCloseTimer(duration:Number):void {
      stopAutoCloseTimer();
      if (!(_autoCloseTimer))
         _autoCloseTimer = new Timer(duration, 1);
      else
         _autoCloseTimer.delay = duration;
      _autoCloseTimer.addEventListener(TimerEvent.TIMER, onAutoCloseTimer);
      _autoCloseTimer.start();
   }

   private function stopAutoCloseTimer():void {
      if (!(_autoCloseTimer))
         return;
      _autoCloseTimer.stop();
      _autoCloseTimer.removeEventListener(TimerEvent.TIMER, onAutoCloseTimer);

   }

}
}

class SingletonEnforcer {
}

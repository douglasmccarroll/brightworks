package com.brightworks.component.text {
import com.brightworks.util.Utils_Text;

import flash.text.AntiAliasType;
import flash.text.GridFitType;

import mx.core.UIComponent;
import mx.events.FlexEvent;

import spark.components.supportClasses.StyleableTextField;
import spark.core.SpriteVisualElement;

public class MobileText extends UIComponent {
   protected var spriteVisualElement:SpriteVisualElement;
   protected var textField:StyleableTextField;

   private var _isDisposed:Boolean;

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
   //
   //          Getters & Setters
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

   private var _fontFamily:String;
   private var _fontFamilyChanged:Boolean;

   public function set fontFamily(value:String):void {
      _fontFamily = value;
      _fontFamilyChanged = true;
   }

   private var _fontSize:int;
   private var _fontSizeChanged:Boolean;

   public function set fontSize(value:int):void {
      _fontSize = value;
      _fontSizeChanged = true;
   }

   private var _fontWeight:String;
   private var _fontWeightChanged:Boolean;

   public function set fontWeight(value:String):void {
      _fontWeight = value;
      _fontWeightChanged = true;
   }

   private var _leading:int;
   private var _leadingChanged:Boolean;

   public function set leading(value:int):void {
      _leading = value;
      _leadingChanged = true;
   }

   private var _text:String;
   private var _textChanged:Boolean;

   public function get text():String {
      return _text;
   }

   public function set text(value:String):void {
      _text = value;
      _textChanged = true;
      invalidateProperties();
   }

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
   //
   //          Public Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

   public function MobileText() {
      super();
      spriteVisualElement = new SpriteVisualElement();
      spriteVisualElement.alpha = 0;
      addChild(spriteVisualElement);
      textField = new StyleableTextField();
      doInitTextField();
      // StyleableTextField breaks if the next 2 lines aren't here
      // Also, if you move the next four lines into doInitTextField(), things break. Which doesn't seem to make sense...
      textField.setStyle("fontAntiAliasType", AntiAliasType.NORMAL);
      textField.setStyle("fontGridFitType", GridFitType.PIXEL);
      textField.selectable = false;
      textField.editable = false;
      textField.commitStyles();
      addChild(textField);
      addEventListener(FlexEvent.PREINITIALIZE, onPreinitialize);
   }

   public function dispose():void {
      if (_isDisposed)
         return;
      _isDisposed = true;
      spriteVisualElement = null;
      textField = null;
   }

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
   //
   //          Protected Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

   override protected function commitProperties():void {
      super.commitProperties();
      doCommitProperties();
   }

   protected function doCommitProperties():void {
      if (_fontFamilyChanged) {
         textField.setStyle("fontFamily", _fontFamily);
         textField.commitStyles();
         _fontFamilyChanged = false;
         invalidateDisplayList();
      }
      if (_fontSizeChanged) {
         textField.setStyle("fontSize", _fontSize);
         textField.commitStyles();
         _fontSizeChanged = false;
         invalidateDisplayList();
      }
      if (_fontWeightChanged) {
         textField.setStyle("fontWeight", _fontWeight);
         textField.commitStyles();
         _fontWeightChanged = false;
         invalidateDisplayList();
      }
      if (_leadingChanged) {
         textField.setStyle("leading", _leading);
         textField.commitStyles();
         _leadingChanged = false;
         invalidateDisplayList();
      }
      if (_textChanged) {
         textField.text = _text;
         _textChanged = false;
         invalidateDisplayList();
      }
   }

   protected function doInitTextField():void {
      textField.multiline = true;
      textField.wordWrap = true;
      textField.setStyle("fontFamily", "lucidaunicode");
   }

   override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
      super.updateDisplayList(unscaledWidth, unscaledHeight);
      spriteVisualElement.graphics.clear();
   }

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
   //
   //          Private Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

   private function onPreinitialize(event:FlexEvent):void {
      doCommitProperties();
   }

}
}

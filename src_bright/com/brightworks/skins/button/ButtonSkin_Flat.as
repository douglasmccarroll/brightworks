package com.brightworks.skins.button {

/*

  dmccarroll 20170711
  This class was created by modifying spark.skins.android4.ButtonSkin, which was created by modifying some other skin, I think.
  It calls the background graphic "BorderSkin". This should probably be changed.

*/

import com.brightworks.util.Log;
import com.brightworks.util.Utils_Graphic;
import com.brightworks.util.Utils_Text;

import flash.display.DisplayObject;

import mx.core.DPIClassification;
import mx.core.UIComponent;
import mx.core.mx_internal;
import mx.events.FlexEvent;

import com.brightworks.skins.button.ButtonSkin_Flat_fxg_disabled;
import com.brightworks.skins.button.ButtonSkin_Flat_fxg_down;
import com.brightworks.skins.button.ButtonSkin_Flat_fxg_up;

import spark.components.supportClasses.StyleableTextField;
import spark.skins.mobile.supportClasses.ButtonSkinBase;

use namespace mx_internal;

public class ButtonSkin_Flat extends ButtonSkinBase {
   mx_internal static const CHROME_COLOR_RATIOS:Array = [0, 127.5];
   mx_internal static const CHROME_COLOR_ALPHAS:Array = [1, 1];

   mx_internal var fillColorStyleName:String = "chromeColor";

   public var labelDisplayShadow:StyleableTextField;
   private var _border:DisplayObject;
   private var _borderClass:Class;
   private var _changeFXGSkin:Boolean = false;
   private var _disabledBorderSkin:Class;
   private var _downBorderSkin:Class;
   private var _layoutCornerEllipseSize:uint;
   private var _upBorderSkin:Class;

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   //
   //     Getters / Setters
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   protected function get border():DisplayObject {
      return _border;
   }

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   //
   //     Public Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   public function ButtonSkin_Flat() {
      super();
      Utils_Graphic.addDropShadow(this, Utils_Text.getStandardFontSize() / 6, .4);
      _disabledBorderSkin = ButtonSkin_Flat_fxg_disabled;
      _downBorderSkin = ButtonSkin_Flat_fxg_down;
      _upBorderSkin = ButtonSkin_Flat_fxg_up;
      _layoutCornerEllipseSize = 0;
      switch (applicationDPI) {
         case DPIClassification.DPI_640: {
            layoutGap = 20;
            layoutPaddingLeft = 40;
            layoutPaddingRight = 40;
            layoutPaddingTop = 40;
            layoutPaddingBottom = 40;
            layoutBorderSize = 2;
            measuredDefaultWidth = 128;
            measuredDefaultHeight = 172;
            break;
         }
         case DPIClassification.DPI_480: {
            layoutGap = 14;
            layoutPaddingLeft = 30;
            layoutPaddingRight = 30;
            layoutPaddingTop = 30;
            layoutPaddingBottom = 30;
            layoutBorderSize = 2;
            measuredDefaultWidth = 96;
            measuredDefaultHeight = 130;
            break;
         }
         case DPIClassification.DPI_320: {
            layoutGap = 10;
            layoutPaddingLeft = 20;
            layoutPaddingRight = 20;
            layoutPaddingTop = 20;
            layoutPaddingBottom = 20;
            layoutBorderSize = 2;
            measuredDefaultWidth = 64;
            measuredDefaultHeight = 86;
            break;
         }
         case DPIClassification.DPI_240: {
            layoutGap = 7;
            layoutPaddingLeft = 15;
            layoutPaddingRight = 15;
            layoutPaddingTop = 15;
            layoutPaddingBottom = 15;
            layoutBorderSize = 1;
            measuredDefaultWidth = 48;
            measuredDefaultHeight = 65;
            break;
         }
         case DPIClassification.DPI_120: {
            layoutGap = 4;
            layoutPaddingLeft = 8;
            layoutPaddingRight = 8;
            layoutPaddingTop = 8;
            layoutPaddingBottom = 8;
            layoutBorderSize = 1;
            measuredDefaultWidth = 24;
            measuredDefaultHeight = 33;
            break;
         }
         default: {
            layoutGap = 5;
            layoutPaddingLeft = 10;
            layoutPaddingRight = 10;
            layoutPaddingTop = 10;
            layoutPaddingBottom = 10;
            layoutBorderSize = 1;
            measuredDefaultWidth = 32;
            measuredDefaultHeight = 43;
            break;
         }
      }
   }

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   //
   //     Protected Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   override protected function commitCurrentState():void {
      super.commitCurrentState();
      _borderClass = getBorderClassForCurrentState();
      if (!(_border is _borderClass))
         _changeFXGSkin = true;
      invalidateDisplayList();
   }

   override protected function createChildren():void {
      super.createChildren();
      if (!labelDisplayShadow && labelDisplay) {
         labelDisplayShadow = StyleableTextField(createInFontContext(StyleableTextField));
         labelDisplayShadow.styleName = this;
         labelDisplayShadow.colorName = "textShadowColor";
         labelDisplayShadow.alpha = 1;
         labelDisplayShadow.useTightTextBounds = false;

         // add shadow before display
         addChildAt(labelDisplayShadow, getChildIndex(labelDisplay));
      }
      setStyle("textAlign", "center");
      setStyle("color", 0xcbcbef);
   }

   override protected function commitDisabled():void {
      // ButtonSkinBase.commitDisabled() sets our alpha
      // Instead, we're changing our skin FXG (which is handled in getBorderClassForCurrentState() )
   }

   override protected function drawBackground(unscaledWidth:Number, unscaledHeight:Number):void {
      super.drawBackground(unscaledWidth, unscaledHeight);
      var chromeColor:uint = getStyle(fillColorStyleName);
      applyColorTransform(this.border, 0xFFFFFF, chromeColor);
   }

   override protected function labelDisplay_valueCommitHandler(event:FlexEvent):void {
      super.labelDisplay_valueCommitHandler(event);
      labelDisplayShadow.text = labelDisplay.text;
   }

   override protected function layoutContents(unscaledWidth:Number, unscaledHeight:Number):void {
      super.layoutContents(unscaledWidth, unscaledHeight);
      // size the FXG background
      if (_changeFXGSkin) {
         _changeFXGSkin = false;
         if (_border) {
            removeChild(_border);
            _border = null;
         }
         if (_borderClass) {
            _border = new _borderClass();
            addChildAt(_border, 0);
         }
      }
      layoutBorder(unscaledWidth, unscaledHeight);
      // update label shadow
      labelDisplayShadow.alpha = .85;
      labelDisplayShadow.commitStyles();
      // don't use tightText positioning on shadow
      setElementPosition(labelDisplayShadow, labelDisplay.x + 1, labelDisplay.y + 1);
      setElementSize(labelDisplayShadow, labelDisplay.width, labelDisplay.height);
      // if labelDisplay is truncated, then push it down here as well.
      // otherwise, it would have gotten pushed in the labelDisplay_valueCommitHandler()
      if (labelDisplay.isTruncated)
         labelDisplayShadow.text = labelDisplay.text;
   }

   //--------------------------------------------------------------------------
   //
   //  mx_internal Methods
   //
   //--------------------------------------------------------------------------

   // Position the background of the skin. Override this function to re-position the background.
   mx_internal function layoutBorder(unscaledWidth:Number, unscaledHeight:Number):void {
      setElementSize(border, unscaledWidth, unscaledHeight);
      setElementPosition(border, 0, 0);
   }

   //--------------------------------------------------------------------------
   //
   //  Private Methods
   //
   //--------------------------------------------------------------------------

   private function getBorderClassForCurrentState():Class {
      if (UIComponent(owner).enabled) {
         switch (currentState) {
            case "down":
               return _downBorderSkin;
            case "downAndSelected":
               return _downBorderSkin;
            case "up":
               return _upBorderSkin;
            case "upAndSelected":
               return _downBorderSkin;
            default:
               Log.warn("ButtonSkin_Flat.getBorderClassForCurrentState(): No case for current state: " + currentState);
               return _upBorderSkin;
         }
      } else {
         return _disabledBorderSkin;
      }
   }



}
}
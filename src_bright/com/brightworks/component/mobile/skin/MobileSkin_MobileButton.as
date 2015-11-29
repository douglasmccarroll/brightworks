package com.brightworks.component.mobile.skin {
   import com.brightworks.util.Log;

   import flash.display.DisplayObject;
   import flash.display.GradientType;

   import mx.core.DPIClassification;
   import mx.core.UIComponent;
   import mx.core.mx_internal;
   import mx.styles.CSSStyleDeclaration;
   import mx.utils.ColorUtil;

   import spark.components.Group;
   import spark.components.IconPlacement;
   import spark.components.Label;
   import spark.components.ResizeMode;
   import spark.components.supportClasses.ButtonBase;
   import spark.components.supportClasses.StyleableTextField;
   import spark.primitives.BitmapImage;
   import spark.skins.mobile.supportClasses.MobileSkin;

   use namespace mx_internal;

   public class MobileSkin_MobileButton extends MobileSkin {
      private static const _FILL_COLOR_ALPHAS:Array = [1, 1];
      private static const _FILL_COLOR_RATIOS:Array = [0, 110];
      private static const _FILL_COLOR_STYLE_NAME:String = "colorFill";
      private static const _LABEL_SHADOW_ALPHA:Number = .4;
      private static const _LABEL_SHADOW_COLOR:Number = 0x0000;

      public var labelDisplay:Label;
      public var labelDisplayShadow:Label;

      protected var layoutBorderSize:uint;
      protected var layoutCornerEllipseSize:uint;
      protected var layoutGap:int;
      protected var layoutPaddingBottom:int;
      protected var layoutPaddingLeft:int;
      protected var layoutPaddingRight:int;
      protected var layoutPaddingTop:int;
      protected var useCenterAlignment:Boolean = true; // If true, then the labelDisplay and iconDisplay are centered.
      protected var useIconStyle:Boolean = true;

      private var _changeFXGSkin:Boolean = false;
      private var _color_fill:Number;
      private var _drawBackgroundCallCount:uint = 0;
      private var _enabledChanged:Boolean = false;
      private var _hostComponent:ButtonBase;
      private var _icon:Object; // The currently set icon, can be Class, DisplayObject, URL
      private var _iconChanged:Boolean = false;
      private var _iconHolder:Group; // Needed when iconInstance is a BitmapImage
      private var _iconInstance:Object; // Can be either DisplayObject or BitmapImage
      private var _styleName:String = ".mobileButton";

      // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      //
      //          Getters & Setters
      //
      // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

      override public function set currentState(value:String):void {
         var isDisabled:Boolean = currentState && currentState.indexOf("disabled") >= 0;

         super.currentState = value;

         if (isDisabled != currentState.indexOf("disabled") >= 0) {
            _enabledChanged = true;
            invalidateProperties();
         }
      }

      public function get hostComponent():ButtonBase {
         return _hostComponent;
      }

      public function set hostComponent(value:ButtonBase):void {
         _hostComponent = value;
      }

      // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      //
      //          Public Methods
      //
      // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

      public function MobileSkin_MobileButton() {
         super();
         switch (applicationDPI) {
            case DPIClassification.DPI_320:  {
               layoutGap = 10;
               layoutCornerEllipseSize = 20;
               layoutPaddingLeft = 20;
               layoutPaddingRight = 20;
               layoutPaddingTop = 20;
               layoutPaddingBottom = 20;
               layoutBorderSize = 2;
               measuredDefaultWidth = 64;
               measuredDefaultHeight = 86;
               break;
            }
            case DPIClassification.DPI_240:  {
               layoutGap = 7;
               layoutCornerEllipseSize = 15;
               layoutPaddingLeft = 15;
               layoutPaddingRight = 15;
               layoutPaddingTop = 15;
               layoutPaddingBottom = 15;
               layoutBorderSize = 1;
               measuredDefaultWidth = 48;
               measuredDefaultHeight = 65;
               break;
            }
            default:  {
               // default DPI_160
               layoutGap = 5;
               layoutCornerEllipseSize = 10;
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

      override public function styleChanged(styleProp:String):void {
         var allStyles:Boolean = !styleProp || styleProp == "styleName";

         if (allStyles || styleProp == "iconPlacement") {
            invalidateSize();
            invalidateDisplayList();
         }

         if (useIconStyle && (allStyles || styleProp == "icon")) {
            _iconChanged = true;
            invalidateProperties();
         }

         if (styleProp == "textShadowAlpha") {
            invalidateDisplayList();
         }

         super.styleChanged(styleProp);
      }

      // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      //
      //          Protected Methods
      //
      // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

      override protected function commitCurrentState():void {
         super.commitCurrentState();
         drawBackgroundRect();
      }

      // Commit alpha values for the skin when in a disabled state.
      protected function commitDisabled():void {
         alpha = hostComponent.enabled ? 1 : 0.4;
      }

      override protected function commitProperties():void {
         super.commitProperties();
         if (useIconStyle && _iconChanged) {
            // force enabled update when icon changes
            _enabledChanged = true;
            _iconChanged = false;
            setIcon(getStyle("icon"));
         }
         if (_enabledChanged) {
            commitDisabled();
            _enabledChanged = false;
         }
      }

      override protected function createChildren():void {
         super.createChildren();
         if (UIComponent(_hostComponent).styleName is String)
            _styleName = String(UIComponent(_hostComponent).styleName);
         var styleDec:CSSStyleDeclaration = CSSStyleDeclaration(styleManager.getStyleDeclaration(_styleName));
         if (!styleDec) {
            Log.error("MobileSkin_MobileButton.createChildren(): No CSS for styleName of '" + _styleName + "'");
            return;
         }
         _color_fill = styleDec.getStyle(_FILL_COLOR_STYLE_NAME);
         labelDisplayShadow = Label(createInFontContext(Label));
         labelDisplayShadow.setStyle("color", _LABEL_SHADOW_COLOR);
         addChild(labelDisplayShadow);
         labelDisplay = Label(createInFontContext(Label));
         labelDisplay.setStyle("fontFamily", "_sans");
         addChild(labelDisplay);
      }

      override protected function drawBackground(unscaledWidth:Number, unscaledHeight:Number):void {
         super.drawBackground(unscaledWidth, unscaledHeight);
         // Calling drawBackgroundRect() on the first call to this method does nothing, i.e. the
         // background rect doesn't get perceptibly drawn. Calling it more than once is unneccesary.
         // So, call it only on the second call to this method.
         // Also, strangely, if you change the next line to "if (_drawBackgroundCallCount == 1)", it breaks things (?!)
         if (!_drawBackgroundCallCount != 1) {
            drawBackgroundRect();
         }
         _drawBackgroundCallCount++;
      }

      //  Returns the current skin part that displays the icon.
      //  If the icon is a Class, then the iconDisplay is an instance of that class.
      //  If the icon is a DisplayObject instance, then the iconDisplay is that instance.
      //  If the icon is URL, then iconDisplay is the Group that holds the BitmapImage with that URL.
      protected function getIconDisplay():DisplayObject {
         return _iconHolder ? _iconHolder : _iconInstance as DisplayObject;
      }

      override protected function layoutContents(unscaledWidth:Number, unscaledHeight:Number):void {
         super.layoutContents(unscaledWidth, unscaledHeight);
         var hasLabel:Boolean = (hostComponent && hostComponent.label != "");
         var labelX:Number = 0;
         var labelY:Number = 0;
         var labelWidth:Number = 0;
         var labelHeight:Number = 0;
         var textWidth:Number = 0;
         var textHeight:Number = 0;
         var textDescent:Number = 0;
         var iconPlacement:String = getStyle("iconPlacement");
         var isHorizontal:Boolean = (iconPlacement == IconPlacement.LEFT || iconPlacement == IconPlacement.RIGHT);
         var iconX:Number = 0;
         var iconY:Number = 0;
         var unscaledIconWidth:Number = 0;
         var unscaledIconHeight:Number = 0;
         // vertical gap grows when text descent > gap
         var adjustableGap:Number = 0;
         // reset text if it was truncated before.
         if (hostComponent && labelDisplay.isTruncated)
            labelDisplay.text = hostComponent.label;
         if (hasLabel) {
            textWidth = getElementPreferredWidth(labelDisplay);
            textHeight = getElementPreferredHeight(labelDisplay);
         }
         var iconDisplay:DisplayObject = getIconDisplay();
         if (iconDisplay) {
            unscaledIconWidth = getElementPreferredWidth(iconDisplay);
            unscaledIconHeight = getElementPreferredHeight(iconDisplay);
            adjustableGap = (hasLabel) ? layoutGap : 0;
         }
         // compute padding bottom based on descent and text position
         var viewWidth:Number = Math.max(unscaledWidth - layoutPaddingLeft - layoutPaddingRight, 0);
         var viewHeight:Number = Math.max(unscaledHeight - layoutPaddingTop - layoutPaddingBottom, 0);
         var iconViewWidth:Number = Math.min(unscaledIconWidth, viewWidth);
         var iconViewHeight:Number = Math.min(unscaledIconHeight, viewHeight);
         // snap label to left and right bounds
         labelWidth = viewWidth;
         // default label vertical positioning is ascent centered
         labelHeight = Math.min(viewHeight, textHeight);
         labelY = (viewHeight - labelHeight) / 2;
         if (isHorizontal) {
            // label width constrained by icon width
            labelWidth = Math.max(Math.min(viewWidth - iconViewWidth - adjustableGap, textWidth), 0);
            if (useCenterAlignment)
               labelX = (viewWidth - labelWidth - iconViewWidth - adjustableGap) / 2;
            else
               labelX = 0;
            if (iconPlacement == IconPlacement.LEFT) {
               iconX = labelX;
               labelX += iconViewWidth + adjustableGap;
            } else {
               iconX  = labelX + labelWidth + adjustableGap;
            }
            iconY = (viewHeight - iconViewHeight) / 2;
         } else if (iconViewHeight) {
            // icon takes precedence over label
            labelHeight = Math.min(Math.max(viewHeight - iconViewHeight - adjustableGap, 0), textHeight);
            // adjust gap for descent when text is above icon
            if (hasLabel && (iconPlacement == IconPlacement.BOTTOM))
               adjustableGap = Math.max(adjustableGap, textDescent);
            if (useCenterAlignment) {
               // labelWidth already set to viewWidth with textAlign=center
               labelX = 0;
               // y-position for vertical center of both icon and label
               labelY = (viewHeight - labelHeight - iconViewHeight - adjustableGap) / 2;
            } else {
               // label horizontal center with textAlign=left
               labelWidth = Math.min(textWidth, viewWidth);
               labelX = (viewWidth - labelWidth) / 2;
            }
            // horizontally center iconWidth
            iconX = (viewWidth - iconViewWidth) / 2;
            var availableIconHeight:Number = viewHeight - labelHeight - adjustableGap;
            if (iconPlacement == IconPlacement.TOP) {
               if (useCenterAlignment) {
                  iconY = labelY;
                  labelY = iconY + adjustableGap + iconViewHeight;
               } else {
                  if (unscaledIconHeight >= availableIconHeight) {
                     // constraint to top
                     iconY = 0;
                  } else {
                     // center icon in available height (above label) including gap
                     // remove padding top since we offset again later
                     iconY = ((availableIconHeight + layoutPaddingTop + adjustableGap - unscaledIconHeight) / 2) - layoutPaddingTop;
                  }
                  labelY = viewHeight - labelHeight;
               }
            } else // IconPlacement.BOTTOM
            {
               if (useCenterAlignment) {
                  iconY = labelY + labelHeight + adjustableGap;
               } else {
                  if (unscaledIconHeight >= availableIconHeight) {
                     // constraint to bottom
                     iconY = viewHeight - iconViewHeight;
                  } else {
                     // center icon in available height (below label) including gap
                     iconY = ((availableIconHeight + layoutPaddingBottom + adjustableGap - unscaledIconHeight) / 2) + labelHeight;
                  }

                  labelY = 0;
               }
            }
         }
         // adjust labelHeight for vertical clipping at the bottom edge
         if (isHorizontal && (labelHeight < textHeight)) {
            // allow gutter to be outside skin bounds
            // this appears as clipping by the bottom border
            var labelViewHeight:Number = Math.min(unscaledHeight - layoutPaddingTop - labelY 
               - textDescent + (StyleableTextField.TEXT_HEIGHT_PADDING / 2), textHeight);
            labelHeight = Math.max(labelViewHeight, labelHeight);
         }
         labelX = Math.max(0, Math.round(labelX)) + layoutPaddingLeft;
         // text looks better a little high as opposed to low, so we use floor instead of round
         labelY = Math.max(0, Math.floor(labelY)) + layoutPaddingTop;
         iconX = Math.max(0, Math.round(iconX)) + layoutPaddingLeft;
         iconY = Math.max(0, Math.round(iconY)) + layoutPaddingTop;
         setElementSize(labelDisplay, labelWidth, labelHeight);


         // dmccarroll 20120324
         // This is a kludge fix that works in my specific case, i.e. no icons, etc.  It 
         // may not work in other cases. The logic in this method is complex, and I don't want
         // to invest the time right now to figure all this out when I may never use icons etc.
         //
         // This fix may be caused by the fact that, since I changed labelDiplay from a
         // StyleableTextField to a Label, we can no longer do this...
         //       textDescent = labelDisplay.getLineMetrics(0).descent;
         // ... but, actually, I don't think so. IIRC, textDescent was only used to ensure that the bottom 
         // padding was at least as high as the text descent.
         labelY += 2;

         setElementPosition(labelDisplay, labelX, labelY);
         if (iconDisplay) {
            setElementSize(iconDisplay, iconViewWidth, iconViewHeight);
            setElementPosition(iconDisplay, iconX, iconY);
         }
         // size the FXG background
         if (_changeFXGSkin) {
            _changeFXGSkin = false;
         }
         // update label shadow
         labelDisplayShadow.alpha = _LABEL_SHADOW_ALPHA;
         // don't use tightText positioning on shadow
         setElementPosition(labelDisplayShadow, labelDisplay.x - 1, labelDisplay.y - 1);
         setElementSize(labelDisplayShadow, labelDisplay.width, labelDisplay.height);
         labelDisplayShadow.text = labelDisplay.text;
      }

      override protected function measure():void {
         super.measure();
         var labelWidth:Number = 0;
         var labelHeight:Number = 0;
         var iconDisplay:DisplayObject = getIconDisplay();
         // reset text if it was truncated before.
         if (hostComponent && labelDisplay.isTruncated)
            labelDisplay.text = hostComponent.label;
         // we want to get the label's width and height if we have text or there's
         // no icon present
         if (labelDisplay.text != "" || !iconDisplay) {
            labelWidth = getElementPreferredWidth(labelDisplay);
            labelHeight = getElementPreferredHeight(labelDisplay);
         }
         var w:Number = layoutPaddingLeft + layoutPaddingRight;
         var h:Number = 0;
         var iconWidth:Number = 0;
         var iconHeight:Number = 0;
         if (iconDisplay) {
            iconWidth = getElementPreferredWidth(iconDisplay);
            iconHeight = getElementPreferredHeight(iconDisplay);
         }
         var iconPlacement:String = getStyle("iconPlacement");
         if (iconPlacement == IconPlacement.LEFT ||
            iconPlacement == IconPlacement.RIGHT) {
            w += labelWidth + iconWidth;
            if (labelWidth && iconWidth)
               w += layoutGap;
            var viewHeight:Number = Math.max(labelHeight, iconHeight);
            h += viewHeight;
         } else {
            w += Math.max(labelWidth, iconWidth);
            h += labelHeight + iconHeight;
            if (labelHeight && iconHeight) {
               h += layoutGap;
            }
         }
         h += layoutPaddingTop + layoutPaddingBottom;
         // measuredMinHeight for width and height for a square measured minimum size
         measuredMinWidth = h;
         measuredMinHeight = h;
         measuredWidth = w
         measuredHeight = h;
      }

      //  Sets the current icon for the iconDisplay skin part.
      //  The iconDisplay skin part is created/set-up on demand.
      protected function setIcon(icon:Object):void {
         if (_icon == icon)
            return;
         _icon = icon;
         // Clean-up the _iconInstance
         if (_iconInstance) {
            if (_iconHolder)
               _iconHolder.removeAllElements();
            else
               this.removeChild(_iconInstance as DisplayObject);
         }
         _iconInstance = null;
         // Set-up the iconHolder
         var needsHolder:Boolean = icon && !(icon is Class) && !(icon is DisplayObject);
         if (needsHolder && !_iconHolder) {
            // layoutContents() will set icon size no larger than it's unscaled size
            // icon will only scale down when limited by button size
            _iconHolder = new Group();
            _iconHolder.resizeMode = ResizeMode.SCALE;
            addChild(_iconHolder);
         } else if (!needsHolder && _iconHolder) {
            this.removeChild(_iconHolder);
            _iconHolder = null;
         }
         // Set-up the icon
         if (icon) {
            if (needsHolder) {
               _iconInstance = new BitmapImage();
               _iconInstance.source = icon;
               _iconHolder.addElementAt(_iconInstance as BitmapImage, 0);
            } else {
               if (icon is Class)
                  _iconInstance = new (Class(icon))();
               else
                  _iconInstance = icon;

               addChild(_iconInstance as DisplayObject);
            }
         }
         // explicitly invalidate, since addChild/removeChild don't invalidate for us
         invalidateSize();
         invalidateDisplayList();
      }

      // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      //
      //          Private Methods
      //
      // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

      private function drawBackgroundRect():void {
         super.drawBackground(unscaledWidth, unscaledHeight);
         var fillColors:Array = [];
         var lineColor:Number;
         switch (currentState) {
            case "down":
            case "downAndSelected":  {
               fillColors.push(ColorUtil.adjustBrightness2(_color_fill, 25));
               fillColors.push(ColorUtil.adjustBrightness2(_color_fill, -40));
               lineColor = 0xDDDDDD;
               break;
            }
            case "up":
            case "upAndSelected":  {
               fillColors.push(ColorUtil.adjustBrightness2(_color_fill, 25));
               fillColors.push(ColorUtil.adjustBrightness2(_color_fill, -40));
               lineColor = 0x888888;
               break;
            }
            case "disabled":  {
               fillColors.push(ColorUtil.adjustBrightness2(_color_fill, 25));
               fillColors.push(ColorUtil.adjustBrightness2(_color_fill, -40));
               lineColor = 0xDDDDDD;
               break;
            }
            default:  {
               Log.error("MobileSkin_MobileButton.drawBackground(): No case for current state of '" + currentState + "' - using default");
               fillColors.push(ColorUtil.adjustBrightness2(_color_fill, 60));
               lineColor = 0xDDDDDD;
               fillColors.push(_color_fill);
            }
         }
         colorMatrix.createGradientBox(unscaledWidth, unscaledHeight, Math.PI / 2, 0, 0);
         graphics.clear();
         graphics.beginGradientFill(GradientType.LINEAR, fillColors, _FILL_COLOR_ALPHAS, _FILL_COLOR_RATIOS, colorMatrix);
         graphics.lineStyle(1, lineColor, .5, true);
         graphics.drawRoundRect(layoutBorderSize, layoutBorderSize, 
            unscaledWidth - (layoutBorderSize * 2), 
            unscaledHeight - (layoutBorderSize * 2), 
            layoutCornerEllipseSize, layoutCornerEllipseSize);
         graphics.endFill();
      }

   }
}

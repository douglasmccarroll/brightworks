package com.brightworks.util {
import flash.display.Sprite;
import flash.filters.BitmapFilterQuality;
import flash.filters.BitmapFilterType;
import flash.geom.ColorTransform;

import spark.filters.BevelFilter;

public class Utils_Graphic {
   public function Utils_Graphic() {
   }

   public static function drawBevelledSurface(sprite:Sprite, color:uint, brightnessMultiplier:Number, cornerRadius:uint, bevelDistance:uint):void {
      sprite.graphics.clear();
      sprite.graphics.lineStyle(1, color, 1, true);
      sprite.graphics.beginFill(color);
      sprite.graphics.drawRoundRect(0, 0, sprite.width, sprite.height, cornerRadius, cornerRadius);
      sprite.graphics.endFill();
      sprite.filters = [createBevelFilter(bevelDistance)];
      sprite.transform.colorTransform = new ColorTransform(
            brightnessMultiplier,
            brightnessMultiplier,
            brightnessMultiplier);
   }

   private static function createBevelFilter(distance:uint):BevelFilter {
      var angleInDegrees:Number = 45;
      var highlightColor:Number = 0xFFFFFF; // Utils_Color.modifyColorBrightness(computeButtonFillColor(), .5);
      var highlightAlpha:Number = .2;
      var shadowColor:Number    = 0x000000; // Utils_Color.modifyColorBrightness(computeButtonFillColor(), -.5);
      var shadowAlpha:Number    = .2;
      var blurX:Number          = 0;
      var blurY:Number          = 0;
      var strength:Number       = 1;
      var quality:Number        = BitmapFilterQuality.MEDIUM;
      var type:String           = BitmapFilterType.INNER;
      var knockout:Boolean      = false;
      return new BevelFilter(
            distance,
            angleInDegrees,
            highlightColor,
            highlightAlpha,
            shadowColor,
            shadowAlpha,
            blurX,
            blurY,
            strength,
            quality,
            type,
            knockout);
   }


}
}

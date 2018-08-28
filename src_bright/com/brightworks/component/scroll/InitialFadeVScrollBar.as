/*
Author: Steven Shongrunden
URL: http://flexponential.com/2011/07/30/controlling-scroll-bar-visibility-in-a-mobile-scroller/
*/
package com.brightworks.component.scroll {
import flash.events.Event;
import flash.events.TimerEvent;
import flash.utils.Timer;

import mx.events.EffectEvent;

import spark.components.VScrollBar;
import spark.effects.Animate;
import spark.effects.animation.MotionPath;
import spark.effects.animation.SimpleMotionPath;

/**
 * A subclass of VScrollBar for use in a Scroller with interactionMode="touch"
 * where the scrollbar will be shown at startup and then fade away after a
 * short period of time.
 */
public class InitialFadeVScrollBar extends VScrollBar {
   private var initialFadeTimer:Timer;
   private var initialFadeAnimation:Animate;

   // force the scroll bars to stay visible
   private var keepScrollBars:Boolean;

   public function InitialFadeVScrollBar() {
      // show the scrollbar at initial startup
      keepScrollBars = true;

      // setup a timer to fade away the scrollbars after initial startup
      initialFadeTimer = new Timer(500);
      initialFadeTimer.addEventListener(TimerEvent.TIMER, handleInitialFadeOut);
      initialFadeTimer.start();
   }

   private function handleInitialFadeOut(e:Event):void {
      initialFadeTimer.stop();
      initialFadeTimer.removeEventListener(TimerEvent.TIMER, handleInitialFadeOut);

      // no longer force the scrollbars to be visible
      keepScrollBars = false;

      // animate the scrollbars away
      initialFadeAnimation = new Animate();
      var motionPaths:Vector.<MotionPath> = Vector.<MotionPath>([new SimpleMotionPath("alpha", 1, 0.1)]);
      initialFadeAnimation.motionPaths = motionPaths;
      initialFadeAnimation.duration = 1000;
      initialFadeAnimation.addEventListener(EffectEvent.EFFECT_END, handleEffectEnd);
      initialFadeAnimation.play([this]);

      // TODO: Still bugs when you scroll during the initial timer
   }

   private function handleEffectEnd(e:Event):void {
      // remove event listener
      initialFadeAnimation.removeEventListener(EffectEvent.EFFECT_END, handleEffectEnd);

      // now that we're faded out we'll go back to the normal state ScrollerLayout is expecting
      this.alpha = 0;
      this.visible = false;
      this.includeInLayout = false;
      this.scaleX = 0;
      this.scaleY = 0;
   }

   override public function set alpha(value:Number):void {
      if (!keepScrollBars)
         super.alpha = value;
   }

   override public function set visible(value:Boolean):void {
      if (!keepScrollBars)
         super.visible = value;
   }

   override public function set includeInLayout(value:Boolean):void {
      if (!keepScrollBars)
         super.includeInLayout = value;
   }

   override public function set scaleX(value:Number):void {
      if (!keepScrollBars)
         super.scaleX = value;
   }

   override public function set scaleY(value:Number):void {
      if (!keepScrollBars)
         super.scaleY = value;
   }

}
}

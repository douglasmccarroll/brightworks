/*
Copyright 2020 Brightworks, Inc.

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
package com.brightworks.component.core {
// This class is a modified version of code written by Nahuel Foronda for this article:
// http://www.asfusion.com/blog/entry/mobile-itemrenderer-in-actionscript-part-4

import flash.events.Event;
import flash.utils.Dictionary;

import mx.core.IChildList;
import mx.core.IRawChildrenContainer;
import mx.core.IUITextField;
import mx.styles.*;
import mx.utils.NameUtil;

import spark.core.SpriteVisualElement;

// IStyleClient:
//    "describes the properties and methods that an object must implement so that it can fully
//     participate in the style subsystem. This interface is implemented by UIComponent."
//     Properties:
//         className : String - [read-only] The name of the component class.
//         inheritingStyles : Object - An object containing the inheritable styles for this component.
//         nonInheritingStyles : Object - An object containing the noninheritable styles for this component.
//         styleDeclaration : CSSStyleDeclaration - The style declaration that holds the inline styles declared by this object.
//         styleName : Object - The source of this object's style values.
//     Methods:
//         clearStyle(styleProp:String):void - Deletes a style property from this component instance.
//         getClassStyleDeclarations():Array - Returns an Array of CSSStyleDeclaration objects for the type selector that applies to this component, or null if none exist.
//         getStyle(styleProp:String):* - Gets a style property that has been set anywhere in this component's style lookup chain.
//         notifyStyleChangeInChildren(styleProp:String, recursive:Boolean):void - Propagates style changes to the children of this component.
//         regenerateStyleCache(recursive:Boolean):void - Sets up the internal style cache values so that the getStyle() method functions.
//         registerEffects(effects:Array):void - Registers the EffectManager as one of the event listeners for each effect event.
//         setStyle(styleProp:String, newValue:*):void - Sets a style property on this component instance.
//         styleChanged(styleProp:String):void - Called when the value of a style property is changed.
//
// IAdvancedStyleClient:
//    "describes the advanced properties that a component must implement to fully participate in the advanced style subsystem.
//     Properties:
//         id : String - [read-only] The identity of the component.
//         styleParent : IAdvancedStyleClient - The parent of this IAdvancedStyleClient..
//     Methods:
//         matchesCSSState(cssState:String):Boolean - Returns true if cssState matches currentCSSState.
//         matchesCSSType(cssType:String):Boolean - Determines whether this instance is the same as, or is a subclass of, the given type.
//         stylesInitialized():void - Flex calls the stylesInitialized() method when the styles for a component are first initialized.

public class StyleClientSpriteVisualElement extends SpriteVisualElement implements IStyleClient, IChildList, IAdvancedStyleClient {
   protected var layoutWidth:Number;
   protected var layoutHeight:Number;
   protected var measuredWidth:Number;
   protected var measuredHeight:Number;
   protected var explicitWidth:Number;
   protected var explicitHeight:Number;
   protected var creationComplete:Boolean;
   protected var declarations:Dictionary = new Dictionary();
   protected var stateDeclaraion:CSSStyleDeclaration;

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   //
   //          Getters & Setters
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   public function get className():String {
      return NameUtil.getUnqualifiedClassName(this);
   }

   /**
    *  The state to be used when matching CSS pseudo-selectors. By default
    *  this is the currentState.
    */
   private var _currentCSSState:String;

   public function get currentCSSState():String {
      return _currentCSSState;
   }

   public function set currentCSSState(value:String):void {
      _currentCSSState = value;

      setStateDeclaration();
   }

   private var _inheritingStyles:Object = StyleProtoChain.STYLE_UNINITIALIZED;

   [Inspectable(environment="none")]

   /**
    *  The beginning of this component's chain of inheriting styles.
    *  The <code>getStyle()</code> method simply accesses
    *  <code>inheritingStyles[styleName]</code> to search the entire
    *  prototype-linked chain.
    *  This object is set up by <code>initProtoChain()</code>.
    *  Developers typically never need to access this property directly.
    */
   public function get inheritingStyles():Object {
      return _inheritingStyles;
   }

   public function set inheritingStyles(value:Object):void {
      _inheritingStyles = value;
   }

   private var _nonInheritingStyles:Object = StyleProtoChain.STYLE_UNINITIALIZED;

   [Inspectable(environment="none")]

   /**
    *  The beginning of this component's chain of non-inheriting styles.
    *  The <code>getStyle()</code> method simply accesses
    *  <code>nonInheritingStyles[styleName]</code> to search the entire
    *  prototype-linked chain.
    *  This object is set up by <code>initProtoChain()</code>.
    *  Developers typically never need to access this property directly.
    */
   public function get nonInheritingStyles():Object {
      return _nonInheritingStyles;
   }

   public function set nonInheritingStyles(value:Object):void {
      _nonInheritingStyles = value;
   }

   private var _styleDeclaration:CSSStyleDeclaration;

   public function get styleDeclaration():CSSStyleDeclaration {
      return _styleDeclaration;
   }

   public function set styleDeclaration(value:CSSStyleDeclaration):void {
      _styleDeclaration = value
   }

   public function get styleManager():IStyleManager2 {
      return StyleManager.getStyleManager(moduleFactory);
   }

   private var _styleName:Object

   public function get styleName():Object {
      return _styleName;
   }

   public function set styleName(value:Object):void {
      _styleName = value;
      if (creationComplete)
         StyleProtoChain.initProtoChain(this);
   }

   private var _styleParent:IAdvancedStyleClient

   // Don't assign this property directly. It is set by the DisplayObjectConainer's
   // addChild(), addChildAt(), removeChild(), and removeChildAt() methods.
   public function get styleParent():IAdvancedStyleClient {
      return parent as IAdvancedStyleClient;
      ;
   }

   public function set styleParent(value:IAdvancedStyleClient):void {
      _styleParent = value;
   }

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   //
   //          Public Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   public function clearStyle(styleProp:String):void {
      setStyle(styleProp, undefined);
   }

   public function getClassStyleDeclarations():Array {
      return StyleProtoChain.getClassStyleDeclarations(this);
   }

   override public function getLayoutBoundsHeight(postLayoutTransform:Boolean = true):Number {
      return (layoutHeight) ? layoutHeight : super.getLayoutBoundsHeight(postLayoutTransform);
   }

   override public function getLayoutBoundsWidth(postLayoutTransform:Boolean = true):Number {
      return (layoutWidth) ? layoutWidth : super.getLayoutBoundsWidth(postLayoutTransform);
   }

   override public function getPreferredBoundsHeight(postLayoutTransform:Boolean = true):Number {
      return (measuredHeight) ? measuredHeight : super.getPreferredBoundsHeight(postLayoutTransform);
   }

   override public function getPreferredBoundsWidth(postLayoutTransform:Boolean = true):Number {
      return (measuredWidth) ? measuredWidth : super.getPreferredBoundsWidth(postLayoutTransform);
   }

   public function getStyle(styleProp:String):* {
      return styleManager.inheritingStyles[styleProp] ? _inheritingStyles[styleProp] : _nonInheritingStyles[styleProp];
   }

   public function hasCSSState():Boolean {
      return false;
   }

   public function matchesCSSState(cssState:String):Boolean {
      return currentCSSState == cssState;
   }

   public function matchesCSSType(cssType:String):Boolean {
      return StyleProtoChain.matchesCSSType(this, cssType);
   }

   public function notifyStyleChangeInChildren(styleProp:String, recursive:Boolean):void {
      var n:int = numChildren;
      for (var i:int = 0; i < n; i++) {
         var child:ISimpleStyleClient = getChildAt(i) as ISimpleStyleClient;

         if (child) {
            child.styleChanged(styleProp);

            // Always recursively call this function because of my
            // descendants might have a styleName property that points
            // to this object.  The recursive flag is respected in
            // Container.notifyStyleChangeInChildren.
            if (child is IStyleClient)
               IStyleClient(child).notifyStyleChangeInChildren(styleProp, recursive);
         }
      }
   }

   public function regenerateStyleCache(recursive:Boolean):void {
      StyleProtoChain.initProtoChain(this);
      stylesInitialized();

      var childList:IChildList = this is IRawChildrenContainer ? IRawChildrenContainer(this).rawChildren : IChildList(this);

      // Recursively call this method on each child.
      var n:int = childList.numChildren;

      for (var i:int = 0; i < n; i++) {
         var child:Object = childList.getChildAt(i);

         if (child is IStyleClient) {
            // Does this object already have a proto chain?
            // If not, there's no need to regenerate a new one.
            IStyleClient(child).regenerateStyleCache(recursive);

         }
         else if (child is IUITextField) {
            // Does this object already have a proto chain?
            // If not, there's no need to regenerate a new one.
            if (IUITextField(child).inheritingStyles)
               StyleProtoChain.initTextField(IUITextField(child));
         }
      }
   }

   public function registerEffects(effects:Array):void {
      // not implemented
   }

   override public function setLayoutBoundsSize(width:Number, height:Number, postLayoutTransform:Boolean = true):void {
      if (isNaN(width))
         width = getPreferredBoundsWidth(postLayoutTransform);

      if (isNaN(height))
         height = getPreferredBoundsHeight(postLayoutTransform);

      layoutWidth = width;
      layoutHeight = height;
      updateDisplayList(width, height);
   }

   public function setStyle(styleProp:String, newValue:*):void {
      StyleProtoChain.setStyle(this, styleProp, newValue);
   }

   public function styleChanged(styleProp:String):void {
      //StyleProtoChain.styleChanged(this, styleProp);

      if (styleProp && (styleProp != "styleName")) {
         if (hasEventListener(styleProp + "Changed"))
            dispatchEvent(new Event(styleProp + "Changed"));
      }
      else {
         if (hasEventListener("allStylesChanged"))
            dispatchEvent(new Event("allStylesChanged"));
      }
   }

   public function stylesInitialized():void {
      if (!creationComplete) {
         createChildren();
         creationComplete = true;
         measure()
      }
   }

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   //
   //          Protected Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   protected function setStateDeclaration():void {
      StyleProtoChain.initProtoChain(this);
   }

   protected function createChildren():void {

   }

   protected function invalidateDisplayList():void {
      if (layoutWidth && layoutHeight) {
         updateDisplayList(layoutWidth, layoutHeight);
      }
   }

   protected function measure():void {
      // To be implemented in sub classes
   }

   protected function updateDisplayList(width:Number, height:Number):void {
      // To be implemented in sub classes
   }

}
}

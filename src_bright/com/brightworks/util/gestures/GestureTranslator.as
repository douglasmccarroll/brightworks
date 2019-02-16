/*
Copyright 2018 Brightworks, Inc.

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
package com.brightworks.util.gestures {
import com.brightworks.interfaces.IDisposable;
import com.brightworks.util.Log;
import com.brightworks.util.Utils_DateTime;
import com.brightworks.util.Utils_Dispose;

public class GestureTranslator implements IDisposable {
   public static const GESTURE__ARROW_DOWN:String = "gesture_Arrow_Down";
   public static const GESTURE__ARROW_LEFT:String = "gesture_Arrow_Left";
   public static const GESTURE__ARROW_RIGHT:String = "gesture_Arrow_Right";
   public static const GESTURE__ARROW_UP:String = "gesture_Arrow_Up";
   public static const GESTURE__CIRCLE:String = "gesture_Circle";
   public static const GESTURE__NONE:String = "gesture_None";
   public static const GESTURE__SWIPE_DOWN:String = "gesture_SwipeDown";
   public static const GESTURE__SWIPE_DOWN_LEFT:String = "gesture_SwipeDownLeft";
   public static const GESTURE__SWIPE_DOWN_RIGHT:String = "gesture_SwipeDownRight";
   public static const GESTURE__SWIPE_LEFT:String = "gesture_SwipeLeft";
   public static const GESTURE__SWIPE_RIGHT:String = "gesture_SwipeRight";
   public static const GESTURE__SWIPE_UP:String = "gesture_SwipeUp";
   public static const GESTURE__SWIPE_UP_LEFT:String = "gesture_SwipeUpLeft";
   public static const GESTURE__SWIPE_UP_RIGHT:String = "gesture_SwipeUpRight";

   private static const TIME_LIMIT__MOUSE_MOVE_TRACKING:uint = 2000;

   private var _isDisposed:Boolean = false;
   private var _mostRecentNoteworthyLoc:LocInfo;
   private var _mouseDownLoc:LocInfo;
   private var _locExtremeInfos_Down:LocInfo;
   //private var _locExtremeInfos_DownRight:LocInfo;
   //private var _locExtremeInfos_DownLeft:LocInfo;
   private var _locExtremeInfos_Right:LocInfo;
   private var _locExtremeInfos_Left:LocInfo;
   private var _locExtremeInfos_Up:LocInfo;
   //private var _locExtremeInfos_UpLeft:LocInfo;
   //private var _locExtremeInfos_UpRight:LocInfo;
   private var _mouseUpLoc:LocInfo;
   private var _noteworthyLocList:Array = [];
   private var _screenDiagonalTenth:int = -1;
   private var _stageHeight:int = -1;
   private var _stageWidth:int = -1;

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
   //
   //          Public Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

   public function GestureTranslator(mouseStageX:int, mouseStageY:int, stageHeight:int, stageWidth:int) {
      var time:Number = Utils_DateTime.getCurrentMS_BasedOnDate();
      _mouseDownLoc = new LocInfo(mouseStageX, mouseStageY, time);
      _locExtremeInfos_Down = new LocInfo(mouseStageX, mouseStageY, time);
      //_locExtremeInfos_DownLeft = new LocInfo(mouseStageX, mouseStageY, time);
      //_locExtremeInfos_DownRight = new LocInfo(mouseStageX, mouseStageY, time);
      _locExtremeInfos_Left = new LocInfo(mouseStageX, mouseStageY, time);
      _locExtremeInfos_Right = new LocInfo(mouseStageX, mouseStageY, time);
      _locExtremeInfos_Up = new LocInfo(mouseStageX, mouseStageY, time);
      //_locExtremeInfos_UpLeft = new LocInfo(mouseStageX, mouseStageY, time);
      //_locExtremeInfos_UpRight = new LocInfo(mouseStageX, mouseStageY, time);
      _stageHeight = stageHeight;
      _stageWidth = stageWidth;
      addNoteworthyLoc(mouseStageX, mouseStageY);
      computeScreenDiagonalTenth();
   }

   public function dispose():void {
      if (_isDisposed)
         return;
      _isDisposed = true;
      _mostRecentNoteworthyLoc = null;
      _mouseDownLoc = null;
      _locExtremeInfos_Down = null;
      //_locExtremeInfos_DownRight = null;
      //_locExtremeInfos_DownLeft = null;
      _locExtremeInfos_Right = null;
      _locExtremeInfos_Left = null;
      _locExtremeInfos_Up = null;
      //_locExtremeInfos_UpLeft = null;
      //_locExtremeInfos_UpRight = null;
      _mouseUpLoc = null;
      if (_noteworthyLocList) {
         Utils_Dispose.disposeArray(_noteworthyLocList, true);
         _noteworthyLocList = null;
      }
   }

   public function isTimedOut():Boolean {
      var currTime:Number = Utils_DateTime.getCurrentMS_BasedOnDate();
      var elapsedTime:Number = currTime - _mouseDownLoc.time;
      var result:Boolean = (elapsedTime > TIME_LIMIT__MOUSE_MOVE_TRACKING);
      if (result)
         var ttt:int = 0;
      return result;
   }

   public function mouseMove(mouseStageX:int, mouseStageY:int):void {
      computeMinAndMaxMouseLocs(mouseStageX, mouseStageY)
      if (isNewLocNoteworthy(mouseStageX, mouseStageY))
         addNoteworthyLoc(mouseStageX, mouseStageY);
   }

   public function mouseUp(mouseStageX:int, mouseStageY:int):String {
      computeMinAndMaxMouseLocs(mouseStageX, mouseStageY)
      _mouseUpLoc = new LocInfo(mouseStageX, mouseStageY, Utils_DateTime.getCurrentMS_BasedOnDate());
      if (!didSignificantMouseMovementOccur())
         return GESTURE__NONE;
      addNoteworthyLoc(mouseStageX, mouseStageY);
      var result:String = computeGestureIfAny();
      return result;
   }

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
   //
   //          Private Methods
   //
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

   private function addNoteworthyLoc(mouseStageX:int, mouseStageY:int):void {
      var li:LocInfo = new LocInfo(mouseStageX, mouseStageY, Utils_DateTime.getCurrentMS_BasedOnDate());
      _mostRecentNoteworthyLoc = li;
      _noteworthyLocList.push(li);
   }

   private function computeDistance_MouseDownToMouseUp_InScreenDiagTenths():int {
      if (!_mouseUpLoc)
         Log.warn("GestureTranslator.computeDistance_MouseDownToMouseUp_InScreenDiagTenths(): Mouse up loc is null.");
      var distance:int = computeAbsoluteDistanceBetweenLocInfos(_mouseDownLoc, _mouseUpLoc);
      var result:int = Math.floor(distance / _screenDiagonalTenth);
      return result;
   }

   private function computeAbsoluteDistanceBetweenPoints(firstX:int, firstY:int, secondX:int, secondY:int):int {
      var horzDistance:int = Math.abs(firstX - secondX);
      var vertDistance:int = Math.abs(firstY - secondY);
      var valuesSquaredAndAdded:Number = (horzDistance * horzDistance) + (vertDistance * vertDistance);
      var distance:int = Math.round(Math.sqrt(valuesSquaredAndAdded));
      return distance;
   }

   private function computeAbsoluteDistanceBetweenLocInfos(firstLocInfo:LocInfo, secondLocInfo:LocInfo):int {
      return computeAbsoluteDistanceBetweenPoints(firstLocInfo.x, firstLocInfo.y, secondLocInfo.x, secondLocInfo.y);
   }

   private function computeGestureIfAny():String {
      if (isGesture_Circle())
         return GESTURE__CIRCLE;
      if (isGesture_Arrow_Down())
         return GESTURE__ARROW_DOWN;
      if (isGesture_Arrow_Left())
         return GESTURE__ARROW_LEFT;
      if (isGesture_Arrow_Right())
         return GESTURE__ARROW_RIGHT;
      if (isGesture_Arrow_Up())
         return GESTURE__ARROW_UP;
      if (isGesture_SwipeDown())
         return GESTURE__SWIPE_DOWN;
      if (isGesture_SwipeDownLeft())
         return GESTURE__SWIPE_DOWN_LEFT;
      if (isGesture_SwipeDownRight())
         return GESTURE__SWIPE_DOWN_RIGHT;
      if (isGesture_SwipeLeft())
         return GESTURE__SWIPE_LEFT;
      if (isGesture_SwipeRight())
         return GESTURE__SWIPE_RIGHT;
      if (isGesture_SwipeUp())
         return GESTURE__SWIPE_UP;
      if (isGesture_SwipeUpLeft())
         return GESTURE__SWIPE_UP_LEFT;
      if (isGesture_SwipeUpRight())
         return GESTURE__SWIPE_UP_RIGHT;
      return GESTURE__NONE;
   }

   private function computeMinAndMaxMouseLocs(mouseStageX:int, mouseStageY:int):void {

      var time:int = Utils_DateTime.getCurrentMS_BasedOnDate();
      if (mouseStageY > _locExtremeInfos_Down.y)
         _locExtremeInfos_Down.setInfo(mouseStageX, mouseStageY, time);
      if (mouseStageX < _locExtremeInfos_Left.x)
         _locExtremeInfos_Left.setInfo(mouseStageX, mouseStageY, time);
      if (mouseStageX > _locExtremeInfos_Right.x)
         _locExtremeInfos_Right.setInfo(mouseStageX, mouseStageY, time);
      if (mouseStageY < _locExtremeInfos_Up.y)
         _locExtremeInfos_Up.setInfo(mouseStageX, mouseStageY, time);

      // Note that the 'corner' extremes - UpRight etc. - require that the new loc have
      // values on *both* axes that take it closer to the corner of the screen. A more
      // precise way to do this would be to measure the distance between the new point
      // and the corner, and the distance for the 'previous closest to corner point', 
      // and use the closest point.
      //
      // On second thought, I've concluded that this won't be accurate enough. Also, I'm
      // finding that, so far at least, I don't need these locs.
      //
      /*
      if ((mouseStageY > _locExtremeInfos_DownLeft.y) && (mouseStageX < _locExtremeInfos_DownLeft.x))
          _locExtremeInfos_DownLeft.setInfo(mouseStageX, mouseStageY, time);
      if ((mouseStageY > _locExtremeInfos_DownRight.y) && (mouseStageX > _locExtremeInfos_DownRight.x))
          _locExtremeInfos_DownRight.setInfo(mouseStageX, mouseStageY, time);
      if ((mouseStageY < _locExtremeInfos_UpLeft.y) && (mouseStageX < _locExtremeInfos_UpLeft.x))
          _locExtremeInfos_UpLeft.setInfo(mouseStageX, mouseStageY, time);
      if ((mouseStageY < _locExtremeInfos_UpRight.y) && (mouseStageX > _locExtremeInfos_UpRight.x))
          _locExtremeInfos_UpRight.setInfo(mouseStageX, mouseStageY, time);
      */
   }

   private function computeDistance_Horz(firstLocInfo:LocInfo, secondLocInfo:LocInfo):int {
      return secondLocInfo.x - firstLocInfo.x;
   }

   private function computeDistance_Vert(firstLocInfo:LocInfo, secondLocInfo:LocInfo):int {
      return secondLocInfo.y - firstLocInfo.y;
   }

   private function computeScreenDiagonalTenth():void {
      var distance:int = computeAbsoluteDistanceBetweenPoints(0, 0, _stageWidth, _stageHeight);
      _screenDiagonalTenth = Math.round(distance / 10);
   }

   private function didSignificantMouseMovementOccur():Boolean {
      if (computeDistance_MouseDownToMouseUp_InScreenDiagTenths() <= 1)
         return false;
      return true;
   }

   private function isGesture_Arrow_Down():Boolean {
      var firstLegVertDistance:int = computeDistance_Vert(_mouseDownLoc, _locExtremeInfos_Down);
      if (firstLegVertDistance < (3 * _screenDiagonalTenth))
         return false;
      var secondLegVertDistance:int = computeDistance_Vert(_locExtremeInfos_Down, _mouseUpLoc);
      if (secondLegVertDistance > (-3 * _screenDiagonalTenth))
         return false;
      return true;
   }

   private function isGesture_Arrow_Left():Boolean {
      var firstLegHorzDistance:int = computeDistance_Horz(_mouseDownLoc, _locExtremeInfos_Left);
      if (firstLegHorzDistance > (-3 * _screenDiagonalTenth))
         return false;
      var secondLegHorzDistance:int = computeDistance_Horz(_locExtremeInfos_Left, _mouseUpLoc);
      if (secondLegHorzDistance < (3 * _screenDiagonalTenth))
         return false;
      return true;
   }

   private function isGesture_Arrow_Right():Boolean {
      var firstLegHorzDistance:int = computeDistance_Horz(_mouseDownLoc, _locExtremeInfos_Right);
      if (firstLegHorzDistance < (3 * _screenDiagonalTenth))
         return false;
      var secondLegHorzDistance:int = computeDistance_Horz(_locExtremeInfos_Right, _mouseUpLoc);
      if (secondLegHorzDistance > (-3 * _screenDiagonalTenth))
         return false;
      return true;
   }

   private function isGesture_Arrow_Up():Boolean {
      var firstLegVertDistance:int = computeDistance_Vert(_mouseDownLoc, _locExtremeInfos_Up);
      if (firstLegVertDistance > (-3 * _screenDiagonalTenth))
         return false;
      var secondLegVertDistance:int = computeDistance_Vert(_locExtremeInfos_Up, _mouseUpLoc);
      if (secondLegVertDistance < (3 * _screenDiagonalTenth))
         return false;
      return true;
   }

   private function isGesture_Circle():Boolean {
      var vertDistance:int = Math.abs(computeDistance_Vert(_locExtremeInfos_Down, _locExtremeInfos_Up));
      if (vertDistance < (3 * _screenDiagonalTenth))
         return false;
      var horzDistance:int = Math.abs(computeDistance_Horz(_locExtremeInfos_Right, _locExtremeInfos_Left));
      if (horzDistance < (3 * _screenDiagonalTenth))
         return false;
      // See if any loc in the last quarter of our gesture came close to the mouseDown loc;
      if (_noteworthyLocList.length < 4)
         return false;
      var bEndCameClose:Boolean = false;
      var numberOfLocsToCheck:int = Math.floor(_noteworthyLocList.length / 4);
      var firstIndexToCheck:int = (_noteworthyLocList.length - numberOfLocsToCheck) - 1;
      for (var i:int = firstIndexToCheck; i < _noteworthyLocList.length; i++) {
         var currLocInfo:LocInfo = _noteworthyLocList[i];
         var distance:int = computeAbsoluteDistanceBetweenLocInfos(currLocInfo, _mouseDownLoc);
         if (distance < _screenDiagonalTenth) {
            bEndCameClose = true;
            break;
         }
      }
      return bEndCameClose;
   }

   private function isGesture_SwipeDown():Boolean {
      if (!isGestureDistance_MouseDownToMouseUp_SwipeWorthy())
         return false;
      if (!isGestureRange_Horz_VerticalSwipeWorthy())
         return false;
      if (!isGestureRange_Vert_VerticalSwipeWorthy())
         return false;
      if (!isGestureDirection_Down())
         return false;
      return true;
   }

   private function isGesture_SwipeDownLeft():Boolean {
      if (!isGestureDistance_MouseDownToMouseUp_SwipeWorthy())
         return false;
      if (!isGestureRange_Horz_DiagonalSwipeWorthy())
         return false;
      if (!isGestureRange_Vert_DiagonalSwipeWorthy())
         return false;
      if (!isGestureDirection_Down())
         return false;
      if (!isGestureDirection_Left())
         return false;
      return true;
   }

   private function isGesture_SwipeDownRight():Boolean {
      if (!isGestureDistance_MouseDownToMouseUp_SwipeWorthy())
         return false;
      if (!isGestureRange_Horz_DiagonalSwipeWorthy())
         return false;
      if (!isGestureRange_Vert_DiagonalSwipeWorthy())
         return false;
      if (!isGestureDirection_Down())
         return false;
      if (!isGestureDirection_Right())
         return false;
      return true;
   }

   private function isGesture_SwipeLeft():Boolean {
      if (!isGestureDistance_MouseDownToMouseUp_SwipeWorthy())
         return false;
      if (!isGestureRange_Horz_HorizontalSwipeWorthy())
         return false;
      if (!isGestureRange_Vert_HorizontalSwipeWorthy())
         return false;
      if (!isGestureDirection_Left())
         return false;
      return true;
   }

   private function isGesture_SwipeRight():Boolean {
      if (!isGestureDistance_MouseDownToMouseUp_SwipeWorthy())
         return false;
      if (!isGestureRange_Horz_HorizontalSwipeWorthy())
         return false;
      if (!isGestureRange_Vert_HorizontalSwipeWorthy())
         return false;
      if (!isGestureDirection_Right())
         return false;
      return true;
   }

   private function isGesture_SwipeUp():Boolean {
      if (!isGestureDistance_MouseDownToMouseUp_SwipeWorthy())
         return false;
      if (!isGestureRange_Horz_VerticalSwipeWorthy())
         return false;
      if (!isGestureRange_Vert_VerticalSwipeWorthy())
         return false;
      if (!isGestureDirection_Up())
         return false;
      return true;
   }

   private function isGesture_SwipeUpLeft():Boolean {
      if (!isGestureDistance_MouseDownToMouseUp_SwipeWorthy())
         return false;
      if (!isGestureRange_Horz_DiagonalSwipeWorthy())
         return false;
      if (!isGestureRange_Vert_DiagonalSwipeWorthy())
         return false;
      if (!isGestureDirection_Up())
         return false;
      if (!isGestureDirection_Left())
         return false;
      return true;
   }

   private function isGesture_SwipeUpRight():Boolean {
      if (!isGestureDistance_MouseDownToMouseUp_SwipeWorthy())
         return false;
      if (!isGestureRange_Horz_DiagonalSwipeWorthy())
         return false;
      if (!isGestureRange_Vert_DiagonalSwipeWorthy())
         return false;
      if (!isGestureDirection_Up())
         return false;
      if (!isGestureDirection_Right())
         return false;
      return true;
   }

   private function isGestureDirection_Down():Boolean {
      return (_mouseDownLoc.y < _mouseUpLoc.y);
   }

   private function isGestureDirection_Left():Boolean {
      return (_mouseDownLoc.x > _mouseUpLoc.x);
   }

   private function isGestureDirection_Right():Boolean {
      return (_mouseDownLoc.x < _mouseUpLoc.x);
   }

   private function isGestureDirection_Up():Boolean {
      return (_mouseDownLoc.y > _mouseUpLoc.y);
   }

   private function isGestureDistance_MouseDownToMouseUp_SwipeWorthy():Boolean {
      var result:Boolean = (computeDistance_MouseDownToMouseUp_InScreenDiagTenths() > 3);
      return result;
   }

   private function isGestureRange_Horz_DiagonalSwipeWorthy():Boolean {
      var distance:int = Math.abs(_mouseDownLoc.x - _mouseUpLoc.x);
      var result:Boolean = (distance > (_screenDiagonalTenth * 3));
      return result;
   }

   private function isGestureRange_Horz_HorizontalSwipeWorthy():Boolean {
      var distance:int = Math.abs(_mouseDownLoc.x - _mouseUpLoc.x);
      var result:Boolean = (distance > (_screenDiagonalTenth * 3));
      return result;
   }

   private function isGestureRange_Horz_VerticalSwipeWorthy():Boolean {
      var distance:int = Math.abs(_mouseDownLoc.x - _mouseUpLoc.x);
      var result:Boolean = (distance < (_screenDiagonalTenth * 1));
      return result;
   }

   private function isGestureRange_Vert_DiagonalSwipeWorthy():Boolean {
      var distance:int = Math.abs(_mouseDownLoc.y - _mouseUpLoc.y);
      var result:Boolean = (distance > (_screenDiagonalTenth * 3));
      return result;
   }

   private function isGestureRange_Vert_HorizontalSwipeWorthy():Boolean {
      var distance:int = Math.abs(_mouseDownLoc.y - _mouseUpLoc.y);
      var result:Boolean = (distance < (_screenDiagonalTenth * 1));
      return result;
   }

   private function isGestureRange_Vert_VerticalSwipeWorthy():Boolean {
      var distance:int = Math.abs(_mouseDownLoc.y - _mouseUpLoc.y);
      var result:Boolean = (distance > (_screenDiagonalTenth * 3));
      return result;
   }

   private function isNewLocNoteworthy(mouseStageX:int, mouseStageY:int):Boolean {
      var distance:int = computeAbsoluteDistanceBetweenPoints(mouseStageX, mouseStageY, _mostRecentNoteworthyLoc.x, _mostRecentNoteworthyLoc.y);
      var result:Boolean = (distance > (_screenDiagonalTenth / 3));
      return result;
   }

}
}

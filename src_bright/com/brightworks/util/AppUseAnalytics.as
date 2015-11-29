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
package com.brightworks.util
{
    import com.brightworks.interfaces.IManagedSingleton;
    import com.brightworks.util.singleton.SingletonManager;
    import com.google.analytics.GATracker;
    import com.brightworks.constant.Constant_Private;

    import flash.events.Event;
    import flash.system.Capabilities;

    import mx.core.FlexGlobals;

    public class AppUseAnalytics implements IManagedSingleton
    {
        public static const CATEGORY__APP_STARTUP:String = "App Startup";
        public static const CATEGORY__LESSON_FINISHED:String = "Lesson Finished";
        public static const CATEGORY__LESSON_LEARNED:String = "Lesson Learned";

        public static var appInfoStringCreatorCallback:Function;

        private static var _instance:AppUseAnalytics;

        private var _isReady:Boolean;
        private var _tracker:GATracker;

        // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
        //
        //          Public Methods
        //
        // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

        // var b:Boolean = _tracker.trackEvent(category, action, label, value);
        // _tracker.trackPageview(s);

        public function AppUseAnalytics(manager:SingletonManager)
        {
            _instance = this;
            if (FlexGlobals.topLevelApplication.stage)
            {
                onAppAddedToStage();
            }
            else
            {
                FlexGlobals.topLevelApplication.addEventListener(Event.ADDED_TO_STAGE, onAppAddedToStage);
            }
        }

        public function appStartup(appInfo:String):void
        {
            trackEvent(CATEGORY__APP_STARTUP, appInfo);
        }

        public function initSingleton():void {
        }

        public function lessonFinished(lessonName:String, lessonVersion:String):void
        {
            trackEvent(CATEGORY__LESSON_FINISHED, lessonName + " " + lessonVersion);
        }

        public function lessonLearned(lessonName:String, lessonVersion:String):void
        {
            trackEvent(CATEGORY__LESSON_LEARNED, lessonName + " " + lessonVersion);
        }

        public static function getInstance():AppUseAnalytics
        {
            if (!(_instance))
                throw new Error("Singleton not initialized");
            return _instance;
        }

        // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        //
        //          Private Methods
        //
        // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

        private function trackEvent(category:String, info:String):void
        {
            if (!_tracker)
                return;
            var actionString:String = (appInfoStringCreatorCallback is Function) ? appInfoStringCreatorCallback() : "";
            actionString +=
                Capabilities.os +
                " " + 
                Capabilities.manufacturer;
            _tracker.trackEvent(category, actionString, info);
        /*var url:String =
            "/" +
            category +
            "/" +
            info +
            "/" +
            action;
        _tracker.trackPageview(url);*/
        }

        private function onAppAddedToStage(event:Event = null):void
        {
            _tracker = new GATracker(FlexGlobals.topLevelApplication.stage, Constant_Private.LANGMENTOR_GOOGLE_ANALYTICS_CODE, "AS3");
        }

    }
}

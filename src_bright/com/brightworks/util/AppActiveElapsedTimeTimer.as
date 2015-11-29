package com.brightworks.util
{
    import flash.events.Event;
    import flash.events.TimerEvent;
    import flash.utils.Timer;

    public class AppActiveElapsedTimeTimer extends Timer
    {
        private var _deactivatedModeRemainingTime:Number;
        private var _isDisposed:Boolean;
        private var _isActive:Boolean;
        private var _isStarted:Boolean;
        private var _startTime_CurrentActivation:Number;

        // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        //
        //          Public Methods
        //
        // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

        public function AppActiveElapsedTimeTimer(delay:Number)
        {
            // This class currently only supports single-event timers.
            super(delay, 1);
            addEventListener(Event.ACTIVATE, onActivate);
            addEventListener(Event.DEACTIVATE, onDeactivate);
            addEventListener(TimerEvent.TIMER, onTimer);
        }

        public function dispose():void
        {
            if (_isDisposed)
                return;
            _isDisposed = true;
            _isActive = false;
            _isStarted = false;
            super.stop();
            removeEventListener(Event.ACTIVATE, onActivate);
            removeEventListener(Event.DEACTIVATE, onDeactivate);
            removeEventListener(TimerEvent.TIMER, onTimer);
        }

        override public function start():void
        {
            super.start();
            _isStarted = true;
            _startTime_CurrentActivation = Utils_DateTime.getCurrentMS_BasedOnDate();
            _isActive = true;
        }

        override public function stop():void
        {
            dispose();
        }

        // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        //
        //          Private Methods
        //
        // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

        private function getRemainingTime():Number
        {
            if (!_isActive)
            {
                Log.error("AppActiveElapsedTimeTimer.getRemainingTime(): Called when timer not active");
                return 0;
            }
            var elapsedTime:Number = (Utils_DateTime.getCurrentMS_BasedOnDate() - _startTime_CurrentActivation);
            if (elapsedTime < 0)
            {
                Log.error("AppActiveElapsedTimeTimer.getRemainingTime(): Elapsed time is negative number");
                return 0;
            }
            var result:Number = delay - elapsedTime;
            if (result < 0)
            {
                // This can happen occasionally - especially when debugging
                return 0;
            }
            return result;
        }

        private function onActivate(event:Event):void
        {
            if (Utils_System.isRunningOnDesktop())
            {
                // See comment in onDeactivate()
                return;
            }
            if (!_isStarted)
                return;
            if (_isActive)
                return;
            _isActive = true;
            //if (!isNaN(_deactivatedModeRemainingTime))
            delay = _deactivatedModeRemainingTime;
            _deactivatedModeRemainingTime = 0;
            _startTime_CurrentActivation = Utils_DateTime.getCurrentMS_BasedOnDate();
            start();
        }

        private function onDeactivate(event:Event):void
        {
            if (Utils_System.isRunningOnDesktop())
            {
                // When running on desktop, a deactivate event indicates that the app's window has lost
                // focus, but the app continues to execute. So we haven't really deactivated.
                return;
            }
            if (!_isStarted)
                return;
            if (!_isActive)
                return;
            _deactivatedModeRemainingTime = getRemainingTime();
            _isActive = false;
            super.stop();
        }

        private function onTimer(event:TimerEvent):void
        {
            dispose();
        }

    }
}



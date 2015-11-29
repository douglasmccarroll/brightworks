package com.brightworks.interfaces
{

    public interface ILoggingConfigProvider
    {
        function getLogToServerMaxStringLength(level:uint):uint
        function getLogToServerURL(level:uint):String
        function isLoggingEnabled(level:uint):Boolean
        function isLogToServerEnabled(level:uint):Boolean
    }
}

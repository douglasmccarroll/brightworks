package com.brightworks.controller
{
    import com.brightworks.util.Utils_ArrayVectorEtc;

    public class CommandManager
    {
        private static var _commandList:Array = [];

        public function CommandManager()
        {
        }

        public static function addCommand(c:Command_Base):void
        {
            if (_commandList.indexOf(c) == -1)
                _commandList.push(c);
        }

        public static function removeCommand(c:Command_Base):void
        {
            if (_commandList.indexOf(c) != -1)
                Utils_ArrayVectorEtc.removeFirstInstanceOfInstanceFromArray(c, _commandList);
        }
    }
}

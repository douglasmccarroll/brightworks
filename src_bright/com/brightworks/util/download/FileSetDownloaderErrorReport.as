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
package com.brightworks.util.download
{
    import com.brightworks.techreport.ITechReport;
    import com.brightworks.techreport.TechReport;
    import com.brightworks.interfaces.IDisposable;
    import com.brightworks.util.Utils_Dispose;

    import flash.utils.Dictionary;

    public class FileSetDownloaderErrorReport extends TechReport implements ITechReport, IDisposable
    {
        public var bFileInfoNotPopulated:Boolean;
        public var index_fileId_to_fileDownloaderErrorReport:Dictionary;
        public var index_fileId_to_fileDownloaderStatus:Dictionary;

        private var _isDisposed:Boolean = false;

        public function FileSetDownloaderErrorReport()
        {
        }

        override public function dispose():void
        {
            super.dispose();
            if (_isDisposed)
                return;
            _isDisposed = true;
            Utils_Dispose.disposeDictionary(index_fileId_to_fileDownloaderErrorReport, true);
            index_fileId_to_fileDownloaderErrorReport = null;
        }
    }
}

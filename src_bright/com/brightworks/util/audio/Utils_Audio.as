/*
 *  Copyright 2021 Brightworks, Inc.
 *
 *  This file is part of Language Mentor.
 *
 *  Language Mentor is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  Language Mentor is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with Language Mentor.  If not, see <http://www.gnu.org/licenses/>.
 *
 */
package com.brightworks.util.audio {
import com.brightworks.util.*;
import com.langcollab.languagementor.util.Utils_LangCollab;

import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.media.Sound;
import flash.utils.ByteArray;
import flash.utils.Endian;

public class Utils_Audio {
   public static function computeAverageVolume(s:Sound):Number {
      var dataByteArray:ByteArray = new ByteArray();
      if (s.bytesLoaded != s.bytesTotal)
         Log.warn("Utils_Audio.computeAverageVolume(): s.bytesLoaded != s.bytesTotal");
      s.extract(dataByteArray, s.bytesLoaded, 0);
      var result:Number = Utils_ByteArray.getAverageAbsoluteValueFromByteArrayOfFloats(dataByteArray);
      dataByteArray.clear();
      return result;
   }

   public static function computeFractionOfSampleAtOrAboveVolume(sound:Sound, volume:Number):Number {
      var dataByteArray:ByteArray = new ByteArray();
      if (sound.bytesLoaded != sound.bytesTotal)
         Log.warn("Utils_Audio.computeFractionOfSampleAtOrAboveVolume(): sound.bytesLoaded != sound.bytesTotal");
      sound.extract(dataByteArray, sound.bytesLoaded, 0);
      var result:Number = Utils_ByteArray.getFractionOfAbsoluteValuesInByteArrayOfFloatsThatAreAtOrAboveNumber(dataByteArray, volume);
      dataByteArray.clear();
      return result;
   }

   public static function computeMaxVolume(s:Sound):Number {
      var dataByteArray:ByteArray = new ByteArray();
      if (s.bytesLoaded != s.bytesTotal)
         Log.warn("Utils_Audio.computeMaxVolume(): s.bytesLoaded != s.bytesTotal");
      s.extract(dataByteArray, s.bytesLoaded, 0);
      var result:Number = Utils_ByteArray.getHighestAbsoluteValueFromByteArrayOfFloats(dataByteArray);
      dataByteArray.clear();
      return result;
   }



}
}









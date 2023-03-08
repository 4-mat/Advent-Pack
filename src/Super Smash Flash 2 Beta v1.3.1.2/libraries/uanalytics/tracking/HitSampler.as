// Decompiled by AS3 Sorcerer 6.30
// www.as3sorcerer.com

//libraries.uanalytics.tracking.HitSampler

package libraries.uanalytics.tracking
{
    import libraries.uanalytics.utils.crc32;
    import flash.utils.ByteArray;
    import libraries.uanalytics.utils.isDigit;

    public class HitSampler 
    {


        private static function _hashString(source:String):Number
        {
            var crc:crc32 = new crc32();
            var bytes:ByteArray = new ByteArray();
            bytes.writeUTFBytes(source);
            crc.update(bytes);
            return (crc.valueOf());
        }

        private static function _parseNumber(str:String):Number
        {
            var i:uint;
            if (str == "")
            {
                return (NaN);
            };
            var l:uint = str.length;
            var dot:uint;
            i = 0;
            while (i < l)
            {
                if (((str.charAt(i) == ".") && (dot == 0)))
                {
                    dot++;
                }
                else
                {
                    if ((!(isDigit(str, i))))
                    {
                        return (NaN);
                    };
                };
                i++;
            };
            return (parseFloat(str));
        }

        public static function isSampled(model:HitModel, samplerate:String=""):Boolean
        {
            var sampleRate:Number = getSampleRate(samplerate);
            return ((sampleRate < 100) && ((_hashString(model.get(Tracker.CLIENT_ID)) % 10000) >= (100 * sampleRate)));
        }

        public static function getSampleRate(rate:String):Number
        {
            if (((rate == null) || (rate == "")))
            {
                return (100);
            };
            var result:Number = Math.max(0, Math.min(100, (Math.round((_parseNumber(rate) * 100)) / 100)));
            if (isNaN(result))
            {
                return (0);
            };
            return (result);
        }


    }
}//package libraries.uanalytics.tracking


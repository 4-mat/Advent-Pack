// Decompiled by AS3 Sorcerer 6.30
// www.as3sorcerer.com

//libraries.uanalytics.utils.crc32

package libraries.uanalytics.utils
{
    import __AS3__.vec.Vector;
    import flash.utils.Endian;
    import flash.utils.ByteArray;
    import __AS3__.vec.*;

    public final class crc32 
    {

        private static var lookup:Vector.<uint> = make_crc_table();
        private static var _poly:uint = 3988292384;
        private static var _init:uint = 0xFFFFFFFF;

        private var _crc:uint;
        private var _length:uint;
        private var _endian:String;

        public function crc32()
        {
            this._length = 0xFFFFFFFF;
            this._endian = Endian.LITTLE_ENDIAN;
            this.reset();
        }

        private static function make_crc_table():Vector.<uint>
        {
            var c:uint;
            var i:uint;
            var j:uint;
            var table:Vector.<uint> = new Vector.<uint>();
            i = 0;
            while (i < 0x0100)
            {
                c = i;
                j = 0;
                while (j < 8)
                {
                    if ((c & 0x01) != 0)
                    {
                        c = ((c >>> 1) ^ _poly);
                    }
                    else
                    {
                        c = (c >>> 1);
                    };
                    j++;
                };
                table[i] = c;
                i++;
            };
            return (table);
        }


        public function get endian():String
        {
            return (this._endian);
        }

        public function get length():uint
        {
            return (this._length);
        }

        public function update(bytes:ByteArray, offset:uint=0, length:uint=0):void
        {
            var i:uint;
            var c:uint;
            if (length == 0)
            {
                length = bytes.length;
            };
            bytes.position = offset;
            var crc:uint = (this._length & this._crc);
            i = offset;
            while (i < length)
            {
                c = uint(bytes[i]);
                crc = ((crc >>> 8) ^ lookup[((crc ^ c) & 0xFF)]);
                i++;
            };
            this._crc = (~(crc));
        }

        public function reset():void
        {
            this._crc = _init;
        }

        public function valueOf():uint
        {
            return (this._crc);
        }

        public function toString(radix:Number=16):String
        {
            return (this._crc.toString(radix));
        }


    }
}//package libraries.uanalytics.utils


// Decompiled by AS3 Sorcerer 6.30
// www.as3sorcerer.com

//libraries.uanalytics.utils.generateUUID

package libraries.uanalytics.utils
{
    import flash.utils.ByteArray;
    import flash.crypto.generateRandomBytes;

    public function generateUUID():String
    {
        var i:uint;
        var byte:uint;
        var randomBytes:ByteArray = generateRandomBytes(16);
        randomBytes[6] = (randomBytes[6] & 0x0F);
        randomBytes[6] = (randomBytes[6] | 0x40);
        randomBytes[8] = (randomBytes[8] & 0x3F);
        randomBytes[8] = (randomBytes[8] | 0x80);
        var toHex:Function = function (n:uint):String
        {
            var h:String = n.toString(16);
            h = ((h.length > 1) ? h : ("0" + h));
            return (h);
        };
        var str:String = "";
        var l:uint = randomBytes.length;
        randomBytes.position = 0;
        i = 0;
        while (i < l)
        {
            byte = randomBytes[i];
            str = (str + toHex(byte));
            i++;
        };
        var uuid:String = "";
        uuid = (uuid + str.substr(0, 8));
        uuid = (uuid + "-");
        uuid = (uuid + str.substr(8, 4));
        uuid = (uuid + "-");
        uuid = (uuid + str.substr(12, 4));
        uuid = (uuid + "-");
        uuid = (uuid + str.substr(16, 4));
        uuid = (uuid + "-");
        uuid = (uuid + str.substr(20, 12));
        return (uuid);
    }

}//package libraries.uanalytics.utils


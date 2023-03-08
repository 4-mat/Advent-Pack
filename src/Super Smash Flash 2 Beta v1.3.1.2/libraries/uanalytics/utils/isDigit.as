// Decompiled by AS3 Sorcerer 6.30
// www.as3sorcerer.com

//libraries.uanalytics.utils.isDigit

package libraries.uanalytics.utils
{
    public function isDigit(c:String, index:uint=0):Boolean
    {
        if (index > 0)
        {
            c = c.charAt(index);
        };
        return (("0" <= c) && (c <= "9"));
    }

}//package libraries.uanalytics.utils


// Decompiled by AS3 Sorcerer 6.30
// www.as3sorcerer.com

//libraries.uanalytics.utils.getHostname

package libraries.uanalytics.utils
{
    import flash.net.LocalConnection;

    public function getHostname():String
    {
        var lc:LocalConnection;
        var hostname:String = "";
        if (LocalConnection.isSupported)
        {
            lc = new LocalConnection();
            hostname = lc.domain;
        };
        if (((hostname.substr(0, 4) == "app#") || (hostname == "")))
        {
            hostname = "localhost";
        };
        return (hostname);
    }

}//package libraries.uanalytics.utils


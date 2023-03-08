// Decompiled by AS3 Sorcerer 6.30
// www.as3sorcerer.com

//libraries.uanalytics.tracking.AnalyticsTracker

package libraries.uanalytics.tracking
{
    import flash.utils.Dictionary;

    public interface AnalyticsTracker 
    {

        function get trackingId():String;
        function get clientId():String;
        function get config():Configuration;
        function send(_arg_1:String=null, _arg_2:Dictionary=null):Boolean;
        function pageview(_arg_1:String, _arg_2:String=""):Boolean;
        function screenview(_arg_1:String, _arg_2:Dictionary=null):Boolean;
        function event(_arg_1:String, _arg_2:String, _arg_3:String="", _arg_4:int=-1):Boolean;
        function transaction(_arg_1:String, _arg_2:String="", _arg_3:Number=0, _arg_4:Number=0, _arg_5:Number=0, _arg_6:String=""):Boolean;
        function item(_arg_1:String, _arg_2:String, _arg_3:Number=0, _arg_4:int=0, _arg_5:String="", _arg_6:String="", _arg_7:String=""):Boolean;
        function social(_arg_1:String, _arg_2:String, _arg_3:String):Boolean;
        function exception(_arg_1:String="", _arg_2:Boolean=true):Boolean;
        function timing(_arg_1:String, _arg_2:String, _arg_3:int, _arg_4:String="", _arg_5:Dictionary=null):Boolean;

    }
}//package libraries.uanalytics.tracking


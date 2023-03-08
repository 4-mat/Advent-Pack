// Decompiled by AS3 Sorcerer 6.30
// www.as3sorcerer.com

//libraries.uanalytics.tracker.HitType

package libraries.uanalytics.tracker
{
    import flash.utils.describeType;
    import flash.system.System;

    public class HitType 
    {

        public static const PAGEVIEW:String = "pageview";
        public static const SCREENVIEW:String = "screenview";
        public static const EVENT:String = "event";
        public static const TRANSACTION:String = "transaction";
        public static const ITEM:String = "item";
        public static const SOCIAL:String = "social";
        public static const EXCEPTION:String = "exception";
        public static const TIMING:String = "timing";


        public static function isValid(_arg_1:String):Boolean
        {
            var property:String;
            var member:XML;
            var _class:XML = describeType(HitType);
            var found:Boolean;
            for each (member in _class.constant)
            {
                property = String(member.@name);
                if (HitType[property] == _arg_1)
                {
                    found = true;
                    break;
                };
            };
            System.disposeXML(_class);
            if (found)
            {
                return (true);
            };
            return (false);
        }


    }
}//package libraries.uanalytics.tracker


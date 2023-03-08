// Decompiled by AS3 Sorcerer 6.30
// www.as3sorcerer.com

//com.mcleodgaming.ssf2.enums.SpecialMode

package com.mcleodgaming.ssf2.enums
{
    public class SpecialMode 
    {

        public static const MINI:uint = (1 << 0);
        public static const MEGA:uint = (1 << 1);
        public static const SLOW:uint = (1 << 2);
        public static const LIGHTNING:uint = (1 << 3);
        public static const VAMPIRE:uint = (1 << 4);
        public static const VENGEANCE:uint = (1 << 5);
        public static const FREEZE:uint = (1 << 6);
        public static const EGG:uint = (1 << 7);
        public static const DRAMATIC:uint = (1 << 8);
        public static const TURBO:uint = (1 << 9);
        public static const INVISIBLE:uint = (1 << 10);
        public static const METAL:uint = (1 << 11);
        public static const LIGHT:uint = (1 << 12);
        public static const HEAVY:uint = (1 << 13);
        public static const SSF1:uint = (1 << 14);
        private static var statesArr:Array;


        public static function init():void
        {
            trace("Initialized SpecialMode class");
        }

        public static function modeEnabled(modeVal:uint, modeToCheck:uint):Boolean
        {
            return (Boolean(((modeVal & modeToCheck) > 0)));
        }

        public static function setModeEnabled(modeVal:uint, modeToEnable:uint, status:Boolean):uint
        {
            return ((status) ? (modeVal | modeToEnable) : (modeVal & (~(modeToEnable))));
        }


    }
}//package com.mcleodgaming.ssf2.enums


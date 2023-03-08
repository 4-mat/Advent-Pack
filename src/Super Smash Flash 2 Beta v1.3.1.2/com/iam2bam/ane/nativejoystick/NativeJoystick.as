// Decompiled by AS3 Sorcerer 6.20
// www.as3sorcerer.com

//com.iam2bam.ane.nativejoystick.NativeJoystick

package com.iam2bam.ane.nativejoystick
{
    import com.iam2bam.ane.nativejoystick.intern.NativeJoystickData;
    import com.iam2bam.ane.nativejoystick.intern.NativeJoystickMgr;
    import com.iam2bam.ane.nativejoystick.intern.NativeJoystickCaps;

    public class NativeJoystick 
    {

        public static const AXIS_X:uint = 0;
        public static const AXIS_Y:uint = 1;
        public static const AXIS_Z:uint = 2;
        public static const AXIS_R:uint = 3;
        public static const AXIS_U:uint = 4;
        public static const AXIS_V:uint = 5;
        public static const AXIS_POVX:uint = 6;
        public static const AXIS_POVY:uint = 7;
        public static const AXIS_MAX:uint = 8;
        public static const AXIS_NAMES:Array = ["X", "Y", "Z", "R", "U", "V", "POVX", "POVY"];

        public var data:NativeJoystickData;

        public function NativeJoystick(_arg_1:uint)
        {
            data = manager.getData(_arg_1);
        }

        public static function get maxJoysticks():uint
        {
            return (manager.maxJoysticks);
        }

        public static function isPlugged(_arg_1:uint):Boolean
        {
            return (manager.isPlugged(_arg_1));
        }

        public static function get manager():NativeJoystickMgr
        {
            return (NativeJoystickMgr.instance());
        }


        public function get capabilities():NativeJoystickCaps
        {
            return (data.caps);
        }

        public function get index():uint
        {
            return (data.index);
        }

        public function get numButtons():int
        {
            return (data.caps.numButtons);
        }

        public function get plugged():Boolean
        {
            return (data.curr.plugged);
        }

        public function get justPlugged():Boolean
        {
            return ((data.curr.plugged) && (!(data.prev.plugged)));
        }

        public function get justUnplugged():Boolean
        {
            return ((!(data.curr.plugged)) && (data.prev.plugged));
        }

        public function pressed(_arg_1:int):Boolean
        {
            return (!((data.curr.buttons & (1 << _arg_1)) == 0));
        }

        public function justPressed(_arg_1:int):Boolean
        {
            return (!((data.buttonsJP & (1 << _arg_1)) == 0));
        }

        public function justReleased(_arg_1:int):Boolean
        {
            return (!((data.buttonsJR & (1 << _arg_1)) == 0));
        }

        public function anyPressed():Boolean
        {
            return (!(data.curr.buttons == 0));
        }

        public function anyJustPressed():Boolean
        {
            return (!(data.buttonsJP == 0));
        }

        public function anyJustReleased():Boolean
        {
            return (!(data.buttonsJR == 0));
        }

        public function axis(_arg_1:int):Number
        {
            return (data.curr.axes[_arg_1]);
        }

        public function axisDelta(_arg_1:int):Number
        {
            return (data.curr.axes[_arg_1] - data.prev.axes[_arg_1]);
        }

        public function hasAxis(_arg_1:int):Boolean
        {
            return (data.caps.hasAxis[_arg_1]);
        }

        public function get povAngle():Number
        {
            return (data.curr.povAngle);
        }

        public function get povPressed():Number
        {
            return (data.curr.povPressed);
        }

        public function get x():Number
        {
            return (axis(0));
        }

        public function get y():Number
        {
            return (axis(1));
        }

        public function get z():Number
        {
            return (axis(2));
        }

        public function get r():Number
        {
            return (axis(3));
        }

        public function get u():Number
        {
            return (axis(4));
        }

        public function get v():Number
        {
            return (axis(5));
        }

        public function get povX():Number
        {
            return (axis(6));
        }

        public function get povY():Number
        {
            return (axis(7));
        }


    }
}//package com.iam2bam.ane.nativejoystick


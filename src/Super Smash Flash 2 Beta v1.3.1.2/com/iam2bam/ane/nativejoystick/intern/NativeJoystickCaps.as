// Decompiled by AS3 Sorcerer 6.20
// www.as3sorcerer.com

//com.iam2bam.ane.nativejoystick.intern.NativeJoystickCaps

package com.iam2bam.ane.nativejoystick.intern
{
    import __AS3__.vec.Vector;
    import com.iam2bam.ane.nativejoystick.NativeJoystick;

    public class NativeJoystickCaps 
    {

        public var oemName:String;
        public var hasAxis:Vector.<Boolean>;
        public var axesRange:Vector.<uint>;
        public var hasPOV4Dir:Boolean;
        public var hasPOV4Cont:Boolean;
        public var numAxes:uint;
        public var numButtons:uint;
        public var miscProductName:String;
        public var miscProductID:uint;
        public var miscManufacturerID:uint;
        public var miscOSDriver:String;
        public var miscOSRegKey:String;

        public function NativeJoystickCaps()
        {
            var _local_1:int;
            super();
            hasAxis = new Vector.<Boolean>(8, true);
            axesRange = new Vector.<uint>(8, true);
            _local_1 = 0;
            while (_local_1 < 8)
            {
                axesRange[_local_1] = 1;
                hasAxis[_local_1] = false;
                _local_1++;
            };
        }

        public function get hasX():Boolean
        {
            return (hasAxis[0]);
        }

        public function get hasY():Boolean
        {
            return (hasAxis[1]);
        }

        public function get hasZ():Boolean
        {
            return (hasAxis[2]);
        }

        public function get hasR():Boolean
        {
            return (hasAxis[3]);
        }

        public function get hasU():Boolean
        {
            return (hasAxis[4]);
        }

        public function get hasV():Boolean
        {
            return (hasAxis[5]);
        }

        public function get hasPOV():Boolean
        {
            return ((hasPOV4Dir) || (hasPOV4Cont));
        }

        private function varToString(_arg_1:String):String
        {
            return (((((("\t" + _arg_1) + "=") + this[_arg_1]) + "/") + this[_arg_1].length) + "\n");
        }

        public function toString():String
        {
            var _local_2:int;
            var _local_1:String = "";
            _local_2 = 0;
            while (_local_2 < 8)
            {
                if (hasAxis[_local_2])
                {
                    _local_1 = (_local_1 + (((((("\t\tAxis #" + _local_2) + " ") + NativeJoystick.AXIS_NAMES[_local_2]) + " (0..") + axesRange[_local_2]) + ")\n"));
                };
                _local_2++;
            };
            return (((((((((((("[RadNativeJoystickCaps(\n" + varToString("oemName")) + varToString("hasPOV4Dir")) + varToString("hasPOV4Cont")) + varToString("numButtons")) + varToString("numAxes")) + _local_1) + varToString("miscProductName")) + varToString("miscProductID")) + varToString("miscManufacturerID")) + varToString("miscOSDriver")) + varToString("miscOSRegKey")) + "]");
        }


    }
}//package com.iam2bam.ane.nativejoystick.intern


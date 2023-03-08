// Decompiled by AS3 Sorcerer 6.20
// www.as3sorcerer.com

//com.iam2bam.ane.nativejoystick.intern.NativeJoystickState

package com.iam2bam.ane.nativejoystick.intern
{
    import __AS3__.vec.Vector;

    public class NativeJoystickState 
    {

        public var plugged:Boolean;
        public var axesRaw:Vector.<uint>;
        public var axes:Vector.<Number>;
        public var buttons:uint;
        public var povAngle:Number;
        public var povPressed:Number;

        public function NativeJoystickState():void
        {
            var _local_1:uint = 8;
            axesRaw = new Vector.<uint>(_local_1, true);
            axes = new Vector.<Number>(_local_1, true);
            reset(null, false);
        }

        public function reset(_arg_1:NativeJoystickCaps, _arg_2:Boolean):void
        {
            var _local_4:int;
            var _local_3:uint = 8;
            _local_4 = 0;
            while (_local_4 < _local_3)
            {
                axesRaw[_local_4] = ((_arg_1 == null) ? 0 : (_arg_1.axesRange[_local_4] / 2));
                axes[_local_4] = 0;
                _local_4++;
            };
            povAngle = 0;
            buttons = 0;
            plugged = _arg_2;
        }


    }
}//package com.iam2bam.ane.nativejoystick.intern


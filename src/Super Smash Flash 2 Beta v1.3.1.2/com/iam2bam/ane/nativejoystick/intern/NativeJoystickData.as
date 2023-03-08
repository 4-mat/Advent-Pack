// Decompiled by AS3 Sorcerer 6.20
// www.as3sorcerer.com

//com.iam2bam.ane.nativejoystick.intern.NativeJoystickData

package com.iam2bam.ane.nativejoystick.intern
{
    import com.iam2bam.ane.nativejoystick.NativeJoystick;

    public class NativeJoystickData 
    {

        public var curr:NativeJoystickState;
        public var prev:NativeJoystickState;
        public var caps:NativeJoystickCaps;
        public var index:uint;
        public var detected:Boolean;
        public var joystick:NativeJoystick;
        public var buttonsJP:uint;
        public var buttonsJR:uint;

        public function NativeJoystickData(_arg_1:uint)
        {
            index = _arg_1;
            curr = new NativeJoystickState();
            prev = new NativeJoystickState();
            caps = new NativeJoystickCaps();
        }

    }
}//package com.iam2bam.ane.nativejoystick.intern


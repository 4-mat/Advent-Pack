// Decompiled by AS3 Sorcerer 6.20
// www.as3sorcerer.com

//com.iam2bam.ane.nativejoystick.event.NativeJoystickEvent

package com.iam2bam.ane.nativejoystick.event
{
    import flash.events.Event;
    import com.iam2bam.ane.nativejoystick.NativeJoystick;

    public class NativeJoystickEvent extends Event 
    {

        public static const AXIS_MOVE:String = "NJOYAxisMove";
        public static const BUTTON_DOWN:String = "NJOYButtonDown";
        public static const BUTTON_UP:String = "NJOYButtonUp";
        public static const JOY_PLUGGED:String = "NJOYPlugged";
        public static const JOY_UNPLUGGED:String = "NJOYUnplugged";

        public var index:int = -1;
        public var joystick:NativeJoystick;
        public var axisIndex:int = -1;
        public var axisValue:Number = 0;
        public var axisDelta:Number = 0;
        public var buttonIndex:int = -1;

        public function NativeJoystickEvent(_arg_1:String, _arg_2:Boolean=false, _arg_3:Boolean=false)
        {
            super(_arg_1, _arg_2, _arg_3);
        }

    }
}//package com.iam2bam.ane.nativejoystick.event


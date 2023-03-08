// Decompiled by AS3 Sorcerer 6.30
// www.as3sorcerer.com

//com.mcleodgaming.ssf2.events.GamepadEvent

package com.mcleodgaming.ssf2.events
{
    import flash.events.Event;
    import com.mcleodgaming.ssf2.input.Gamepad;

    public class GamepadEvent extends Event 
    {

        public static var AXIS_CHANGED:String = "axisChanged";
        public static var BUTTON_DOWN:String = "buttonDown";
        public static var BUTTON_UP:String = "buttonUp";

        public var gamepad:Gamepad;
        public var controlState:Object;

        public function GamepadEvent(_arg_1:String, bubbles:Boolean=false, cancelable:Boolean=false)
        {
            super(_arg_1, bubbles, cancelable);
        }

    }
}//package com.mcleodgaming.ssf2.events


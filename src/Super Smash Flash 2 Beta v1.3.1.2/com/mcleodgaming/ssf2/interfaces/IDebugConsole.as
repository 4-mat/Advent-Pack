// Decompiled by AS3 Sorcerer 6.30
// www.as3sorcerer.com

//com.mcleodgaming.ssf2.interfaces.IDebugConsole

package com.mcleodgaming.ssf2.interfaces
{
    public interface IDebugConsole 
    {

        function get ControlsCapture():Boolean;
        function get OnlineCapture():Boolean;
        function get PingCapture():Boolean;
        function get AttackStateCapture():Boolean;
        function get KnockbackCapture():Boolean;
        function get Alerts():Boolean;
        function set Alerts(_arg_1:Boolean):void;
        function makeEvents():void;
        function show():void;
        function killEvents():void;
        function removeSelf():void;
        function forceShow():void;
        function alert(_arg_1:String):void;
        function writeEndAttackControls(_arg_1:String):void;
        function writeTextData(_arg_1:String):void;

    }
}//package com.mcleodgaming.ssf2.interfaces


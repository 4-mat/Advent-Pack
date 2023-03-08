// Decompiled by AS3 Sorcerer 6.30
// www.as3sorcerer.com

//com.mcleodgaming.mgn.net.IWebSocket

package com.mcleodgaming.mgn.net
{
    import flash.events.IEventDispatcher;
    import flash.utils.ByteArray;

    public interface IWebSocket extends IEventDispatcher 
    {

        function get url():String;
        function get connected():Boolean;
        function connect():void;
        function sendString(_arg_1:String):void;
        function sendBytes(_arg_1:ByteArray):void;
        function close():void;

    }
}//package com.mcleodgaming.mgn.net


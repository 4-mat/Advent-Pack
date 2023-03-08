// Decompiled by AS3 Sorcerer 6.30
// www.as3sorcerer.com

//com.mcleodgaming.mgn.net.IP2PSocket

package com.mcleodgaming.mgn.net
{
    import flash.events.IEventDispatcher;

    public interface IP2PSocket extends IEventDispatcher 
    {

        function get connected():Boolean;
        function getAckObj():Object;
        function connect():void;
        function sendToAll(_arg_1:Object):void;
        function close():void;

    }
}//package com.mcleodgaming.mgn.net


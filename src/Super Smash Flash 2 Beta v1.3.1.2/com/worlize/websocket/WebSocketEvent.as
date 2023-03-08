// Decompiled by AS3 Sorcerer 6.30
// www.as3sorcerer.com

//com.worlize.websocket.WebSocketEvent

package com.worlize.websocket
{
    import flash.events.Event;

    public class WebSocketEvent extends Event 
    {

        public static const OPEN:String = "open";
        public static const CLOSED:String = "closed";
        public static const MESSAGE:String = "message";
        public static const FRAME:String = "frame";
        public static const PING:String = "ping";
        public static const PONG:String = "pong";

        public var message:WebSocketMessage;
        public var frame:WebSocketFrame;

        public function WebSocketEvent(_arg_1:String, _arg_2:Boolean=false, _arg_3:Boolean=false)
        {
            super(_arg_1, _arg_2, _arg_3);
        }

    }
}//package com.worlize.websocket


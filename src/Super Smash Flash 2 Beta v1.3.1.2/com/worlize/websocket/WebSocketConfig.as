// Decompiled by AS3 Sorcerer 6.30
// www.as3sorcerer.com

//com.worlize.websocket.WebSocketConfig

package com.worlize.websocket
{
    public class WebSocketConfig 
    {

        public var maxReceivedFrameSize:uint = 0x100000;
        public var maxMessageSize:uint = 0x800000;
        public var fragmentOutgoingMessages:Boolean = true;
        public var fragmentationThreshold:uint = 0x4000;
        public var assembleFragments:Boolean = true;
        public var closeTimeout:uint = 5000;


    }
}//package com.worlize.websocket


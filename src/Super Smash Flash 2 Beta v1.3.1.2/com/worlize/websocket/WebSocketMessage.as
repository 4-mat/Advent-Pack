// Decompiled by AS3 Sorcerer 6.30
// www.as3sorcerer.com

//com.worlize.websocket.WebSocketMessage

package com.worlize.websocket
{
    import flash.utils.ByteArray;

    public class WebSocketMessage 
    {

        public static const TYPE_BINARY:String = "binary";
        public static const TYPE_UTF8:String = "utf8";

        public var type:String;
        public var utf8Data:String;
        public var binaryData:ByteArray;


    }
}//package com.worlize.websocket


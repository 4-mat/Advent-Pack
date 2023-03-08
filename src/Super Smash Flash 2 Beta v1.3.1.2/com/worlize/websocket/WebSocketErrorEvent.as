// Decompiled by AS3 Sorcerer 6.30
// www.as3sorcerer.com

//com.worlize.websocket.WebSocketErrorEvent

package com.worlize.websocket
{
    import flash.events.ErrorEvent;

    public class WebSocketErrorEvent extends ErrorEvent 
    {

        public static const CONNECTION_FAIL:String = "connectionFail";
        public static const ABNORMAL_CLOSE:String = "abnormalClose";

        public function WebSocketErrorEvent(_arg_1:String, _arg_2:Boolean=false, _arg_3:Boolean=false, _arg_4:String="")
        {
            super(_arg_1, _arg_2, _arg_3, _arg_4);
        }

    }
}//package com.worlize.websocket


// Decompiled by AS3 Sorcerer 6.30
// www.as3sorcerer.com

//com.worlize.websocket.WebSocket

package com.worlize.websocket
{
    import flash.events.EventDispatcher;
    import com.adobe.net.URI;
    import flash.net.Socket;
    import flash.utils.ByteArray;
    import __AS3__.vec.Vector;
    import flash.utils.Timer;
    import com.hurlant.crypto.tls.TLSConfig;
    import com.hurlant.crypto.tls.TLSSocket;
    import com.adobe.net.URIEncodingBitmap;
    import com.adobe.utils.StringUtil;
    import flash.events.TimerEvent;
    import com.hurlant.crypto.tls.TLSEngine;
    import com.hurlant.crypto.tls.TLSSecurityParameters;
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.SecurityErrorEvent;
    import flash.events.ProgressEvent;
    import com.hurlant.util.Base64;
    import flash.utils.Endian;
    import com.hurlant.crypto.hash.SHA1;
    import __AS3__.vec.*;

    [Event(name="connectionFail", type="com.worlize.websocket.WebSocketErrorEvent")]
    [Event(name="ioError", type="flash.events.IOErrorEvent")]
    [Event(name="abnormalClose", type="com.worlize.websocket.WebSocketErrorEvent")]
    [Event(name="message", type="com.worlize.websocket.WebSocketEvent")]
    [Event(name="frame", type="com.worlize.websocket.WebSocketEvent")]
    [Event(name="ping", type="com.worlize.websocket.WebSocketEvent")]
    [Event(name="pong", type="com.worlize.websocket.WebSocketEvent")]
    [Event(name="open", type="com.worlize.websocket.WebSocketEvent")]
    [Event(name="closed", type="com.worlize.websocket.WebSocketEvent")]
    public class WebSocket extends EventDispatcher 
    {

        private static const MODE_UTF8:int = 0;
        private static const MODE_BINARY:int = 0;
        private static const MAX_HANDSHAKE_BYTES:int = (10 * 0x0400);//0x2800
        public static var logger:Function = function (_arg_1:String):void
        {
        };

        private var _bufferedAmount:int = 0;
        private var _readyState:int;
        private var _uri:URI;
        private var _protocols:Array;
        private var _serverProtocol:String;
        private var _host:String;
        private var _port:uint;
        private var _resource:String;
        private var _secure:Boolean;
        private var _origin:String;
        private var _useNullMask:Boolean = false;
        private var rawSocket:Socket;
        private var socket:Socket;
        private var timeout:uint;
        private var fatalError:Boolean = false;
        private var nonce:ByteArray;
        private var base64nonce:String;
        private var serverHandshakeResponse:String;
        private var serverExtensions:Array;
        private var currentFrame:WebSocketFrame;
        private var frameQueue:Vector.<WebSocketFrame>;
        private var fragmentationOpcode:int = 0;
        private var fragmentationSize:uint = 0;
        private var waitingForServerClose:Boolean = false;
        private var closeTimeout:int = 5000;
        private var closeTimer:Timer;
        private var handshakeBytesReceived:int;
        private var handshakeTimer:Timer;
        private var handshakeTimeout:int = 10000;
        private var tlsConfig:TLSConfig;
        private var tlsSocket:TLSSocket;
        private var URIpathExcludedBitmap:URIEncodingBitmap = new URIEncodingBitmap(URI.URIpathEscape);
        public var config:WebSocketConfig = new WebSocketConfig();
        public var debug:Boolean = false;

        public function WebSocket(_arg_1:String, _arg_2:String, _arg_3:*=null, _arg_4:uint=10000)
        {
            var _local_5:int;
            super(null);
            this._uri = new URI(_arg_1);
            if ((_arg_3 is String))
            {
                this._protocols = [_arg_3];
            }
            else
            {
                this._protocols = _arg_3;
            };
            if (this._protocols)
            {
                _local_5 = 0;
                while (_local_5 < this._protocols.length)
                {
                    this._protocols[_local_5] = StringUtil.trim(this._protocols[_local_5]);
                    _local_5++;
                };
            };
            this._origin = _arg_2;
            this.timeout = _arg_4;
            this.handshakeTimeout = _arg_4;
            this.init();
        }

        private function init():void
        {
            this.parseUrl();
            this.validateProtocol();
            this.frameQueue = new Vector.<WebSocketFrame>();
            this.fragmentationOpcode = 0;
            this.fragmentationSize = 0;
            this.currentFrame = new WebSocketFrame();
            this.fatalError = false;
            this.closeTimer = new Timer(this.closeTimeout, 1);
            this.closeTimer.addEventListener(TimerEvent.TIMER, this.handleCloseTimer);
            this.handshakeTimer = new Timer(this.handshakeTimeout, 1);
            this.handshakeTimer.addEventListener(TimerEvent.TIMER, this.handleHandshakeTimer);
            this.rawSocket = (this.socket = new Socket());
            this.socket.timeout = this.timeout;
            if (this.secure)
            {
                this.tlsConfig = new TLSConfig(TLSEngine.CLIENT, null, null, null, null, null, TLSSecurityParameters.PROTOCOL_VERSION);
                this.tlsConfig.trustAllCertificates = true;
                this.tlsConfig.ignoreCommonNameMismatch = true;
                this.socket = (this.tlsSocket = new TLSSocket());
            };
            this.rawSocket.addEventListener(Event.CONNECT, this.handleSocketConnect);
            this.rawSocket.addEventListener(IOErrorEvent.IO_ERROR, this.handleSocketIOError);
            this.rawSocket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, this.handleSocketSecurityError);
            this.socket.addEventListener(Event.CLOSE, this.handleSocketClose);
            this.socket.addEventListener(ProgressEvent.SOCKET_DATA, this.handleSocketData);
            this._readyState = WebSocketState.INIT;
        }

        private function validateProtocol():void
        {
            var _local_1:Array;
            var _local_2:int;
            var _local_3:String;
            var _local_4:int;
            var _local_5:int;
            var _local_6:String;
            if (this._protocols)
            {
                _local_1 = ["(", ")", "<", ">", "@", ",", ";", ":", "\\", '"', "/", "[", "]", "?", "=", "{", "}", " ", String.fromCharCode(9)];
                _local_2 = 0;
                while (_local_2 < this._protocols.length)
                {
                    _local_3 = this._protocols[_local_2];
                    _local_4 = 0;
                    while (_local_4 < _local_3.length)
                    {
                        _local_5 = _local_3.charCodeAt(_local_4);
                        _local_6 = _local_3.charAt(_local_4);
                        if ((((_local_5 < 33) || (_local_5 > 126)) || (!(_local_1.indexOf(_local_6) === -1))))
                        {
                            throw (new WebSocketError((("Illegal character '" + String.fromCharCode(_local_6)) + "' in subprotocol.")));
                        };
                        _local_4++;
                    };
                    _local_2++;
                };
            };
        }

        public function connect():void
        {
            if (((this._readyState === WebSocketState.INIT) || (this._readyState === WebSocketState.CLOSED)))
            {
                this._readyState = WebSocketState.CONNECTING;
                this.generateNonce();
                this.handshakeBytesReceived = 0;
                this.rawSocket.connect(this._host, this._port);
                if (this.debug)
                {
                    logger(((("Connecting to " + this._host) + " on port ") + this._port));
                };
            };
        }

        private function parseUrl():void
        {
            this._host = this._uri.authority;
            var _local_1:String = this._uri.scheme.toLocaleLowerCase();
            if (_local_1 === "wss")
            {
                this._secure = true;
                this._port = 443;
            }
            else
            {
                if (_local_1 === "ws")
                {
                    this._secure = false;
                    this._port = 80;
                }
                else
                {
                    throw (new Error(("Unsupported scheme: " + _local_1)));
                };
            };
            var _local_2:uint = parseInt(this._uri.port, 10);
            if (((!(isNaN(_local_2))) && (!(_local_2 === 0))))
            {
                this._port = _local_2;
            };
            var _local_3:String = URI.fastEscapeChars(this._uri.path, this.URIpathExcludedBitmap);
            if (_local_3.length === 0)
            {
                _local_3 = "/";
            };
            var _local_4:String = this._uri.queryRaw;
            if (_local_4.length > 0)
            {
                _local_4 = ("?" + _local_4);
            };
            this._resource = (_local_3 + _local_4);
        }

        private function generateNonce():void
        {
            this.nonce = new ByteArray();
            var _local_1:int;
            while (_local_1 < 16)
            {
                this.nonce.writeByte(Math.round((Math.random() * 0xFF)));
                _local_1++;
            };
            this.nonce.position = 0;
            this.base64nonce = Base64.encodeByteArray(this.nonce);
        }

        public function get readyState():int
        {
            return (this._readyState);
        }

        public function get bufferedAmount():int
        {
            return (this._bufferedAmount);
        }

        public function get uri():String
        {
            var _local_1:String;
            _local_1 = ((this._secure) ? "wss://" : "ws://");
            _local_1 = (_local_1 + this._host);
            if ((((this._secure) && (!(this._port === 443))) || ((!(this._secure)) && (!(this._port === 80)))))
            {
                _local_1 = (_local_1 + (":" + this._port.toString()));
            };
            return (_local_1 + this._resource);
        }

        public function get protocol():String
        {
            return (this._serverProtocol);
        }

        public function get extensions():Array
        {
            return ([]);
        }

        public function get host():String
        {
            return (this._host);
        }

        public function get port():uint
        {
            return (this._port);
        }

        public function get resource():String
        {
            return (this._resource);
        }

        public function get secure():Boolean
        {
            return (this._secure);
        }

        public function get connected():Boolean
        {
            return (this.readyState === WebSocketState.OPEN);
        }

        public function set useNullMask(_arg_1:Boolean):void
        {
            this._useNullMask = _arg_1;
        }

        public function get useNullMask():Boolean
        {
            return (this._useNullMask);
        }

        private function verifyConnectionForSend():void
        {
            if (this._readyState === WebSocketState.CONNECTING)
            {
                throw (new WebSocketError("Invalid State: Cannot send data before connected."));
            };
        }

        public function sendUTF(_arg_1:String):void
        {
            this.verifyConnectionForSend();
            var _local_2:WebSocketFrame = new WebSocketFrame();
            _local_2.opcode = WebSocketOpcode.TEXT_FRAME;
            _local_2.binaryPayload = new ByteArray();
            _local_2.binaryPayload.writeMultiByte(_arg_1, "utf-8");
            this.fragmentAndSend(_local_2);
        }

        public function sendBytes(_arg_1:ByteArray):void
        {
            this.verifyConnectionForSend();
            var _local_2:WebSocketFrame = new WebSocketFrame();
            _local_2.opcode = WebSocketOpcode.BINARY_FRAME;
            _local_2.binaryPayload = _arg_1;
            this.fragmentAndSend(_local_2);
        }

        public function ping(_arg_1:ByteArray=null):void
        {
            this.verifyConnectionForSend();
            var _local_2:WebSocketFrame = new WebSocketFrame();
            _local_2.fin = true;
            _local_2.opcode = WebSocketOpcode.PING;
            if (_arg_1)
            {
                _local_2.binaryPayload = _arg_1;
            };
            this.sendFrame(_local_2);
        }

        private function pong(_arg_1:ByteArray=null):void
        {
            this.verifyConnectionForSend();
            var _local_2:WebSocketFrame = new WebSocketFrame();
            _local_2.fin = true;
            _local_2.opcode = WebSocketOpcode.PONG;
            _local_2.binaryPayload = _arg_1;
            this.sendFrame(_local_2);
        }

        private function fragmentAndSend(_arg_1:WebSocketFrame):void
        {
            var _local_3:int;
            var _local_4:int;
            var _local_5:int;
            var _local_6:WebSocketFrame;
            var _local_7:int;
            if (_arg_1.opcode > 7)
            {
                throw (new WebSocketError("You cannot fragment control frames."));
            };
            var _local_2:uint = this.config.fragmentationThreshold;
            if ((((this.config.fragmentOutgoingMessages) && (_arg_1.binaryPayload)) && (_arg_1.binaryPayload.length > _local_2)))
            {
                _arg_1.binaryPayload.position = 0;
                _local_3 = _arg_1.binaryPayload.length;
                _local_4 = int(Math.ceil((_local_3 / _local_2)));
                _local_5 = 1;
                while (_local_5 <= _local_4)
                {
                    _local_6 = new WebSocketFrame();
                    _local_6.opcode = ((_local_5 === 1) ? _arg_1.opcode : 0);
                    _local_6.fin = (_local_5 === _local_4);
                    _local_7 = ((_local_5 === _local_4) ? (_local_3 - (_local_2 * (_local_5 - 1))) : _local_2);
                    _arg_1.binaryPayload.position = (_local_2 * (_local_5 - 1));
                    _local_6.binaryPayload = new ByteArray();
                    _arg_1.binaryPayload.readBytes(_local_6.binaryPayload, 0, _local_7);
                    this.sendFrame(_local_6);
                    _local_5++;
                };
            }
            else
            {
                _arg_1.fin = true;
                this.sendFrame(_arg_1);
            };
        }

        private function sendFrame(_arg_1:WebSocketFrame, _arg_2:Boolean=false):void
        {
            _arg_1.mask = true;
            _arg_1.useNullMask = this._useNullMask;
            var _local_3:ByteArray = new ByteArray();
            _arg_1.send(_local_3);
            this.sendData(_local_3);
        }

        private function sendData(_arg_1:ByteArray, _arg_2:Boolean=false):void
        {
            if ((!(this.connected)))
            {
                return;
            };
            _arg_1.position = 0;
            this.socket.writeBytes(_arg_1, 0, _arg_1.bytesAvailable);
            this.socket.flush();
            _arg_1.clear();
        }

        public function close(_arg_1:Boolean=true):void
        {
            var _local_2:WebSocketFrame;
            var _local_3:ByteArray;
            if (((!(this.socket.connected)) && (this._readyState === WebSocketState.CONNECTING)))
            {
                this._readyState = WebSocketState.CLOSED;
                try
                {
                    this.socket.close();
                }
                catch(e:Error)
                {
                };
            };
            if (this.socket.connected)
            {
                _local_2 = new WebSocketFrame();
                _local_2.rsv1 = (_local_2.rsv2 = (_local_2.rsv3 = (_local_2.mask = false)));
                _local_2.fin = true;
                _local_2.opcode = WebSocketOpcode.CONNECTION_CLOSE;
                _local_2.closeStatus = WebSocketCloseStatus.NORMAL;
                _local_3 = new ByteArray();
                _local_2.mask = true;
                _local_2.send(_local_3);
                this.sendData(_local_3, true);
                if (_arg_1)
                {
                    this.waitingForServerClose = true;
                    this.closeTimer.stop();
                    this.closeTimer.reset();
                    this.closeTimer.start();
                };
                this.dispatchClosedEvent();
            };
        }

        private function handleCloseTimer(_arg_1:TimerEvent):void
        {
            if (this.waitingForServerClose)
            {
                if (this.socket.connected)
                {
                    this.socket.close();
                };
            };
        }

        private function handleSocketConnect(_arg_1:Event):void
        {
            if (this.debug)
            {
                logger("Socket Connected");
            };
            if (this.secure)
            {
                if (this.debug)
                {
                    logger("starting SSL/TLS");
                };
                this.tlsSocket.startTLS(this.rawSocket, this._host, this.tlsConfig);
            };
            this.socket.endian = Endian.BIG_ENDIAN;
            this.sendHandshake();
        }

        private function handleSocketClose(_arg_1:Event):void
        {
            if (this.debug)
            {
                logger("Socket Disconnected");
            };
            this.dispatchClosedEvent();
        }

        private function handleSocketData(_arg_1:ProgressEvent=null):void
        {
            var _local_2:WebSocketEvent;
            if (this._readyState === WebSocketState.CONNECTING)
            {
                this.readServerHandshake();
                return;
            };
            while ((((this.socket.connected) && (this.currentFrame.addData(this.socket, this.fragmentationOpcode, this.config))) && (!(this.fatalError))))
            {
                if (this.currentFrame.protocolError)
                {
                    this.drop(WebSocketCloseStatus.PROTOCOL_ERROR, this.currentFrame.dropReason);
                    return;
                };
                if (this.currentFrame.frameTooLarge)
                {
                    this.drop(WebSocketCloseStatus.MESSAGE_TOO_LARGE, this.currentFrame.dropReason);
                    return;
                };
                if ((!(this.config.assembleFragments)))
                {
                    _local_2 = new WebSocketEvent(WebSocketEvent.FRAME);
                    _local_2.frame = this.currentFrame;
                    dispatchEvent(_local_2);
                };
                this.processFrame(this.currentFrame);
                this.currentFrame = new WebSocketFrame();
            };
        }

        private function processFrame(_arg_1:WebSocketFrame):void
        {
            var _local_2:WebSocketEvent;
            var _local_3:int;
            var _local_4:WebSocketFrame;
            var _local_5:WebSocketEvent;
            var _local_6:WebSocketEvent;
            var _local_7:int;
            var _local_8:ByteArray;
            var _local_9:int;
            if ((((_arg_1.rsv1) || (_arg_1.rsv2)) || (_arg_1.rsv3)))
            {
                this.drop(WebSocketCloseStatus.PROTOCOL_ERROR, "Received frame with reserved bit set without a negotiated extension.");
                return;
            };
            switch (_arg_1.opcode)
            {
                case WebSocketOpcode.BINARY_FRAME:
                    if (this.config.assembleFragments)
                    {
                        if (this.frameQueue.length === 0)
                        {
                            if (_arg_1.fin)
                            {
                                _local_2 = new WebSocketEvent(WebSocketEvent.MESSAGE);
                                _local_2.message = new WebSocketMessage();
                                _local_2.message.type = WebSocketMessage.TYPE_BINARY;
                                _local_2.message.binaryData = _arg_1.binaryPayload;
                                dispatchEvent(_local_2);
                            }
                            else
                            {
                                if (this.frameQueue.length === 0)
                                {
                                    this.frameQueue.push(_arg_1);
                                    this.fragmentationOpcode = _arg_1.opcode;
                                };
                            };
                        }
                        else
                        {
                            this.drop(WebSocketCloseStatus.PROTOCOL_ERROR, "Illegal BINARY_FRAME received in the middle of a fragmented message.  Expected a continuation or control frame.");
                            return;
                        };
                    };
                    return;
                case WebSocketOpcode.TEXT_FRAME:
                    if (this.config.assembleFragments)
                    {
                        if (this.frameQueue.length === 0)
                        {
                            if (_arg_1.fin)
                            {
                                _local_2 = new WebSocketEvent(WebSocketEvent.MESSAGE);
                                _local_2.message = new WebSocketMessage();
                                _local_2.message.type = WebSocketMessage.TYPE_UTF8;
                                _local_2.message.utf8Data = _arg_1.binaryPayload.readMultiByte(_arg_1.length, "utf-8");
                                dispatchEvent(_local_2);
                            }
                            else
                            {
                                this.frameQueue.push(_arg_1);
                                this.fragmentationOpcode = _arg_1.opcode;
                            };
                        }
                        else
                        {
                            this.drop(WebSocketCloseStatus.PROTOCOL_ERROR, "Illegal TEXT_FRAME received in the middle of a fragmented message.  Expected a continuation or control frame.");
                            return;
                        };
                    };
                    return;
                case WebSocketOpcode.CONTINUATION:
                    if (this.config.assembleFragments)
                    {
                        if (((this.fragmentationOpcode === WebSocketOpcode.CONTINUATION) && (_arg_1.opcode === WebSocketOpcode.CONTINUATION)))
                        {
                            this.drop(WebSocketCloseStatus.PROTOCOL_ERROR, "Unexpected continuation frame.");
                            return;
                        };
                        this.fragmentationSize = (this.fragmentationSize + _arg_1.length);
                        if (this.fragmentationSize > this.config.maxMessageSize)
                        {
                            this.drop(WebSocketCloseStatus.MESSAGE_TOO_LARGE, "Maximum message size exceeded.");
                            return;
                        };
                        this.frameQueue.push(_arg_1);
                        if (_arg_1.fin)
                        {
                            _local_2 = new WebSocketEvent(WebSocketEvent.MESSAGE);
                            _local_2.message = new WebSocketMessage();
                            _local_7 = this.frameQueue[0].opcode;
                            _local_8 = new ByteArray();
                            _local_9 = 0;
                            _local_3 = 0;
                            while (_local_3 < this.frameQueue.length)
                            {
                                _local_9 = (_local_9 + this.frameQueue[_local_3].length);
                                _local_3++;
                            };
                            if (_local_9 > this.config.maxMessageSize)
                            {
                                this.drop(WebSocketCloseStatus.MESSAGE_TOO_LARGE, (((("Message size of " + _local_9) + " bytes exceeds maximum accepted message size of ") + this.config.maxMessageSize) + " bytes."));
                                return;
                            };
                            _local_3 = 0;
                            while (_local_3 < this.frameQueue.length)
                            {
                                _local_4 = this.frameQueue[_local_3];
                                _local_8.writeBytes(_local_4.binaryPayload, 0, _local_4.binaryPayload.length);
                                _local_4.binaryPayload.clear();
                                _local_3++;
                            };
                            _local_8.position = 0;
                            switch (_local_7)
                            {
                                case WebSocketOpcode.BINARY_FRAME:
                                    _local_2.message.type = WebSocketMessage.TYPE_BINARY;
                                    _local_2.message.binaryData = _local_8;
                                    break;
                                case WebSocketOpcode.TEXT_FRAME:
                                    _local_2.message.type = WebSocketMessage.TYPE_UTF8;
                                    _local_2.message.utf8Data = _local_8.readMultiByte(_local_8.length, "utf-8");
                                    break;
                                default:
                                    this.drop(WebSocketCloseStatus.PROTOCOL_ERROR, ("Unexpected first opcode in fragmentation sequence: 0x" + _local_7.toString(16)));
                                    return;
                            };
                            this.frameQueue = new Vector.<WebSocketFrame>();
                            this.fragmentationOpcode = 0;
                            this.fragmentationSize = 0;
                            dispatchEvent(_local_2);
                        };
                    };
                    return;
                case WebSocketOpcode.PING:
                    if (this.debug)
                    {
                        logger("Received Ping");
                    };
                    _local_5 = new WebSocketEvent(WebSocketEvent.PING, false, true);
                    _local_5.frame = _arg_1;
                    if (dispatchEvent(_local_5))
                    {
                        this.pong(_arg_1.binaryPayload);
                    };
                    return;
                case WebSocketOpcode.PONG:
                    if (this.debug)
                    {
                        logger("Received Pong");
                    };
                    _local_6 = new WebSocketEvent(WebSocketEvent.PONG);
                    _local_6.frame = _arg_1;
                    dispatchEvent(_local_6);
                    return;
                case WebSocketOpcode.CONNECTION_CLOSE:
                    if (this.debug)
                    {
                        logger("Received close frame");
                    };
                    if (this.waitingForServerClose)
                    {
                        if (this.debug)
                        {
                            logger("Got close confirmation from server.");
                        };
                        this.closeTimer.stop();
                        this.waitingForServerClose = false;
                        this.socket.close();
                    }
                    else
                    {
                        if (this.debug)
                        {
                            logger("Sending close response to server.");
                        };
                        this.close(false);
                        this.socket.close();
                    };
                    return;
                default:
                    if (this.debug)
                    {
                        logger(("Unrecognized Opcode: 0x" + _arg_1.opcode.toString(16)));
                    };
                    this.drop(WebSocketCloseStatus.PROTOCOL_ERROR, ("Unrecognized Opcode: 0x" + _arg_1.opcode.toString(16)));
            };
        }

        private function handleSocketIOError(_arg_1:IOErrorEvent):void
        {
            if (this.debug)
            {
                logger(("IO Error: " + _arg_1));
            };
            dispatchEvent(_arg_1);
            this.dispatchClosedEvent();
        }

        private function handleSocketSecurityError(_arg_1:SecurityErrorEvent):void
        {
            if (this.debug)
            {
                logger(("Security Error: " + _arg_1));
            };
            dispatchEvent(_arg_1.clone());
            this.dispatchClosedEvent();
        }

        private function sendHandshake():void
        {
            var _local_3:String;
            this.serverHandshakeResponse = "";
            var _local_1:String = this.host;
            if ((((this._secure) && (!(this._port === 443))) || ((!(this._secure)) && (!(this._port === 80)))))
            {
                _local_1 = (_local_1 + (":" + this._port.toString()));
            };
            var _local_2:String = "";
            _local_2 = (_local_2 + (("GET " + this.resource) + " HTTP/1.1\r\n"));
            _local_2 = (_local_2 + (("Host: " + _local_1) + "\r\n"));
            _local_2 = (_local_2 + "Upgrade: websocket\r\n");
            _local_2 = (_local_2 + "Connection: Upgrade\r\n");
            _local_2 = (_local_2 + (("Sec-WebSocket-Key: " + this.base64nonce) + "\r\n"));
            if (this._origin)
            {
                _local_2 = (_local_2 + (("Origin: " + this._origin) + "\r\n"));
            };
            _local_2 = (_local_2 + "Sec-WebSocket-Version: 13\r\n");
            if (this._protocols)
            {
                _local_3 = this._protocols.join(", ");
                _local_2 = (_local_2 + (("Sec-WebSocket-Protocol: " + _local_3) + "\r\n"));
            };
            _local_2 = (_local_2 + "\r\n");
            if (this.debug)
            {
                logger(_local_2);
            };
            this.socket.writeMultiByte(_local_2, "us-ascii");
            this.handshakeTimer.stop();
            this.handshakeTimer.reset();
            this.handshakeTimer.start();
        }

        private function failHandshake(_arg_1:String="Unable to complete websocket handshake."):void
        {
            if (this.debug)
            {
                logger(_arg_1);
            };
            this._readyState = WebSocketState.CLOSED;
            if (this.socket.connected)
            {
                this.socket.close();
            };
            this.handshakeTimer.stop();
            this.handshakeTimer.reset();
            var _local_2:WebSocketErrorEvent = new WebSocketErrorEvent(WebSocketErrorEvent.CONNECTION_FAIL);
            _local_2.text = _arg_1;
            dispatchEvent(_local_2);
            var _local_3:WebSocketEvent = new WebSocketEvent(WebSocketEvent.CLOSED);
            dispatchEvent(_local_3);
        }

        private function failConnection(_arg_1:String):void
        {
            this._readyState = WebSocketState.CLOSED;
            if (this.socket.connected)
            {
                this.socket.close();
            };
            var _local_2:WebSocketErrorEvent = new WebSocketErrorEvent(WebSocketErrorEvent.CONNECTION_FAIL);
            _local_2.text = _arg_1;
            dispatchEvent(_local_2);
            var _local_3:WebSocketEvent = new WebSocketEvent(WebSocketEvent.CLOSED);
            dispatchEvent(_local_3);
        }

        private function drop(_arg_1:uint=1002, _arg_2:String=null):void
        {
            var _local_4:WebSocketErrorEvent;
            if ((!(this.connected)))
            {
                return;
            };
            this.fatalError = true;
            var _local_3:String = ("WebSocket: Dropping Connection. Code: " + _arg_1.toString(10));
            if (_arg_2)
            {
                _local_3 = (_local_3 + (" - " + _arg_2));
            };
            logger(_local_3);
            this.frameQueue = new Vector.<WebSocketFrame>();
            this.fragmentationSize = 0;
            if (_arg_1 !== WebSocketCloseStatus.NORMAL)
            {
                _local_4 = new WebSocketErrorEvent(WebSocketErrorEvent.ABNORMAL_CLOSE);
                _local_4.text = ("Close reason: " + _arg_1);
                dispatchEvent(_local_4);
            };
            this.sendCloseFrame(_arg_1, _arg_2, true);
            this.dispatchClosedEvent();
            this.socket.close();
        }

        private function sendCloseFrame(_arg_1:uint=1000, _arg_2:String=null, _arg_3:Boolean=false):void
        {
            var _local_4:WebSocketFrame = new WebSocketFrame();
            _local_4.fin = true;
            _local_4.opcode = WebSocketOpcode.CONNECTION_CLOSE;
            _local_4.closeStatus = _arg_1;
            if (_arg_2)
            {
                _local_4.binaryPayload = new ByteArray();
                _local_4.binaryPayload.writeUTFBytes(_arg_2);
            };
            this.sendFrame(_local_4, _arg_3);
        }

        private function readServerHandshake():void
        {
            var responseLine:String;
            var header:Object;
            var lcName:String;
            var lcValue:String;
            var extensionsThisLine:Array;
            var byteArray:ByteArray;
            var expectedKey:String;
            var protocol:String;
            var upgradeHeader:Boolean;
            var connectionHeader:Boolean;
            var serverProtocolHeaderMatch:Boolean;
            var keyValidated:Boolean;
            var headersTerminatorIndex:int = -1;
            while (((headersTerminatorIndex === -1) && (this.readHandshakeLine())))
            {
                if (this.handshakeBytesReceived > MAX_HANDSHAKE_BYTES)
                {
                    this.failHandshake((("Received more than " + MAX_HANDSHAKE_BYTES) + " bytes during handshake."));
                    return;
                };
                headersTerminatorIndex = this.serverHandshakeResponse.search(/\r?\n\r?\n/);
            };
            if (headersTerminatorIndex === -1)
            {
                return;
            };
            if (this.debug)
            {
                logger(("Server Response Headers:\n" + this.serverHandshakeResponse));
            };
            this.serverHandshakeResponse = this.serverHandshakeResponse.slice(0, headersTerminatorIndex);
            var lines:Array = this.serverHandshakeResponse.split(/\r?\n/);
            responseLine = lines.shift();
            var responseLineMatch:Array = responseLine.match(/^(HTTP\/\d\.\d) (\d{3}) ?(.*)$/i);
            if (responseLineMatch.length === 0)
            {
                this.failHandshake("Unable to find correctly-formed HTTP status line.");
                return;
            };
            var httpVersion:String = responseLineMatch[1];
            var statusCode:int = parseInt(responseLineMatch[2], 10);
            var statusDescription:String = responseLineMatch[3];
            if (this.debug)
            {
                logger(((("HTTP Status Received: " + statusCode) + " ") + statusDescription));
            };
            if (statusCode !== 101)
            {
                this.failHandshake(((("An HTTP response code other than 101 was received.  Actual Response Code: " + statusCode) + " ") + statusDescription));
                return;
            };
            this.serverExtensions = [];
            try
            {
                while (lines.length > 0)
                {
                    responseLine = lines.shift();
                    header = this.parseHTTPHeader(responseLine);
                    lcName = header.name.toLocaleLowerCase();
                    lcValue = header.value.toLocaleLowerCase();
                    if (((lcName === "upgrade") && (lcValue === "websocket")))
                    {
                        upgradeHeader = true;
                    }
                    else
                    {
                        if (((lcName === "connection") && (lcValue === "upgrade")))
                        {
                            connectionHeader = true;
                        }
                        else
                        {
                            if (((lcName === "sec-websocket-extensions") && (header.value)))
                            {
                                extensionsThisLine = header.value.split(",");
                                this.serverExtensions = this.serverExtensions.concat(extensionsThisLine);
                            }
                            else
                            {
                                if (lcName === "sec-websocket-accept")
                                {
                                    byteArray = new ByteArray();
                                    byteArray.writeUTFBytes((this.base64nonce + "258EAFA5-E914-47DA-95CA-C5AB0DC85B11"));
                                    expectedKey = Base64.encodeByteArray(new SHA1().hash(byteArray));
                                    if (this.debug)
                                    {
                                        logger(("Expected Sec-WebSocket-Accept value: " + expectedKey));
                                    };
                                    if (header.value === expectedKey)
                                    {
                                        keyValidated = true;
                                    };
                                }
                                else
                                {
                                    if (lcName === "sec-websocket-protocol")
                                    {
                                        if (this._protocols)
                                        {
                                            for each (protocol in this._protocols)
                                            {
                                                if (protocol == header.value)
                                                {
                                                    this._serverProtocol = protocol;
                                                };
                                            };
                                        };
                                    };
                                };
                            };
                        };
                    };
                };
            }
            catch(e:Error)
            {
                failHandshake(("There was an error while parsing the following HTTP Header line:\n" + responseLine));
                return;
            };
            if ((!(upgradeHeader)))
            {
                this.failHandshake("The server response did not include a valid Upgrade: websocket header.");
                return;
            };
            if ((!(connectionHeader)))
            {
                this.failHandshake("The server response did not include a valid Connection: upgrade header.");
                return;
            };
            if ((!(keyValidated)))
            {
                this.failHandshake("Unable to validate server response for Sec-Websocket-Accept header.");
                return;
            };
            if (((this._protocols) && (!(this._serverProtocol))))
            {
                this.failHandshake("The server can not respond in any of our requested protocols");
                return;
            };
            if (this.debug)
            {
                logger(("Server Extensions: " + this.serverExtensions.join(" | ")));
            };
            this.handshakeTimer.stop();
            this.handshakeTimer.reset();
            this.serverHandshakeResponse = null;
            this._readyState = WebSocketState.OPEN;
            this.currentFrame = new WebSocketFrame();
            this.frameQueue = new Vector.<WebSocketFrame>();
            dispatchEvent(new WebSocketEvent(WebSocketEvent.OPEN));
            this.handleSocketData();
        }

        private function handleHandshakeTimer(_arg_1:TimerEvent):void
        {
            this.failHandshake("Timed out waiting for server response.");
        }

        private function parseHTTPHeader(_arg_1:String):Object
        {
            var _local_2:Array = _arg_1.split(/\: +/);
            return ((_local_2.length === 2) ? {
    "name":_local_2[0],
    "value":_local_2[1]
} : null);
        }

        private function readHandshakeLine():Boolean
        {
            var _local_1:String;
            while (this.socket.bytesAvailable)
            {
                _local_1 = this.socket.readMultiByte(1, "us-ascii");
                this.handshakeBytesReceived++;
                this.serverHandshakeResponse = (this.serverHandshakeResponse + _local_1);
                if (_local_1 == "\n")
                {
                    return (true);
                };
            };
            return (false);
        }

        private function dispatchClosedEvent():void
        {
            var _local_1:WebSocketEvent;
            if (this.handshakeTimer.running)
            {
                this.handshakeTimer.stop();
            };
            if (this._readyState !== WebSocketState.CLOSED)
            {
                this._readyState = WebSocketState.CLOSED;
                _local_1 = new WebSocketEvent(WebSocketEvent.CLOSED);
                dispatchEvent(_local_1);
            };
        }


    }
}//package com.worlize.websocket


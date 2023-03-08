// Decompiled by AS3 Sorcerer 6.30
// www.as3sorcerer.com

//com.worlize.websocket.WebSocketFrame

package com.worlize.websocket
{
    import __AS3__.vec.Vector;
    import flash.utils.ByteArray;
    import flash.utils.Endian;
    import flash.utils.IDataInput;
    import flash.utils.IDataOutput;
    import __AS3__.vec.*;

    public class WebSocketFrame 
    {

        private static const NEW_FRAME:int = 0;
        private static const WAITING_FOR_16_BIT_LENGTH:int = 1;
        private static const WAITING_FOR_64_BIT_LENGTH:int = 2;
        private static const WAITING_FOR_PAYLOAD:int = 3;
        private static const COMPLETE:int = 4;
        private static var _tempMaskBytes:Vector.<uint> = new Vector.<uint>(4);

        public var fin:Boolean;
        public var rsv1:Boolean;
        public var rsv2:Boolean;
        public var rsv3:Boolean;
        public var opcode:int;
        public var mask:Boolean;
        public var useNullMask:Boolean;
        private var _length:int;
        public var binaryPayload:ByteArray;
        public var closeStatus:int;
        public var protocolError:Boolean = false;
        public var frameTooLarge:Boolean = false;
        public var dropReason:String;
        private var parseState:int = 0;


        public function get length():int
        {
            return (this._length);
        }

        public function addData(_arg_1:IDataInput, _arg_2:int, _arg_3:WebSocketConfig):Boolean
        {
            var _local_4:int;
            var _local_5:int;
            var _local_6:uint;
            if (_arg_1.bytesAvailable >= 2)
            {
                if (this.parseState === NEW_FRAME)
                {
                    _local_4 = _arg_1.readByte();
                    _local_5 = _arg_1.readByte();
                    this.fin = Boolean((_local_4 & 0x80));
                    this.rsv1 = Boolean((_local_4 & 0x40));
                    this.rsv2 = Boolean((_local_4 & 0x20));
                    this.rsv3 = Boolean((_local_4 & 0x10));
                    this.mask = Boolean((_local_5 & 0x80));
                    this.opcode = (_local_4 & 0x0F);
                    this._length = (_local_5 & 0x7F);
                    if (this.mask)
                    {
                        this.protocolError = true;
                        this.dropReason = "Received an illegal masked frame from the server.";
                        return (true);
                    };
                    if (this.opcode > 7)
                    {
                        if (this._length > 125)
                        {
                            this.protocolError = true;
                            this.dropReason = "Illegal control frame larger than 125 bytes.";
                            return (true);
                        };
                        if ((!(this.fin)))
                        {
                            this.protocolError = true;
                            this.dropReason = "Received illegal fragmented control message.";
                            return (true);
                        };
                    };
                    if (this._length === 126)
                    {
                        this.parseState = WAITING_FOR_16_BIT_LENGTH;
                    }
                    else
                    {
                        if (this._length === 127)
                        {
                            this.parseState = WAITING_FOR_64_BIT_LENGTH;
                        }
                        else
                        {
                            this.parseState = WAITING_FOR_PAYLOAD;
                        };
                    };
                };
                if (this.parseState === WAITING_FOR_16_BIT_LENGTH)
                {
                    if (_arg_1.bytesAvailable >= 2)
                    {
                        this._length = _arg_1.readUnsignedShort();
                        this.parseState = WAITING_FOR_PAYLOAD;
                    };
                }
                else
                {
                    if (this.parseState === WAITING_FOR_64_BIT_LENGTH)
                    {
                        if (_arg_1.bytesAvailable >= 8)
                        {
                            _local_6 = _arg_1.readUnsignedInt();
                            if (_local_6 > 0)
                            {
                                this.frameTooLarge = true;
                                this.dropReason = "Unsupported 64-bit length frame received.";
                                return (true);
                            };
                            this._length = _arg_1.readUnsignedInt();
                            this.parseState = WAITING_FOR_PAYLOAD;
                        };
                    };
                };
                if (this.parseState === WAITING_FOR_PAYLOAD)
                {
                    if (this._length > _arg_3.maxReceivedFrameSize)
                    {
                        this.frameTooLarge = true;
                        this.dropReason = ((("Received frame size of " + this._length) + "exceeds maximum accepted frame size of ") + _arg_3.maxReceivedFrameSize);
                        return (true);
                    };
                    if (this._length === 0)
                    {
                        this.binaryPayload = new ByteArray();
                        this.parseState = COMPLETE;
                        return (true);
                    };
                    if (_arg_1.bytesAvailable >= this._length)
                    {
                        this.binaryPayload = new ByteArray();
                        this.binaryPayload.endian = Endian.BIG_ENDIAN;
                        _arg_1.readBytes(this.binaryPayload, 0, this._length);
                        this.binaryPayload.position = 0;
                        this.parseState = COMPLETE;
                        return (true);
                    };
                };
            };
            return (false);
        }

        private function throwAwayPayload(_arg_1:IDataInput):void
        {
            var _local_2:int;
            if (_arg_1.bytesAvailable >= this._length)
            {
                _local_2 = 0;
                while (_local_2 < this._length)
                {
                    _arg_1.readByte();
                    _local_2++;
                };
                this.parseState = COMPLETE;
            };
        }

        public function send(_arg_1:IDataOutput):void
        {
            var _local_2:uint;
            var _local_3:ByteArray;
            var _local_6:int;
            var _local_7:uint;
            if (((this.mask) && (!(this.useNullMask))))
            {
                _local_2 = Math.ceil((Math.random() * 0xFFFFFFFF));
                _tempMaskBytes[0] = ((_local_2 >> 24) & 0xFF);
                _tempMaskBytes[1] = ((_local_2 >> 16) & 0xFF);
                _tempMaskBytes[2] = ((_local_2 >> 8) & 0xFF);
                _tempMaskBytes[3] = (_local_2 & 0xFF);
            };
            var _local_4:int;
            var _local_5:int;
            if (this.fin)
            {
                _local_4 = (_local_4 | 0x80);
            };
            if (this.rsv1)
            {
                _local_4 = (_local_4 | 0x40);
            };
            if (this.rsv2)
            {
                _local_4 = (_local_4 | 0x20);
            };
            if (this.rsv3)
            {
                _local_4 = (_local_4 | 0x10);
            };
            if (this.mask)
            {
                _local_5 = (_local_5 | 0x80);
            };
            _local_4 = (_local_4 | (this.opcode & 0x0F));
            if (this.opcode === WebSocketOpcode.CONNECTION_CLOSE)
            {
                _local_3 = new ByteArray();
                _local_3.endian = Endian.BIG_ENDIAN;
                _local_3.writeShort(this.closeStatus);
                if (this.binaryPayload)
                {
                    this.binaryPayload.position = 0;
                    _local_3.writeBytes(this.binaryPayload);
                };
                _local_3.position = 0;
                this._length = _local_3.length;
            }
            else
            {
                if (this.binaryPayload)
                {
                    _local_3 = this.binaryPayload;
                    _local_3.endian = Endian.BIG_ENDIAN;
                    _local_3.position = 0;
                    this._length = _local_3.length;
                }
                else
                {
                    _local_3 = new ByteArray();
                    this._length = 0;
                };
            };
            if (this.opcode >= 8)
            {
                if (this._length > 125)
                {
                    throw (new Error("Illegal control frame longer than 125 bytes"));
                };
                if ((!(this.fin)))
                {
                    throw (new Error("Control frames must not be fragmented."));
                };
            };
            if (this._length <= 125)
            {
                _local_5 = (_local_5 | (this._length & 0x7F));
            }
            else
            {
                if (((this._length > 125) && (this._length <= 0xFFFF)))
                {
                    _local_5 = (_local_5 | 0x7E);
                }
                else
                {
                    if (this._length > 0xFFFF)
                    {
                        _local_5 = (_local_5 | 0x7F);
                    };
                };
            };
            _arg_1.writeByte(_local_4);
            _arg_1.writeByte(_local_5);
            if (((this._length > 125) && (this._length <= 0xFFFF)))
            {
                _arg_1.writeShort(this._length);
            }
            else
            {
                if (this._length > 0xFFFF)
                {
                    _arg_1.writeUnsignedInt(0);
                    _arg_1.writeUnsignedInt(this._length);
                };
            };
            if (this.mask)
            {
                if (this.useNullMask)
                {
                    _arg_1.writeUnsignedInt(0);
                    _arg_1.writeBytes(_local_3, 0, _local_3.length);
                }
                else
                {
                    _arg_1.writeUnsignedInt(_local_2);
                    _local_6 = 0;
                    _local_7 = _local_3.bytesAvailable;
                    while (_local_7 >= 4)
                    {
                        _arg_1.writeUnsignedInt((_local_3.readUnsignedInt() ^ _local_2));
                        _local_7 = (_local_7 - 4);
                    };
                    while (_local_7 > 0)
                    {
                        _arg_1.writeByte((_local_3.readByte() ^ _tempMaskBytes[_local_6]));
                        _local_6 = (_local_6 + 1);
                        _local_7 = (_local_7 - 1);
                    };
                };
            }
            else
            {
                _arg_1.writeBytes(_local_3, 0, _local_3.length);
            };
        }


    }
}//package com.worlize.websocket


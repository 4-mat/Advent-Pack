// Decompiled by AS3 Sorcerer 6.20
// www.as3sorcerer.com

//com.iam2bam.ane.nativejoystick.intern.NativeJoystickMgr

package com.iam2bam.ane.nativejoystick.intern
{
    import flash.events.EventDispatcher;
    import flash.external.ExtensionContext;
    import flash.utils.Timer;
    import __AS3__.vec.Vector;
    import com.iam2bam.ane.nativejoystick.event.NativeJoystickEvent;
    import com.iam2bam.ane.nativejoystick.NativeJoystick;
    import flash.events.TimerEvent;

    public class NativeJoystickMgr extends EventDispatcher 
    {

        public static const TRACE_SILENT:uint = 0;
        public static const TRACE_NORMAL:uint = 1;
        public static const TRACE_VERBOSE:uint = 2;
        public static const TRACE_DIAGNOSE:uint = 3;
        public static const DEF_POLL_INTERVAL:Number = 33;
        private static const VERSION:String = "1.11";

        private static var _mgr:NativeJoystickMgr;

        private const STR_UPDATEJOYSTICKS:String = "updateJoysticks";

        public var dispatchAlreadyPlugged:Boolean = true;
        private var _ectx:ExtensionContext;
        private var _pollInterval:Number;
        private var _traceLevel:uint;
        private var _detectIntervalMillis:uint;
        private var _tmrPoll:Timer;
        private var _data:Vector.<NativeJoystickData>;
        private var _maxDevs:int;
        private var _analogThreshold:Number = 0.1;

        public function NativeJoystickMgr()
        {
            try
            {
                _traceLevel = 1;
                _maxDevs = -1;
                _pollInterval = 33;
                _ectx = ExtensionContext.createExtensionContext("com.iam2bam.ane.nativejoystick", null);
                _maxDevs = _ectx.call("getMaxDevices");
                _data = new Vector.<NativeJoystickData>(_maxDevs, true);
                (trace(("NativeJoystick extension by 2bam.com - v" + version)));
                if ("1.11" != version)
                {
                    (trace(((("NativeJoystick dll/ane version mismatch: DLL v" + version) + " ANE v") + "1.11")));
                };
                detectIntervalMillis = 300;
                _tmrPoll = new Timer(_pollInterval);
                _tmrPoll.addEventListener("timer", onTimerPoll, false, 0, true);
                _tmrPoll.start();
                updateJoysticks();
            }
            catch(error:Error)
            {
                (trace("NativeJoystickMgr: error creating extension context"));
                (trace(error.errorID, error.name, error.message));
            };
        }

        public static function instance():NativeJoystickMgr
        {
            if (!_mgr)
            {
                _mgr = new (NativeJoystickMgr)();
            };
            return (_mgr);
        }

        public static function dispose():void
        {
            if (_mgr)
            {
                _mgr._ectx.dispose();
                _mgr._tmrPoll.stop();
                _mgr = null;
            };
        }


        public function isPlugged(_arg_1:uint):Boolean
        {
            if (((_arg_1 < 0) || (_arg_1 >= _maxDevs)))
            {
                return (false);
            };
            return ((_data[_arg_1] != null) ? ((_data[_arg_1].detected) && (_data[_arg_1].curr.plugged)) : false);
        }

        public function getData(_arg_1:uint):NativeJoystickData
        {
            if (_arg_1 > _maxDevs)
            {
                return (null);
            };
            var _local_2:NativeJoystickData = _data[_arg_1];
            if (!_local_2)
            {
                var _temp_1:* = new NativeJoystickData(_arg_1);
                var _temp_2:* = _temp_1;
                _local_2 = _temp_2;
                _data[_arg_1] = _temp_1;
            };
            return (_local_2);
        }

        public function get pollInterval():Number
        {
            return (_pollInterval);
        }

        override public function addEventListener(_arg_1:String, _arg_2:Function, _arg_3:Boolean=false, _arg_4:int=0, _arg_5:Boolean=false):void
        {
            var _local_8:* = null;
            var _local_7:int;
            var _local_6:* = null;
            super.addEventListener(_arg_1, _arg_2, _arg_3, _arg_4, _arg_5);
            if (((dispatchAlreadyPlugged) && (_arg_1 == "NJOYPlugged")))
            {
                _local_7 = (_maxDevs - 1);
                while (_local_7 >= 0)
                {
                    _local_6 = _data[_local_7];
                    if (!((!(_local_6)) || (!(_local_6.curr.plugged))))
                    {
                        _ectx.call("getCapabilities", _local_7, _local_6.caps);
                        _local_6.curr.reset(_local_6.caps, true);
                        _local_6.prev.reset(_local_6.caps, false);
                        if (!_local_8)
                        {
                            _local_8 = new NativeJoystickEvent("NJOYPlugged");
                        };
                        _local_8.index = _local_7;
                        if (!_local_6.joystick)
                        {
                            _local_6.joystick = new NativeJoystick(_local_7);
                        };
                        _local_8.joystick = _local_6.joystick;
                        (_arg_2(_local_8));
                    };
                    _local_7--;
                };
            };
        }

        public function set pollInterval(_arg_1:Number):void
        {
            _pollInterval = _arg_1;
            if (_arg_1 <= 0)
            {
                if (_tmrPoll)
                {
                    _tmrPoll.stop();
                };
            }
            else
            {
                if (_arg_1 < 20)
                {
                    (trace("RadNativeJoystickMgr: A pollInterval of less than 20 ms is not recommended (default and suggested value is 33 ms)"));
                };
                if (_tmrPoll)
                {
                    _tmrPoll.delay = _arg_1;
                    if (!_tmrPoll.running)
                    {
                        _tmrPoll.start();
                        updateJoysticks();
                    };
                };
            };
        }

        public function reloadDriverConfig():void
        {
            _ectx.call("reloadDriverConfig");
        }

        private function createEvent(_arg_1:String, _arg_2:NativeJoystickData):NativeJoystickEvent
        {
            var _local_3:NativeJoystickEvent = new NativeJoystickEvent(_arg_1);
            _local_3.index = _arg_2.index;
            if (!_arg_2.joystick)
            {
                _arg_2.joystick = new NativeJoystick(_arg_2.index);
            };
            _local_3.joystick = _arg_2.joystick;
            return (_local_3);
        }

        private function onTimerPoll(_arg_1:TimerEvent):void
        {
            var _local_19:int;
            var _local_2:* = null;
            var _local_14:* = null;
            var _local_5:uint;
            var _local_12:uint;
            var _local_20:uint;
            var _local_22:uint;
            var _local_21:int;
            var _local_23:* = null;
            var _local_13:int;
            var _local_7:int;
            var _local_16:int;
            var _local_15:*;
            var _local_17:*;
            var _local_4:*;
            var _local_25:*;
            var _local_10:*;
            var _local_24:Number;
            var _local_3:Number;
            var _local_8:Number;
            var _local_11:* = null;
            updateJoysticks();
            var _local_9:Boolean = hasEventListener("NJOYButtonDown");
            var _local_6:Boolean = hasEventListener("NJOYButtonUp");
            var _local_18:Boolean = hasEventListener("NJOYAxisMove");
            _local_19 = (_maxDevs - 1);
            while (_local_19 >= 0)
            {
                _local_2 = _data[_local_19];
                if (!((!(_local_2)) || (!(_local_2.detected))))
                {
                    _local_14 = _local_2.caps;
                    if (_local_14)
                    {
                        _local_5 = _local_2.curr.buttons;
                        _local_12 = _local_2.prev.buttons;
                        var _local_26:* = (_local_5 & (~(_local_12)));
                        _local_2.buttonsJP = _local_26;
                        _local_20 = _local_26;
                        _local_26 = ((~(_local_5)) & _local_12);
                        _local_2.buttonsJR = _local_26;
                        _local_22 = _local_26;
                        if (((_local_9) || (_local_6)))
                        {
                            if (!_local_9)
                            {
                                _local_20 = 0;
                            };
                            if (!_local_6)
                            {
                                _local_22 = 0;
                            };
                            _local_13 = 1;
                            _local_7 = _local_14.numButtons;
                            _local_21 = 0;
                            while (_local_21 < _local_7)
                            {
                                if ((_local_20 & _local_13))
                                {
                                    _local_23 = createEvent("NJOYButtonDown", _local_2);
                                    _local_23.buttonIndex = _local_21;
                                    dispatchEvent(_local_23);
                                }
                                else
                                {
                                    if ((_local_22 & _local_13))
                                    {
                                        _local_23 = createEvent("NJOYButtonUp", _local_2);
                                        _local_23.buttonIndex = _local_21;
                                        dispatchEvent(_local_23);
                                    };
                                };
                                _local_13 = (_local_13 << 1);
                                _local_21++;
                            };
                        };
                        _local_16 = 8;
                        _local_15 = _local_2.curr.axes;
                        _local_17 = _local_2.prev.axes;
                        _local_4 = _local_14.axesRange;
                        _local_25 = _local_14.hasAxis;
                        _local_10 = _local_2.curr.axesRaw;
                        _local_21 = 0;
                        while (_local_21 < _local_16)
                        {
                            _local_3 = _local_17[_local_21];
                            if (_local_25[_local_21])
                            {
                                _local_24 = (((2 * _local_10[_local_21]) / _local_4[_local_21]) - 1);
                                _local_15[_local_21] = _local_24;
                                if (((-(_analogThreshold) < _local_24) && (_local_24 < _analogThreshold)))
                                {
                                    _local_24 = 0;
                                };
                                if (((-(_analogThreshold) < _local_3) && (_local_3 < _analogThreshold)))
                                {
                                    _local_3 = 0;
                                };
                                _local_8 = (_local_24 - _local_3);
                                if (((_local_18) && (!(_local_8 == 0))))
                                {
                                    _local_23 = createEvent("NJOYAxisMove", _local_2);
                                    _local_23.axisIndex = _local_21;
                                    _local_23.axisValue = _local_24;
                                    _local_23.axisDelta = _local_8;
                                    dispatchEvent(_local_23);
                                };
                            };
                            _local_21++;
                        };
                        if (_local_2.curr.plugged != _local_2.prev.plugged)
                        {
                            if (_local_2.curr.plugged)
                            {
                                _local_11 = "NJOYPlugged";
                                _ectx.call("getCapabilities", _local_19, _local_2.caps);
                                _local_2.curr.reset(_local_2.caps, true);
                                _local_2.prev.reset(_local_2.caps, false);
                                if (_traceLevel >= 1)
                                {
                                    (trace((("[NJOY] Joystick #" + _local_2.index) + " plugged.")));
                                };
                                if (_traceLevel >= 2)
                                {
                                    (trace(("[NJOY] Caps for joystick #" + _local_19)));
                                    (trace((_local_2.caps + "\n")));
                                };
                            }
                            else
                            {
                                if (!_local_2.detected)
                                {
                                    _local_11 = "NJOYUnplugged";
                                    if (_traceLevel >= 2)
                                    {
                                        (trace((("[NJOY] Joystick #" + _local_2.index) + " unplugged w/errors")));
                                    };
                                }
                                else
                                {
                                    _local_11 = "NJOYUnplugged";
                                    if (_traceLevel >= 2)
                                    {
                                        (trace((("[NJOY] Joystick #" + _local_2.index) + " unplugged")));
                                    };
                                };
                            };
                            if (hasEventListener(_local_11))
                            {
                                dispatchEvent(createEvent(_local_11, _local_2));
                            };
                        };
                    };
                };
                _local_19--;
            };
        }

        public function get traceLevel():uint
        {
            return (_traceLevel);
        }

        public function set traceLevel(_arg_1:uint):void
        {
            if (_traceLevel != _arg_1)
            {
                _traceLevel = _arg_1;
                _ectx.call("setTraceLevel", _arg_1);
            };
        }

        public function get detectIntervalMillis():uint
        {
            return (_detectIntervalMillis);
        }

        public function set detectIntervalMillis(_arg_1:uint):void
        {
            if (_detectIntervalMillis != _arg_1)
            {
                _detectIntervalMillis = _arg_1;
                _ectx.call("setDetectDelay", _arg_1);
            };
        }

        public function get version():String
        {
            return (_ectx.call("getVersion"));
        }

        public function getCapabilities(_arg_1:uint, _arg_2:NativeJoystickCaps):void
        {
            _ectx.call("getCapabilities", _arg_1, _arg_2);
        }

        public function updateJoysticks():void
        {
            _ectx.call("updateJoysticks", _data);
        }

        public function get maxJoysticks():int
        {
            return (_maxDevs);
        }

        public function get analogThreshold():Number
        {
            return (_analogThreshold);
        }

        public function set analogThreshold(_arg_1:Number):void
        {
            if (_arg_1 < 0)
            {
                _arg_1 = 0;
            };
            if (_arg_1 > 1)
            {
                _arg_1 = 1;
            };
            _analogThreshold = _arg_1;
        }


    }
}//package com.iam2bam.ane.nativejoystick.intern


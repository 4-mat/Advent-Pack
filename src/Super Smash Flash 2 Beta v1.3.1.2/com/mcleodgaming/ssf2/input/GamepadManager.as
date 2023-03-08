// Decompiled by AS3 Sorcerer 6.20
// www.as3sorcerer.com

//com.mcleodgaming.ssf2.input.GamepadManager

package com.mcleodgaming.ssf2.input
{
    import com.iam2bam.ane.nativejoystick.intern.NativeJoystickMgr;
    import flash.ui.GameInput;
    import __AS3__.vec.Vector;
    import flash.system.Capabilities;
    import com.mcleodgaming.ssf2.Version;
    import flash.events.GameInputEvent;
    import flash.ui.GameInputControl;
    import flash.ui.GameInputDevice;
    import flash.events.Event;
    import com.iam2bam.ane.nativejoystick.event.NativeJoystickEvent;
    import com.iam2bam.ane.nativejoystick.NativeJoystick;
    import __AS3__.vec.*;

    public class GamepadManager 
    {

        protected static var m_nativeJoystick:NativeJoystickMgr;
        protected static var m_gameInput:GameInput;
        protected static var m_gamepadDeviceMap:Object;
        protected static var m_gamepadInstanceMap:Object;
        protected static var m_gamepadInstanceList:Vector.<Gamepad>;


        public static function init():void
        {
            GamepadManager.m_gamepadDeviceMap = {};
            GamepadManager.m_gamepadInstanceMap = {};
            GamepadManager.m_gamepadInstanceList = new Vector.<Gamepad>();
            if (((((true) && (!(false))) && (Version.supportedProfiles.indexOf("extendedDesktop") >= 0)) && (Capabilities.os.indexOf("Mac") < 0)))
            {
                GamepadManager.setupGameInputNative();
            }
            else
            {
                {
                    GamepadManager.setupGameInput();
                };
            };
        }

        protected static function setupGameInput():void
        {
            GamepadManager.m_gameInput = new GameInput();
            GamepadManager.m_gameInput.addEventListener(GameInputEvent.DEVICE_ADDED, GamepadManager.onDeviceAttached);
            GamepadManager.m_gameInput.addEventListener(GameInputEvent.DEVICE_REMOVED, GamepadManager.onDeviceRemoved);
            GamepadManager.m_gameInput.addEventListener(GameInputEvent.DEVICE_UNUSABLE, GamepadManager.onDeviceError);
        }

        protected static function onDeviceAttached(e:GameInputEvent):void
        {
            var i:int;
            var control:GameInputControl;
            var device:GameInputDevice = e.device;
            var identifier:String = (device.id + device.name);
            GamepadManager.m_gamepadDeviceMap[identifier] = device;
            var oldGamepads:Vector.<Gamepad> = getGamepads();
            var targetPort:int = 1;
            i = 0;
            while (i < oldGamepads.length)
            {
                if (((oldGamepads[i].Name === device.name) && (oldGamepads[i].Port === targetPort)))
                {
                    targetPort++;
                    i = -1;
                };
                i++;
            };
            var gamepad:Gamepad = ((m_gamepadInstanceMap[identifier]) ? m_gamepadInstanceMap[identifier] : new Gamepad(device.name, targetPort));
            m_gamepadInstanceMap[identifier] = gamepad;
            m_gamepadInstanceList.push(gamepad);
            device.enabled = true;
            i = 0;
            while (i < device.numControls)
            {
                control = device.getControlAt(i);
                control.addEventListener(Event.CHANGE, GamepadManager.onDeviceInput);
                Gamepad(m_gamepadInstanceMap[identifier]).registerInput(control.id, control.minValue, control.maxValue, control.value);
                i++;
            };
        }

        protected static function onDeviceInput(e:Event):void
        {
            var control:GameInputControl = GameInputControl(e.currentTarget);
            var device:GameInputDevice = control.device;
            var identifier:String = (device.id + device.name);
            var gamepad:Gamepad = Gamepad(m_gamepadInstanceMap[identifier]);
            if (gamepad)
            {
                gamepad.onDeviceInput(control.id, control.value);
            };
        }

        protected static function onDeviceRemoved(e:GameInputEvent):void
        {
            var control:GameInputControl;
            var device:GameInputDevice = e.device;
            var identifier:String = (device.id + device.name);
            var i:int;
            while (i < device.numControls)
            {
                control = device.getControlAt(i);
                control.removeEventListener(Event.CHANGE, Gamepad(m_gamepadInstanceMap[identifier]).onDeviceInput);
                i++;
            };
            m_gamepadInstanceList.splice(m_gamepadInstanceList.indexOf(m_gamepadDeviceMap[identifier]), 1);
            delete m_gamepadDeviceMap[(device.id + device.name)];
        }

        protected static function onDeviceError(e:GameInputEvent):void
        {
            trace("Device errroed");
        }

        public static function getGamepads():Vector.<Gamepad>
        {
            var gamepads:Vector.<Gamepad> = new Vector.<Gamepad>();
            var i:int;
            while (i < m_gamepadInstanceList.length)
            {
                gamepads.push(m_gamepadInstanceList[i]);
                i++;
            };
            return (gamepads);
        }

        protected static function setupGameInputNative():void
        {
            GamepadManager.m_nativeJoystick = new NativeJoystickMgr();
            GamepadManager.m_nativeJoystick.pollInterval = 20;
            GamepadManager.m_nativeJoystick.detectIntervalMillis = 500;
            GamepadManager.m_nativeJoystick.addEventListener(NativeJoystickEvent.JOY_PLUGGED, onDeviceAttachedNative);
            GamepadManager.m_nativeJoystick.addEventListener(NativeJoystickEvent.JOY_UNPLUGGED, onDeviceRemovedNative);
        }

        protected static function onDeviceAttachedNative(e:NativeJoystickEvent):void
        {
            var getCaps:Function = function ():void
            {
                var joyStick:NativeJoystick;
                var identifier:String;
                var i:int;
                var oldGamepads:Vector.<Gamepad>;
                var targetPort:int;
                var gamepad:Gamepad;
                try
                {
                    GamepadManager.m_nativeJoystick.getCapabilities(e.joystick.index, e.joystick.capabilities);
                }
                catch(err)
                {
                    return;
                };
                if (!(!(e.joystick.capabilities.numButtons)))
                {
                    joyStick = e.joystick;
                    identifier = (((joyStick.capabilities.oemName) || ("Generic Device")) + joyStick.index);
                    GamepadManager.m_gamepadDeviceMap[identifier] = joyStick;
                    oldGamepads = getGamepads();
                    targetPort = 1;
                    i = 0;
                    while (i < oldGamepads.length)
                    {
                        if (((oldGamepads[i].Name === ((joyStick.capabilities.oemName) || ("Generic Device"))) && (oldGamepads[i].Port === targetPort)))
                        {
                            targetPort = (targetPort + 1);
                            i = -1;
                        };
                        i = (i + 1);
                    };
                    gamepad = ((m_gamepadInstanceMap[identifier]) ? m_gamepadInstanceMap[identifier] : new Gamepad(((joyStick.capabilities.oemName) || ("Generic Device")), targetPort));
                    m_gamepadInstanceMap[identifier] = gamepad;
                    m_gamepadInstanceList.unshift(gamepad);
                    GamepadManager.m_nativeJoystick.addEventListener(NativeJoystickEvent.BUTTON_DOWN, onNativeDeviceInput);
                    GamepadManager.m_nativeJoystick.addEventListener(NativeJoystickEvent.BUTTON_UP, onNativeDeviceInput);
                    GamepadManager.m_nativeJoystick.addEventListener(NativeJoystickEvent.AXIS_MOVE, onNativeDeviceInput);
                    i = 0;
                    while (i < joyStick.numButtons)
                    {
                        Gamepad(m_gamepadInstanceMap[identifier]).registerInput(("BUTTON_" + i), 0, 1, 0);
                        i = (i + 1);
                    };
                    try
                    {
                        i = 0;
                        while (i < e.joystick.capabilities.axesRange.length)
                        {
                            if ((!(e.joystick.hasAxis(i))))
                            {
                            }
                            else
                            {
                                Gamepad(m_gamepadInstanceMap[identifier]).registerInput(("AXIS_" + i), -1, 1, 0);
                            };
                            i = (i + 1);
                        };
                    }
                    catch(e:RangeError)
                    {
                    }
                    catch(e:Error)
                    {
                        trace(e);
                    };
                    fixNativePortOrder();
                };
            };
            (getCaps());
        }

        protected static function fixNativePortOrder():void
        {
            var ports:Object = {};
            var i:int;
            while (i < m_gamepadInstanceList.length)
            {
                ports[m_gamepadInstanceList[i].Name] = ((ports[m_gamepadInstanceList[i].Name]) || (0));
                ports[m_gamepadInstanceList[i].Name]++;
                m_gamepadInstanceList[i].Port = ports[m_gamepadInstanceList[i].Name];
                i++;
            };
        }

        protected static function onNativeDeviceInput(e:NativeJoystickEvent):void
        {
            var gamepad:Gamepad;
            var joyStick:NativeJoystick = e.joystick;
            var identifier:String = (((joyStick.capabilities.oemName) || ("Generic Device")) + joyStick.index);
            if (m_gamepadDeviceMap[identifier])
            {
                gamepad = m_gamepadInstanceMap[identifier];
                if (e.type === NativeJoystickEvent.BUTTON_DOWN)
                {
                    gamepad.onDeviceInput(("BUTTON_" + e.buttonIndex), 1);
                }
                else
                {
                    if (e.type === NativeJoystickEvent.BUTTON_UP)
                    {
                        gamepad.onDeviceInput(("BUTTON_" + e.buttonIndex), 0);
                    }
                    else
                    {
                        if (e.type === NativeJoystickEvent.AXIS_MOVE)
                        {
                            gamepad.onDeviceInput(("AXIS_" + e.axisIndex), e.axisValue);
                        };
                    };
                };
            };
        }

        protected static function onDeviceRemovedNative(e:NativeJoystickEvent):void
        {
            var joyStick:NativeJoystick = e.joystick;
            var identifier:String = (((joyStick.capabilities.oemName) || ("Generic Device")) + joyStick.index);
            GamepadManager.m_nativeJoystick.removeEventListener(NativeJoystickEvent.BUTTON_DOWN, onNativeDeviceInput);
            GamepadManager.m_nativeJoystick.removeEventListener(NativeJoystickEvent.BUTTON_UP, onNativeDeviceInput);
            GamepadManager.m_nativeJoystick.removeEventListener(NativeJoystickEvent.AXIS_MOVE, onNativeDeviceInput);
            m_gamepadInstanceList.splice(m_gamepadInstanceList.indexOf(m_gamepadDeviceMap[identifier]), 1);
            delete m_gamepadDeviceMap[identifier];
        }


    }
}//package com.mcleodgaming.ssf2.input


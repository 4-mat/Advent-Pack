// Decompiled by AS3 Sorcerer 6.20
// www.as3sorcerer.com

//com.mcleodgaming.ssf2.input.Gamepad

package com.mcleodgaming.ssf2.input
{
    import flash.events.EventDispatcher;
    import com.mcleodgaming.ssf2.events.GamepadEvent;
    import com.mcleodgaming.ssf2.util.Utils;

    public class Gamepad extends EventDispatcher 
    {

        public static const DEADZONE_DEFAULT:Number = 0.2;
        public static const DASHZONE_DEFAULT:Number = 0.7;

        protected var m_controlState:Object;
        protected var m_controlsList:Array;
        protected var m_controlsMap:Object;
        protected var m_name:String;
        protected var m_port:int;

        public function Gamepad(name:String, port:int):void
        {
            this.m_controlState = {};
            this.m_controlsList = [];
            this.m_controlsMap = {};
            this.m_name = name;
            this.m_port = port;
            this.resetControlsMap();
        }

        public function get Name():String
        {
            return (this.m_name);
        }

        public function get Port():int
        {
            return (this.m_port);
        }

        public function set Port(port:int):void
        {
            this.m_port = port;
        }

        public function get ControlsMap():Object
        {
            return (this.m_controlsMap);
        }

        public function get ControlState():Object
        {
            return (this.m_controlState);
        }

        public function get ControlsList():Array
        {
            return (this.m_controlsList);
        }

        private function resetInputs():void
        {
            var i:*;
            for (i in this.m_controlState)
            {
                this.m_controlState[i].inputs = [];
                this.m_controlState[i].inputsInverse = [];
            };
        }

        private function resetControlsMap():void
        {
            this.m_controlsMap["SHIELD"] = 0;
            this.m_controlsMap["TAUNT"] = 0;
            this.m_controlsMap["START"] = 0;
            this.m_controlsMap["GRAB"] = 0;
            this.m_controlsMap["BUTTON2"] = 0;
            this.m_controlsMap["BUTTON1"] = 0;
            this.m_controlsMap["JUMP"] = 0;
            this.m_controlsMap["RIGHT"] = 0;
            this.m_controlsMap["LEFT"] = 0;
            this.m_controlsMap["DOWN"] = 0;
            this.m_controlsMap["UP"] = 0;
            this.m_controlsMap["DASH"] = 0;
            this.m_controlsMap["C_RIGHT"] = 0;
            this.m_controlsMap["C_LEFT"] = 0;
            this.m_controlsMap["C_DOWN"] = 0;
            this.m_controlsMap["C_UP"] = 0;
            this.m_controlsMap["JUMP2"] = 0;
            this.m_controlsMap["SHIELD2"] = 0;
            this.m_controlsMap["TAP_JUMP"] = 1;
            this.m_controlsMap["AUTO_DASH"] = 0;
            this.m_controlsMap["DT_DASH"] = 1;
        }

        public function registerInput(id:String, minValue:Number, maxValue:Number, value:Number):void
        {
            if ((!(this.m_controlState[id])))
            {
                this.m_controlState[id] = {
                    "id":id,
                    "index":this.m_controlsList.length,
                    "type":((minValue < 0) ? "axis" : "button"),
                    "minValue":minValue,
                    "maxValue":maxValue,
                    "prevValue":0,
                    "value":value,
                    "deadZone":Gamepad.DEADZONE_DEFAULT,
                    "dashZone":Gamepad.DASHZONE_DEFAULT,
                    "inputs":[],
                    "inputsInverse":[]
                };
                this.m_controlsList.push(this.m_controlState[id]);
            };
        }

        private function checkAxis(state:Object, axisRange:Number, callback:Function):void
        {
            var evt:GamepadEvent;
            if (state.value > (state.maxValue * axisRange))
            {
                if (state.prevValue <= (state.maxValue * axisRange))
                {
                    evt = new GamepadEvent(GamepadEvent.AXIS_CHANGED);
                    evt.gamepad = this;
                    evt.controlState = state;
                    (callback(state, state.inputs, true));
                    dispatchEvent(evt);
                };
            }
            else
            {
                if (state.value <= (state.minValue * axisRange))
                {
                    if (state.prevValue > (state.minValue * axisRange))
                    {
                        evt = new GamepadEvent(GamepadEvent.AXIS_CHANGED);
                        evt.gamepad = this;
                        evt.controlState = state;
                        (callback(state, state.inputsInverse, true));
                        dispatchEvent(evt);
                    };
                };
            };
            if (state.value <= (state.maxValue * axisRange))
            {
                if (state.prevValue > (state.maxValue * axisRange))
                {
                    evt = new GamepadEvent(GamepadEvent.AXIS_CHANGED);
                    evt.gamepad = this;
                    evt.controlState = state;
                    (callback(state, state.inputs, false));
                    dispatchEvent(evt);
                };
            };
            if (state.value >= (state.minValue * axisRange))
            {
                if (state.prevValue < (state.minValue * axisRange))
                {
                    evt = new GamepadEvent(GamepadEvent.AXIS_CHANGED);
                    evt.gamepad = this;
                    evt.controlState = state;
                    (callback(state, state.inputsInverse, false));
                    dispatchEvent(evt);
                };
            };
        }

        private function handleDeadZone(state:Object, inputs:Array, status:Boolean):void
        {
            this.toggleControl(inputs, status);
        }

        private function handleDashZone(state:Object, inputs:Array, status:Boolean):void
        {
            if (this.m_controlsMap["AUTO_DASH"])
            {
                return;
            };
            var i:int;
            while (i < inputs.length)
            {
                if ((((inputs[i] === "LEFT") || (inputs[i] === "RIGHT")) || (inputs[i] === "DOWN")))
                {
                    this.toggleControl(["DASH"], status);
                };
                i++;
            };
        }

        private function toggleControl(inputs:Array, status:Boolean):void
        {
            var statusStr:String = ((status) ? "on: " : "off: ");
            var i:int;
            while (i < inputs.length)
            {
                this.m_controlsMap[inputs[i]] = ((status) ? 1 : 0);
                i++;
            };
        }

        public function onDeviceInput(id:String, value:Number):void
        {
            var i:int;
            var evt:GamepadEvent;
            var state:Object = this.m_controlState[id];
            if ((!(state)))
            {
                return;
            };
            state.value = value;
            if (state.type === "axis")
            {
                this.checkAxis(state, state.deadZone, this.handleDeadZone);
                this.checkAxis(state, state.dashZone, this.handleDashZone);
            }
            else
            {
                if (((state.value) && (!(state.prevValue))))
                {
                    evt = new GamepadEvent(GamepadEvent.BUTTON_DOWN);
                    evt.gamepad = this;
                    evt.controlState = state;
                    this.toggleControl(state.inputs, true);
                    dispatchEvent(evt);
                }
                else
                {
                    if (((!(state.value)) && (state.prevValue)))
                    {
                        evt = new GamepadEvent(GamepadEvent.BUTTON_UP);
                        evt.gamepad = this;
                        evt.controlState = state;
                        this.toggleControl(state.inputs, false);
                        dispatchEvent(evt);
                    };
                };
            };
            state.prevValue = state.value;
        }

        public function isPressed(id:String):Boolean
        {
            return ((this.getState(id) !== 0) ? true : false);
        }

        public function getState(id:String):Number
        {
            return (this.m_controlsMap[id]);
        }

        public function setControl(id:String, input:String, inverse:Boolean=false):void
        {
            var control:Object = this.m_controlState[id];
            if ((!(control)))
            {
                return;
            };
            if (control.type === "axis")
            {
                if (inverse)
                {
                    if (control.inputsInverse.indexOf(input) < 0)
                    {
                        control.inputsInverse.push(input);
                    };
                }
                else
                {
                    if (control.inputs.indexOf(input) < 0)
                    {
                        control.inputs.push(input);
                    };
                };
            }
            else
            {
                if (control.inputs.indexOf(input) < 0)
                {
                    control.inputs.push(input);
                };
            };
        }

        public function unsetControl(id:String, input:String, inverse:Boolean=false):void
        {
            var index:int;
            var control:Object = this.m_controlState[id];
            if ((!(control)))
            {
                return;
            };
            if (control.type === "axis")
            {
                if (inverse)
                {
                    index = control.inputsInverse.indexOf(input);
                    this.m_controlsMap[control.inputsInverse[index]] = 0;
                    control.inputsInverse.splice(index, 1);
                }
                else
                {
                    index = control.inputs.indexOf(input);
                    this.m_controlsMap[control.inputs[index]] = 0;
                    control.inputs.splice(index, 1);
                };
            }
            else
            {
                index = control.inputs.indexOf(input);
                this.m_controlsMap[control.inputs[index]] = 0;
                control.inputs.splice(index, 1);
            };
        }

        public function exportControls():Object
        {
            return (null);
        }

        public function importControls(obj:Object):void
        {
            var inputNameKey:*;
            var controlIndex:*;
            this.resetControlsMap();
            this.resetInputs();
            if (obj)
            {
                for (inputNameKey in obj)
                {
                    if (["TAP_JUMP", "AUTO_DASH", "DT_DASH"].indexOf(inputNameKey) >= 0)
                    {
                        this.m_controlsMap[inputNameKey] = obj[inputNameKey];
                    }
                    else
                    {
                        for (controlIndex in obj[inputNameKey].inputs)
                        {
                            this.setControl(inputNameKey, obj[inputNameKey].inputs[controlIndex], false);
                        };
                        for (controlIndex in obj[inputNameKey].inputsInverse)
                        {
                            this.setControl(inputNameKey, obj[inputNameKey].inputsInverse[controlIndex], true);
                        };
                        if (obj[inputNameKey].dashZone)
                        {
                            if (this.m_controlState[inputNameKey])
                            {
                                this.m_controlState[inputNameKey].dashZone = obj[inputNameKey].dashZone;
                                this.m_controlState[inputNameKey].deadZone = obj[inputNameKey].deadZone;
                            }
                            else
                            {
                                this.m_controlState[inputNameKey] = Utils.copyObject(obj[inputNameKey]);
                                this.m_controlState[inputNameKey] = Utils.copyObject(obj[inputNameKey]);
                            };
                        };
                    };
                };
            };
        }


    }
}//package com.mcleodgaming.ssf2.input


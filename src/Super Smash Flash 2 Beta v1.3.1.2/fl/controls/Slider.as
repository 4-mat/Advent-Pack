// Decompiled by AS3 Sorcerer 6.30
// www.as3sorcerer.com

//fl.controls.Slider

package fl.controls
{
    import fl.core.UIComponent;
    import fl.managers.IFocusManagerComponent;
    import flash.display.Sprite;
    import fl.core.InvalidationType;
    import fl.events.InteractionInputType;
    import fl.events.SliderEvent;
    import flash.display.DisplayObject;
    import fl.events.SliderEventClickTarget;
    import flash.events.MouseEvent;
    import flash.display.DisplayObjectContainer;
    import flash.ui.Keyboard;
    import flash.events.KeyboardEvent;

    [Event(name="thumbPress", type="fl.events.SliderEvent")]
    [Event(name="thumbRelease", type="fl.events.SliderEvent")]
    [Event(name="thumbDrag", type="fl.events.SliderEvent")]
    [Event(name="change", type="fl.events.SliderEvent")]
    [Style(name="thumbUpSkin", type="Class")]
    [Style(name="thumbOverSkin", type="Class")]
    [Style(name="thumbDownSkin", type="Class")]
    [Style(name="thumbDisabledSkin", type="Class")]
    [Style(name="sliderTrackSkin", type="Class")]
    [Style(name="sliderTrackDisabledSkin", type="Class")]
    [Style(name="tickSkin", type="Class")]
    public class Slider extends UIComponent implements IFocusManagerComponent 
    {

        protected static var defaultStyles:Object = {
            "thumbUpSkin":"SliderThumb_upSkin",
            "thumbOverSkin":"SliderThumb_overSkin",
            "thumbDownSkin":"SliderThumb_downSkin",
            "thumbDisabledSkin":"SliderThumb_disabledSkin",
            "sliderTrackSkin":"SliderTrack_skin",
            "sliderTrackDisabledSkin":"SliderTrack_disabledSkin",
            "tickSkin":"SliderTick_skin",
            "focusRectSkin":null,
            "focusRectPadding":null
        };
        protected static const TRACK_STYLES:Object = {
            "upSkin":"sliderTrackSkin",
            "overSkin":"sliderTrackSkin",
            "downSkin":"sliderTrackSkin",
            "disabledSkin":"sliderTrackDisabledSkin"
        };
        protected static const THUMB_STYLES:Object = {
            "upSkin":"thumbUpSkin",
            "overSkin":"thumbOverSkin",
            "downSkin":"thumbDownSkin",
            "disabledSkin":"thumbDisabledSkin"
        };
        protected static const TICK_STYLES:Object = {"upSkin":"tickSkin"};

        protected var _direction:String = SliderDirection.HORIZONTAL;
        protected var _minimum:Number = 0;
        protected var _maximum:Number = 10;
        protected var _value:Number = 0;
        protected var _tickInterval:Number = 0;
        protected var _snapInterval:Number = 0;
        protected var _liveDragging:Boolean = false;
        protected var tickContainer:Sprite;
        protected var thumb:BaseButton;
        protected var track:BaseButton;

        public function Slider()
        {
            this.setStyles();
        }

        public static function getStyleDefinition():Object
        {
            return (defaultStyles);
        }


        [Inspectable(enumeration="horizontal,vertical", defaultValue="horizontal")]
        public function get direction():String
        {
            return (this._direction);
        }

        public function set direction(_arg_1:String):void
        {
            this._direction = _arg_1;
            var _local_2:Boolean = (this._direction == SliderDirection.VERTICAL);
            if (isLivePreview)
            {
                if (_local_2)
                {
                    setScaleY(-1);
                    y = this.track.height;
                }
                else
                {
                    setScaleY(1);
                    y = 0;
                };
                this.positionThumb();
                return;
            };
            if (((_local_2) && (componentInspectorSetting)))
            {
                if ((rotation % 90) == 0)
                {
                    setScaleY(-1);
                };
            };
            if ((!(componentInspectorSetting)))
            {
                rotation = ((_local_2) ? 90 : 0);
            };
        }

        [Inspectable(defaultValue="0")]
        public function get minimum():Number
        {
            return (this._minimum);
        }

        public function set minimum(_arg_1:Number):void
        {
            this._minimum = _arg_1;
            this.value = Math.max(_arg_1, this.value);
            invalidate(InvalidationType.DATA);
        }

        [Inspectable(defaultValue="10")]
        public function get maximum():Number
        {
            return (this._maximum);
        }

        public function set maximum(_arg_1:Number):void
        {
            this._maximum = _arg_1;
            this.value = Math.min(_arg_1, this.value);
            invalidate(InvalidationType.DATA);
        }

        [Inspectable(defaultValue="0")]
        public function get tickInterval():Number
        {
            return (this._tickInterval);
        }

        public function set tickInterval(_arg_1:Number):void
        {
            this._tickInterval = _arg_1;
            invalidate(InvalidationType.SIZE);
        }

        [Inspectable(defaultValue="0")]
        public function get snapInterval():Number
        {
            return (this._snapInterval);
        }

        public function set snapInterval(_arg_1:Number):void
        {
            this._snapInterval = _arg_1;
        }

        [Inspectable(defaultValue="false")]
        public function set liveDragging(_arg_1:Boolean):void
        {
            this._liveDragging = _arg_1;
        }

        public function get liveDragging():Boolean
        {
            return (this._liveDragging);
        }

        [Inspectable(defaultValue="true", verbose="1")]
        override public function get enabled():Boolean
        {
            return (super.enabled);
        }

        override public function set enabled(_arg_1:Boolean):void
        {
            if (this.enabled == _arg_1)
            {
                return;
            };
            super.enabled = _arg_1;
            this.track.enabled = (this.thumb.enabled = _arg_1);
        }

        override public function setSize(_arg_1:Number, _arg_2:Number):void
        {
            if (((this._direction == SliderDirection.VERTICAL) && (!(isLivePreview))))
            {
                super.setSize(_arg_2, _arg_1);
            }
            else
            {
                super.setSize(_arg_1, _arg_2);
            };
            invalidate(InvalidationType.SIZE);
        }

        [Inspectable(defaultValue="0")]
        public function get value():Number
        {
            return (this._value);
        }

        public function set value(_arg_1:Number):void
        {
            this.doSetValue(_arg_1);
        }

        protected function doSetValue(_arg_1:Number, _arg_2:String=null, _arg_3:String=null, _arg_4:int=undefined):void
        {
            var _local_6:Number;
            var _local_7:Number;
            var _local_8:Number;
            var _local_9:Number;
            var _local_5:Number = this._value;
            if (((!(this._snapInterval == 0)) && (!(this._snapInterval == 1))))
            {
                _local_6 = Math.pow(10, this.getPrecision(this.snapInterval));
                _local_7 = (this._snapInterval * _local_6);
                _local_8 = Math.round((_arg_1 * _local_6));
                _local_9 = (Math.round((_local_8 / _local_7)) * _local_7);
                _arg_1 = (_local_9 / _local_6);
                this._value = Math.max(this.minimum, Math.min(this.maximum, _arg_1));
            }
            else
            {
                this._value = Math.max(this.minimum, Math.min(this.maximum, Math.round(_arg_1)));
            };
            if (((!(_local_5 == this._value)) && (((this.liveDragging) && (!(_arg_3 == null))) || (_arg_2 == InteractionInputType.KEYBOARD))))
            {
                dispatchEvent(new SliderEvent(SliderEvent.CHANGE, this.value, _arg_3, _arg_2, _arg_4));
            };
            this.positionThumb();
        }

        protected function setStyles():void
        {
            copyStylesToChild(this.thumb, THUMB_STYLES);
            copyStylesToChild(this.track, TRACK_STYLES);
        }

        override protected function draw():void
        {
            if (isInvalid(InvalidationType.STYLES))
            {
                this.setStyles();
                invalidate(InvalidationType.SIZE, false);
            };
            if (isInvalid(InvalidationType.SIZE))
            {
                this.track.setSize(_width, this.track.height);
                this.track.drawNow();
                this.thumb.drawNow();
            };
            if (this.tickInterval > 0)
            {
                this.drawTicks();
            }
            else
            {
                this.clearTicks();
            };
            this.positionThumb();
            super.draw();
        }

        protected function positionThumb():void
        {
            this.thumb.x = ((((this._direction == SliderDirection.VERTICAL) ? (this.maximum - this.value) : (this.value - this.minimum)) / (this.maximum - this.minimum)) * _width);
        }

        protected function drawTicks():void
        {
            var _local_5:DisplayObject;
            this.clearTicks();
            this.tickContainer = new Sprite();
            var _local_1:Number = ((this.maximum < 1) ? (this.tickInterval / 100) : this.tickInterval);
            var _local_2:Number = ((this.maximum - this.minimum) / _local_1);
            var _local_3:Number = (_width / _local_2);
            var _local_4:uint;
            while (_local_4 <= _local_2)
            {
                _local_5 = getDisplayObjectInstance(getStyleValue("tickSkin"));
                _local_5.x = (_local_3 * _local_4);
                _local_5.y = ((this.track.y - _local_5.height) - 2);
                this.tickContainer.addChild(_local_5);
                _local_4++;
            };
            addChild(this.tickContainer);
        }

        protected function clearTicks():void
        {
            if (((!(this.tickContainer)) || (!(this.tickContainer.parent))))
            {
                return;
            };
            removeChild(this.tickContainer);
        }

        protected function calculateValue(_arg_1:Number, _arg_2:String, _arg_3:String, _arg_4:int=undefined):void
        {
            var _local_5:Number = ((_arg_1 / _width) * (this.maximum - this.minimum));
            if (this._direction == SliderDirection.VERTICAL)
            {
                _local_5 = (this.maximum - _local_5);
            }
            else
            {
                _local_5 = (this.minimum + _local_5);
            };
            this.doSetValue(_local_5, _arg_2, _arg_3, _arg_4);
        }

        protected function doDrag(_arg_1:MouseEvent):void
        {
            var _local_2:Number = (_width / this.snapInterval);
            var _local_3:Number = this.track.mouseX;
            this.calculateValue(_local_3, InteractionInputType.MOUSE, SliderEventClickTarget.THUMB);
            dispatchEvent(new SliderEvent(SliderEvent.THUMB_DRAG, this.value, SliderEventClickTarget.THUMB, InteractionInputType.MOUSE));
        }

        protected function thumbPressHandler(_arg_1:MouseEvent):void
        {
            var _local_2:DisplayObjectContainer = focusManager.form;
            _local_2.addEventListener(MouseEvent.MOUSE_MOVE, this.doDrag, false, 0, true);
            _local_2.addEventListener(MouseEvent.MOUSE_UP, this.thumbReleaseHandler, false, 0, true);
            dispatchEvent(new SliderEvent(SliderEvent.THUMB_PRESS, this.value, SliderEventClickTarget.THUMB, InteractionInputType.MOUSE));
        }

        protected function thumbReleaseHandler(_arg_1:MouseEvent):void
        {
            var _local_2:DisplayObjectContainer = focusManager.form;
            _local_2.removeEventListener(MouseEvent.MOUSE_MOVE, this.doDrag);
            _local_2.removeEventListener(MouseEvent.MOUSE_UP, this.thumbReleaseHandler);
            dispatchEvent(new SliderEvent(SliderEvent.THUMB_RELEASE, this.value, SliderEventClickTarget.THUMB, InteractionInputType.MOUSE));
            dispatchEvent(new SliderEvent(SliderEvent.CHANGE, this.value, SliderEventClickTarget.THUMB, InteractionInputType.MOUSE));
        }

        protected function onTrackClick(_arg_1:MouseEvent):void
        {
            this.calculateValue(this.track.mouseX, InteractionInputType.MOUSE, SliderEventClickTarget.TRACK);
            if ((!(this.liveDragging)))
            {
                dispatchEvent(new SliderEvent(SliderEvent.CHANGE, this.value, SliderEventClickTarget.TRACK, InteractionInputType.MOUSE));
            };
        }

        override protected function keyDownHandler(_arg_1:KeyboardEvent):void
        {
            var _local_3:Number;
            if ((!(this.enabled)))
            {
                return;
            };
            var _local_2:Number = ((this.snapInterval > 0) ? this.snapInterval : 1);
            var _local_4:Boolean = (this.direction == SliderDirection.HORIZONTAL);
            if ((((_arg_1.keyCode == Keyboard.DOWN) && (!(_local_4))) || ((_arg_1.keyCode == Keyboard.LEFT) && (_local_4))))
            {
                _local_3 = (this.value - _local_2);
            }
            else
            {
                if ((((_arg_1.keyCode == Keyboard.UP) && (!(_local_4))) || ((_arg_1.keyCode == Keyboard.RIGHT) && (_local_4))))
                {
                    _local_3 = (this.value + _local_2);
                }
                else
                {
                    if ((((_arg_1.keyCode == Keyboard.PAGE_DOWN) && (!(_local_4))) || ((_arg_1.keyCode == Keyboard.HOME) && (_local_4))))
                    {
                        _local_3 = this.minimum;
                    }
                    else
                    {
                        if ((((_arg_1.keyCode == Keyboard.PAGE_UP) && (!(_local_4))) || ((_arg_1.keyCode == Keyboard.END) && (_local_4))))
                        {
                            _local_3 = this.maximum;
                        };
                    };
                };
            };
            if ((!(isNaN(_local_3))))
            {
                _arg_1.stopPropagation();
                this.doSetValue(_local_3, InteractionInputType.KEYBOARD, null, _arg_1.keyCode);
            };
        }

        override protected function configUI():void
        {
            super.configUI();
            this.thumb = new BaseButton();
            this.thumb.setSize(13, 13);
            this.thumb.autoRepeat = false;
            addChild(this.thumb);
            this.thumb.addEventListener(MouseEvent.MOUSE_DOWN, this.thumbPressHandler, false, 0, true);
            this.track = new BaseButton();
            this.track.move(0, 0);
            this.track.setSize(80, 4);
            this.track.autoRepeat = false;
            this.track.useHandCursor = false;
            this.track.addEventListener(MouseEvent.CLICK, this.onTrackClick, false, 0, true);
            addChildAt(this.track, 0);
        }

        protected function getPrecision(_arg_1:Number):Number
        {
            var _local_2:String = _arg_1.toString();
            if (_local_2.indexOf(".") == -1)
            {
                return (0);
            };
            return (_local_2.split(".").pop().length);
        }


    }
}//package fl.controls


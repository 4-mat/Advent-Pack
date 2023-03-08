// Decompiled by AS3 Sorcerer 6.30
// www.as3sorcerer.com

//com.mcleodgaming.ssf2.platforms.Platform

package com.mcleodgaming.ssf2.platforms
{
    import com.mcleodgaming.ssf2.engine.InteractiveSprite;
    import flash.display.MovieClip;
    import __AS3__.vec.Vector;
    import com.mcleodgaming.ssf2.engine.StageData;
    import flash.geom.Point;
    import com.mcleodgaming.ssf2.enums.SpecialMode;
    import com.mcleodgaming.ssf2.engine.*;
    import __AS3__.vec.*;

    public class Platform extends BitmapCollisionBoundary 
    {

        protected var m_spriteOwner:InteractiveSprite;
        protected var m_platform:MovieClip;
        protected var m_ignoreList:Vector.<InteractiveSprite>;
        protected var m_inversedIgnoreList:Boolean;
        protected var m_x_start:Number;
        protected var m_y_start:Number;
        protected var m_x_prev:Number;
        protected var m_y_prev:Number;

        public function Platform(mc:MovieClip, stageData:StageData, instance:String="ground", useRectangle:Boolean=false)
        {
            super(mc, stageData, instance, useRectangle);
            this.m_platform = m_collisionClipContainer;
            this.m_spriteOwner = null;
            this.m_ignoreList = new Vector.<InteractiveSprite>();
            this.m_inversedIgnoreList = false;
            this.m_x_start = this.m_platform.x;
            this.m_y_start = this.m_platform.y;
            this.m_x_prev = this.m_platform.x;
            this.m_y_prev = this.m_platform.y;
            this.m_x_prev = 0;
            this.m_y_prev = 0;
            this.storeOldLocation();
        }

        public function faceRight():void
        {
            this.m_platform.scaleX = Math.abs(this.m_platform.scaleX);
        }

        public function faceLeft():void
        {
            this.m_platform.scaleX = -(Math.abs(this.m_platform.scaleX));
        }

        public function get SpriteOwner():InteractiveSprite
        {
            return (this.m_spriteOwner);
        }

        public function set SpriteOwner(owner:InteractiveSprite):void
        {
            this.m_spriteOwner = owner;
        }

        public function get IgnoreList():Vector.<InteractiveSprite>
        {
            return (this.m_ignoreList);
        }

        public function get PreviousX():Number
        {
            return (this.m_x_prev);
        }

        public function get PreviousY():Number
        {
            return (this.m_y_prev);
        }

        public function getStartPosition():Point
        {
            return (new Point(this.m_x_start, this.m_y_start));
        }

        public function setStartPosition(point:Point):void
        {
            this.m_x_start = point.x;
            this.m_y_start = point.y;
        }

        public function get foreground():String
        {
            return ((m_collisionClipContainer.foreground) || (null));
        }

        public function set foreground(value:String):void
        {
            m_collisionClipContainer.foreground = value;
        }

        public function get fallthrough():Boolean
        {
            return (m_collisionClipContainer.fallthrough == true);
        }

        public function set fallthrough(value:Boolean):void
        {
            m_collisionClipContainer.fallthrough = value;
        }

        public function get noDropThrough():Boolean
        {
            return (m_collisionClipContainer.noDropThrough == true);
        }

        public function set noDropThrough(value:Boolean):void
        {
            m_collisionClipContainer.noDropThrough = value;
        }

        public function get accel_friction():Number
        {
            if (SpecialMode.modeEnabled(STAGEDATA.GameRef.LevelData.specialModes, SpecialMode.SSF1))
            {
                return ((m_collisionClipContainer.accel_friction != undefined) ? (m_collisionClipContainer.accel_friction * 0.6) : 1);
            };
            return ((m_collisionClipContainer.accel_friction != undefined) ? m_collisionClipContainer.accel_friction : 1);
        }

        public function set accel_friction(value:Number):void
        {
            m_collisionClipContainer.accel_friction = value;
        }

        public function get decel_friction():Number
        {
            if ((((SpecialMode.modeEnabled(STAGEDATA.GameRef.LevelData.specialModes, SpecialMode.SSF1)) && (m_collisionClipContainer.decel_friction)) && (m_collisionClipContainer.decel_friction < 0)))
            {
                return ((m_collisionClipContainer.decel_friction != undefined) ? (m_collisionClipContainer.decel_friction * 0.6) : 1);
            };
            return ((m_collisionClipContainer.decel_friction != undefined) ? m_collisionClipContainer.decel_friction : 1);
        }

        public function set decel_friction(value:Number):void
        {
            m_collisionClipContainer.decel_friction = value;
        }

        public function get x_influence():Number
        {
            return ((m_collisionClipContainer.x_influence) ? m_collisionClipContainer.x_influence : 0);
        }

        public function set x_influence(value:Number):void
        {
            m_collisionClipContainer.x_influence = value;
        }

        public function get danger():Boolean
        {
            return (m_collisionClipContainer.danger == true);
        }

        public function set danger(value:Boolean):void
        {
            m_collisionClipContainer.danger = value;
        }

        public function get bounce_speed():Number
        {
            return ((m_collisionClipContainer.bounce_speed > 0) ? m_collisionClipContainer.bounce_speed : 0);
        }

        public function set bounce_speed(value:Number):void
        {
            m_collisionClipContainer.bounce_speed = value;
        }

        public function get conserve_horizontal_momentum():Boolean
        {
            return (m_collisionClipContainer.conserve_horizontal_momentum == true);
        }

        public function set conserve_horizontal_momentum(value:Boolean):void
        {
            m_collisionClipContainer.conserve_horizontal_momentum = value;
        }

        public function get conserve_upward_momentum():Boolean
        {
            return (m_collisionClipContainer.conserve_upward_momentum == true);
        }

        public function set conserve_upward_momentum(value:Boolean):void
        {
            m_collisionClipContainer.conserve_upward_momentum = value;
        }

        public function get conserve_downward_momentum():Boolean
        {
            return (m_collisionClipContainer.conserve_downward_momentum == true);
        }

        public function set conserve_downward_momentum(value:Boolean):void
        {
            m_collisionClipContainer.conserve_downward_momentum = value;
        }

        public function setAlpha(val:Number):void
        {
            m_collisionClipContainer.alpha = val;
        }

        public function setCamFocus(value:Boolean):void
        {
            STAGEDATA.CamRef.addForcedTarget(this.m_platform);
        }

        public function getX():Number
        {
            return (this.m_platform.x);
        }

        public function setX(value:Number):void
        {
            this.m_platform.x = value;
        }

        public function getY():Number
        {
            return (this.m_platform.y);
        }

        public function setY(value:Number):void
        {
            this.m_platform.y = value;
        }

        public function setIgnoreObjectListInversed(inversed:Boolean):void
        {
            this.m_inversedIgnoreList = inversed;
        }

        public function shouldIgnore(sprite:InteractiveSprite):Boolean
        {
            if (this.m_ignoreList.length === 0)
            {
                return (false);
            };
            if (this.m_inversedIgnoreList)
            {
                return (this.m_ignoreList.indexOf(sprite) < 0);
            };
            return (this.m_ignoreList.indexOf(sprite) >= 0);
        }

        public function storeOldLocation():void
        {
            this.m_x_prev = this.m_platform.x;
            this.m_y_prev = this.m_platform.y;
        }

        override public function destroy():void
        {
            m_dead = true;
            this.fallthrough = true;
            if (this.m_platform.parent)
            {
                this.m_platform.parent.removeChild(this.m_platform);
            };
            STAGEDATA.removePlatform(this);
        }

        override public function PERFORMALL():void
        {
            this.storeOldLocation();
        }


    }
}//package com.mcleodgaming.ssf2.platforms


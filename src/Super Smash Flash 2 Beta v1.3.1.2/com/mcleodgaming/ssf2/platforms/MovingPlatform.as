// Decompiled by AS3 Sorcerer 6.30
// www.as3sorcerer.com

//com.mcleodgaming.ssf2.platforms.MovingPlatform

package com.mcleodgaming.ssf2.platforms
{
    import flash.display.MovieClip;
    import flash.geom.Point;
    import __AS3__.vec.Vector;
    import com.mcleodgaming.ssf2.util.FrameTimer;
    import com.mcleodgaming.ssf2.api.SSF2Platform;
    import com.mcleodgaming.ssf2.util.ResourceManager;
    import com.mcleodgaming.ssf2.engine.StageData;
    import com.mcleodgaming.ssf2.engine.InteractiveSprite;
    import com.mcleodgaming.ssf2.enemies.*;
    import com.mcleodgaming.ssf2.engine.*;
    import com.mcleodgaming.ssf2.util.*;
    import com.mcleodgaming.ssf2.api.*;
    import __AS3__.vec.*;

    public class MovingPlatform extends Platform 
    {

        protected var m_foregroundPiece:MovieClip;
        protected var m_foregroundPoint:Point;
        protected var m_disabled:Boolean;
        protected var m_ledges:Vector.<MovieClip>;
        protected var m_ledgePoints:Vector.<Point>;
        protected var m_ledgePointsPrev:Vector.<Point>;
        protected var m_findLedges:Boolean;
        protected var m_xSpeed:Number;
        protected var m_ySpeed:Number;
        private var m_moveTimer:FrameTimer;
        private var m_waitTimer:FrameTimer;
        private var m_wait:Boolean;
        private var m_platformMovement:Vector.<PlatformMovement>;
        private var m_moveIndex:int;
        private var m_xLoc:Number;
        private var m_yLoc:Number;

        public function MovingPlatform(mc:MovieClip, stageData:StageData, instance:String="ground", stats:Object=null)
        {
            if ((!(stats)))
            {
                stats = {};
            };
            if ((!(stats.classAPI)))
            {
                stats.classAPI = stageData.BASE_CLASSES.SSF2Platform;
            };
            m_apiInstance = new SSF2Platform(stats.classAPI, this);
            if ((!(mc)))
            {
                mc = ResourceManager.getLibraryMC(m_apiInstance.getOwnStats().linkage_id);
                stageData.StageRef.addChild(mc);
            };
            super(mc, stageData, instance);
            this.m_xSpeed = 0;
            this.m_ySpeed = 0;
            this.m_disabled = false;
            this.m_ledges = new Vector.<MovieClip>();
            this.m_ledgePoints = new Vector.<Point>();
            this.m_ledgePointsPrev = new Vector.<Point>();
            this.m_foregroundPiece = null;
            this.m_foregroundPoint = new Point();
            this.m_findLedges = (((m_apiInstance) && (!(typeof(m_apiInstance.getOwnStats().attachLedges) === "undefined"))) ? m_apiInstance.getOwnStats().attachLedges : true);
            this.m_platformMovement = new Vector.<PlatformMovement>();
            this.m_moveTimer = new FrameTimer(1);
            this.m_waitTimer = new FrameTimer(1);
            this.m_xSpeed = 0;
            this.m_ySpeed = 0;
            var i:int = 1;
            while (m_platform[("movement" + i)])
            {
                this.addMovement(m_platform[("movement" + i)]);
                i++;
            };
            this.m_moveIndex = ((m_platform.startIndex) ? m_platform.startIndex : this.m_moveIndex);
            this.m_wait = false;
            this.m_xLoc = m_platform.x;
            this.m_yLoc = m_platform.y;
            if (this.m_foregroundPiece != null)
            {
                this.m_foregroundPoint.x = this.m_foregroundPiece.x;
                this.m_foregroundPoint.y = this.m_foregroundPiece.y;
            };
            this.findLedges();
        }

        public function get syncPlatform():String
        {
            return ((m_collisionClip.syncPlatform) ? m_collisionClip.syncPlatform : null);
        }

        public function set syncPlatform(value:String):void
        {
            m_collisionClip.syncPlatform = value;
        }

        public function get LedgeList():Vector.<MovieClip>
        {
            return (this.m_ledges);
        }

        override public function setX(value:Number):void
        {
            super.setX(value);
            this.syncForeground();
        }

        override public function setY(value:Number):void
        {
            super.setY(value);
            this.syncForeground();
        }

        public function getXSpeed():Number
        {
            return (this.m_xSpeed);
        }

        public function setXSpeed(value:Number):void
        {
            this.m_xSpeed = value;
        }

        public function getYSpeed():Number
        {
            return (this.m_ySpeed);
        }

        public function setYSpeed(value:Number):void
        {
            this.m_ySpeed = value;
        }

        override public function set foreground(value:String):void
        {
            m_collisionClipContainer.foreground = value;
            this.findForegroundPieces();
        }

        public function addMovement(movement:Object):void
        {
            var movementInstance:PlatformMovement = new PlatformMovement();
            movementInstance.xAccel = ((movement.xAccel) ? movement.xAccel : 0);
            movementInstance.xDecel = ((movement.xDecel) ? movement.xDecel : 0);
            movementInstance.yAccel = ((movement.yAccel) ? movement.yAccel : 0);
            movementInstance.yDecel = ((movement.yDecel) ? movement.yDecel : 0);
            movementInstance.moveTime = ((movement.moveTime) ? movement.moveTime : 0);
            movementInstance.waitTime = ((movement.waitTime) ? movement.waitTime : 0);
            movementInstance.xSpeed = ((movement.xSpeed) ? movement.xSpeed : 0);
            movementInstance.ySpeed = ((movement.ySpeed) ? movement.ySpeed : 0);
            movementInstance.fallthrough = ((movement.fallthrough !== undefined) ? movement.fallthrough : fallthrough);
            movementInstance.noDropThrough = ((movement.noDropThrough !== undefined) ? movement.noDropThrough : noDropThrough);
            movementInstance.camFocus = ((movement.camFocus !== undefined) ? movement.camFocus : false);
            this.m_platformMovement.push(movementInstance);
            if (this.m_platformMovement.length === 1)
            {
                this.m_wait = false;
                this.m_moveIndex = 0;
                this.m_moveTimer.MaxTime = movementInstance.moveTime;
                this.m_moveTimer.MaxTime = movementInstance.moveTime;
                this.m_waitTimer.reset();
                this.m_waitTimer.reset();
                this.m_xSpeed = ((movementInstance.xAccel > 0) ? 0 : movementInstance.xSpeed);
                this.m_ySpeed = ((movementInstance.yAccel > 0) ? 0 : movementInstance.ySpeed);
                if (movementInstance.camFocus)
                {
                    STAGEDATA.CamRef.addForcedTarget(m_platform);
                };
            };
        }

        public function clearMovement():void
        {
            this.m_platformMovement.splice(0, this.m_platformMovement.length);
        }

        private function incrementMovement():void
        {
            this.m_moveIndex++;
            if (this.m_moveIndex >= this.m_platformMovement.length)
            {
                this.m_moveIndex = 0;
            };
        }

        public function extraHitTests(x_offset:Number, y_offset:Number, caller:InteractiveSprite):Boolean
        {
            if (((!(m_apiInstance)) || (!(m_apiInstance.instance))))
            {
                return (false);
            };
            return (SSF2Platform(m_apiInstance).extraHitTests(x_offset, y_offset, caller));
        }

        public function updateStart(point:Point):void
        {
            m_x_start = point.x;
            m_y_start = point.y;
        }

        public function setForegroundPiece(mc:MovieClip):void
        {
            this.m_foregroundPiece = mc;
            this.m_foregroundPoint.x = this.m_foregroundPiece.x;
            this.m_foregroundPoint.y = this.m_foregroundPiece.y;
        }

        public function findForegroundPieces():void
        {
            var i:int;
            var found:Boolean;
            var foregroundMC:MovieClip;
            var curObject:MovieClip;
            if (foreground)
            {
                i = 0;
                found = false;
                foregroundMC = STAGEDATA.StageParentRef;
                curObject = null;
                i = 0;
                while (i < foregroundMC.numChildren)
                {
                    if ((foregroundMC.getChildAt(i) is MovieClip))
                    {
                        curObject = MovieClip(foregroundMC.getChildAt(i));
                        if (((curObject.foreground) && (curObject.foreground == foreground)))
                        {
                            this.m_foregroundPiece = curObject;
                            found = true;
                            break;
                        };
                    };
                    i++;
                };
                if ((!(found)))
                {
                    foregroundMC = STAGEDATA.StageFG;
                    i = 0;
                    while (((!(foregroundMC == null)) && (i < foregroundMC.numChildren)))
                    {
                        if ((foregroundMC.getChildAt(i) is MovieClip))
                        {
                            curObject = MovieClip(foregroundMC.getChildAt(i));
                            if (((curObject.foreground) && (curObject.foreground == foreground)))
                            {
                                this.m_foregroundPiece = curObject;
                                break;
                            };
                        };
                        i++;
                    };
                };
                if (this.m_foregroundPiece != null)
                {
                    this.m_foregroundPoint.x = this.m_foregroundPiece.x;
                    this.m_foregroundPoint.y = this.m_foregroundPiece.y;
                };
            };
        }

        public function findLedges():void
        {
            var ledges1:Vector.<MovieClip>;
            var ledges2:Vector.<MovieClip>;
            var tmpPoint:Point;
            var i:int;
            if (this.m_findLedges)
            {
                ledges1 = STAGEDATA.getLedges_L();
                ledges2 = STAGEDATA.getLedges_R();
                tmpPoint = new Point();
                i = 0;
                while (i < ledges1.length)
                {
                    if (((((ledges1[i].syncPlatform) && (this.syncPlatform)) && (ledges1[i].syncPlatform == this.syncPlatform)) || (((!(ledges1[i].syncPlatform)) && (!(this.syncPlatform))) && (hitTestPoint(ledges1[i].x, ledges1[i].y)))))
                    {
                        this.m_ledges.push(ledges1[i]);
                        this.m_ledgePoints.push(new Point(ledges1[i].x, ledges1[i].y));
                        this.m_ledgePointsPrev.push(new Point(ledges1[i].x, ledges1[i].y));
                    };
                    i++;
                };
                i = 0;
                while (i < ledges2.length)
                {
                    if (((((ledges2[i].syncPlatform) && (this.syncPlatform)) && (ledges2[i].syncPlatform == this.syncPlatform)) || (((!(ledges2[i].syncPlatform)) && (!(this.syncPlatform))) && (hitTestPoint(ledges2[i].x, ledges2[i].y)))))
                    {
                        this.m_ledges.push(ledges2[i]);
                        this.m_ledgePoints.push(new Point(ledges2[i].x, ledges2[i].y));
                        this.m_ledgePointsPrev.push(new Point(ledges2[i].x, ledges2[i].y));
                    };
                    i++;
                };
            };
        }

        public function syncLedges():void
        {
            var diff:Point;
            var i:int;
            while (i < this.m_ledges.length)
            {
                diff = new Point((m_platform.x - m_x_start), (m_platform.y - m_y_start));
                this.m_ledges[i].x = (this.m_ledgePoints[i].x + diff.x);
                this.m_ledges[i].y = (this.m_ledgePoints[i].y + diff.y);
                i++;
            };
        }

        public function syncForeground():void
        {
            var diff:Point;
            if (this.m_foregroundPiece != null)
            {
                diff = new Point((m_platform.x - m_x_start), (m_platform.y - m_y_start));
                this.m_foregroundPiece.x = (this.m_foregroundPoint.x + (diff.x * (m_platform.parent.scaleX / this.m_foregroundPiece.parent.scaleX)));
                this.m_foregroundPiece.y = (this.m_foregroundPoint.y + (diff.y * (m_platform.parent.scaleY / this.m_foregroundPiece.parent.scaleY)));
            };
        }

        protected function move():void
        {
            if (this.m_platformMovement.length)
            {
                if ((!(this.m_wait)))
                {
                    this.m_moveTimer.tick();
                    this.m_xLoc = (this.m_xLoc + this.m_xSpeed);
                    this.m_yLoc = (this.m_yLoc + this.m_ySpeed);
                    m_platform.x = this.m_xLoc;
                    m_platform.y = this.m_yLoc;
                    this.syncLedges();
                    if ((!(this.m_moveTimer.IsComplete)))
                    {
                        if (this.m_platformMovement[this.m_moveIndex].xAccel > 0)
                        {
                            if (((this.m_platformMovement[this.m_moveIndex].xSpeed > 0) && (this.m_xSpeed < this.m_platformMovement[this.m_moveIndex].xSpeed)))
                            {
                                this.m_xSpeed = (this.m_xSpeed + this.m_platformMovement[this.m_moveIndex].xAccel);
                            }
                            else
                            {
                                if (((this.m_platformMovement[this.m_moveIndex].xSpeed < 0) && (this.m_xSpeed > this.m_platformMovement[this.m_moveIndex].xSpeed)))
                                {
                                    this.m_xSpeed = (this.m_xSpeed - this.m_platformMovement[this.m_moveIndex].xAccel);
                                };
                            };
                        };
                        if (this.m_platformMovement[this.m_moveIndex].yAccel > 0)
                        {
                            if (((this.m_platformMovement[this.m_moveIndex].ySpeed > 0) && (this.m_ySpeed < this.m_platformMovement[this.m_moveIndex].ySpeed)))
                            {
                                this.m_ySpeed = (this.m_ySpeed + this.m_platformMovement[this.m_moveIndex].yAccel);
                            }
                            else
                            {
                                if (((this.m_platformMovement[this.m_moveIndex].ySpeed < 0) && (this.m_ySpeed > this.m_platformMovement[this.m_moveIndex].ySpeed)))
                                {
                                    this.m_ySpeed = (this.m_ySpeed - this.m_platformMovement[this.m_moveIndex].yAccel);
                                };
                            };
                        };
                    }
                    else
                    {
                        if (this.m_moveTimer.IsComplete)
                        {
                            if (this.m_platformMovement[this.m_moveIndex].xDecel > 0)
                            {
                                if (this.m_platformMovement[this.m_moveIndex].xSpeed > 0)
                                {
                                    this.m_xSpeed = (this.m_xSpeed - this.m_platformMovement[this.m_moveIndex].xDecel);
                                    if (this.m_xSpeed <= 0)
                                    {
                                        this.m_moveTimer.reset();
                                        this.m_wait = true;
                                    };
                                }
                                else
                                {
                                    if (this.m_platformMovement[this.m_moveIndex].xSpeed < 0)
                                    {
                                        this.m_xSpeed = (this.m_xSpeed + this.m_platformMovement[this.m_moveIndex].xDecel);
                                        if (this.m_xSpeed >= 0)
                                        {
                                            this.m_moveTimer.reset();
                                            this.m_wait = true;
                                        };
                                    };
                                };
                            };
                            if (this.m_platformMovement[this.m_moveIndex].yDecel > 0)
                            {
                                if (this.m_platformMovement[this.m_moveIndex].ySpeed > 0)
                                {
                                    this.m_ySpeed = (this.m_ySpeed - this.m_platformMovement[this.m_moveIndex].yDecel);
                                    if (this.m_ySpeed < 0)
                                    {
                                        this.m_moveTimer.reset();
                                        this.m_wait = true;
                                    };
                                }
                                else
                                {
                                    if (this.m_platformMovement[this.m_moveIndex].ySpeed < 0)
                                    {
                                        this.m_ySpeed = (this.m_ySpeed + this.m_platformMovement[this.m_moveIndex].yDecel);
                                        if (this.m_ySpeed > 0)
                                        {
                                            this.m_moveTimer.reset();
                                            this.m_wait = true;
                                        };
                                    }
                                    else
                                    {
                                        this.m_moveTimer.reset();
                                        this.m_wait = true;
                                    };
                                };
                            };
                            if (((this.m_platformMovement[this.m_moveIndex].xDecel <= 0) && (this.m_platformMovement[this.m_moveIndex].yDecel <= 0)))
                            {
                                this.m_moveTimer.reset();
                                this.m_wait = true;
                            };
                        };
                    };
                };
                if (this.m_wait)
                {
                    if (this.m_waitTimer.IsComplete)
                    {
                        this.m_moveTimer.reset();
                        this.m_waitTimer.reset();
                        this.incrementMovement();
                        this.m_moveTimer.MaxTime = this.m_platformMovement[this.m_moveIndex].moveTime;
                        this.m_waitTimer.MaxTime = ((this.m_platformMovement[this.m_moveIndex].waitTime < 0) ? int.MAX_VALUE : this.m_platformMovement[this.m_moveIndex].waitTime);
                        this.m_xSpeed = ((this.m_platformMovement[this.m_moveIndex].xAccel > 0) ? 0 : this.m_platformMovement[this.m_moveIndex].xSpeed);
                        this.m_ySpeed = ((this.m_platformMovement[this.m_moveIndex].yAccel > 0) ? 0 : this.m_platformMovement[this.m_moveIndex].ySpeed);
                        noDropThrough = this.m_platformMovement[this.m_moveIndex].noDropThrough;
                        fallthrough = this.m_platformMovement[this.m_moveIndex].fallthrough;
                        this.m_wait = false;
                        if (this.m_platformMovement[this.m_moveIndex].camFocus)
                        {
                            STAGEDATA.CamRef.addForcedTarget(m_platform);
                        }
                        else
                        {
                            STAGEDATA.CamRef.deleteForcedTarget(m_platform);
                        };
                    };
                    if (this.m_waitTimer.MaxTime < int.MAX_VALUE)
                    {
                        this.m_waitTimer.tick();
                    };
                };
            };
            if (((!(this.m_xSpeed === 0)) || (!(this.m_ySpeed === 0))))
            {
                m_platform.x = (m_platform.x + this.m_xSpeed);
                m_platform.y = (m_platform.y + this.m_ySpeed);
            };
            this.syncLedges();
            this.syncForeground();
        }

        override public function stop():void
        {
            super.stop();
            if (this.m_foregroundPiece != null)
            {
                this.m_foregroundPiece.stop();
            };
        }

        override public function play():void
        {
            super.play();
            if (this.m_foregroundPiece != null)
            {
                this.m_foregroundPiece.play();
            };
        }

        public function syncPlayers():void
        {
            var i:int;
            i = 0;
            while (i < STAGEDATA.Characters.length)
            {
                STAGEDATA.Characters[i].checkMovingPlatforms(this);
                i++;
            };
            i = 0;
            while (i < STAGEDATA.Projectiles.length)
            {
                STAGEDATA.Projectiles[i].checkMovingPlatforms(this);
                i++;
            };
            i = 0;
            while (i < STAGEDATA.Enemies.length)
            {
                if (STAGEDATA.Enemies[i] != null)
                {
                    STAGEDATA.Enemies[i].checkMovingPlatforms(this);
                };
                i++;
            };
            i = 0;
            while (i < STAGEDATA.ItemsRef.ItemsInUse.length)
            {
                if (((!(STAGEDATA.ItemsRef.ItemsInUse[i] == null)) && (!(STAGEDATA.ItemsRef.ItemsInUse[i].Dead))))
                {
                    STAGEDATA.ItemsRef.ItemsInUse[i].checkMovingPlatforms(this);
                };
                i++;
            };
        }

        override public function destroy():void
        {
            m_dead = true;
            STAGEDATA.removePlatform(this);
        }

        override public function PERFORMALL():void
        {
            this.PREPERFORM();
            if ((!(this.m_disabled)))
            {
                storeOldLocation();
                this.move();
                if (m_apiInstance)
                {
                    m_apiInstance.update();
                };
                this.syncPlayers();
            };
            this.POSTPERFORM();
        }

        protected function PREPERFORM():void
        {
            if ((!(this.m_disabled)))
            {
                if (m_platform.currentFrame == m_platform.totalFrames)
                {
                    m_platform.gotoAndStop(1);
                }
                else
                {
                    m_platform.nextFrame();
                };
                if (this.m_foregroundPiece != null)
                {
                    if (this.m_foregroundPiece.currentFrame == this.m_foregroundPiece.totalFrames)
                    {
                        this.m_foregroundPiece.gotoAndStop(1);
                    }
                    else
                    {
                        this.m_foregroundPiece.nextFrame();
                    };
                };
            };
        }

        protected function POSTPERFORM():void
        {
            if ((!(this.m_disabled)))
            {
                this.stop();
            };
        }

        override public function setAlpha(val:Number):void
        {
            super.setAlpha(val);
            if (this.m_foregroundPiece != null)
            {
                this.m_foregroundPiece.alpha = val;
            };
        }

        public function killPlatform():void
        {
            m_platform.visible = false;
            if (this.m_foregroundPiece != null)
            {
                this.m_foregroundPiece.visible = false;
            };
            if (m_platform.ground)
            {
                MovieClip(m_platform.ground).fallthrough = true;
            }
            else
            {
                m_platform.fallthrough = true;
            };
            m_platform.visible = false;
            this.m_disabled = true;
        }


    }
}//package com.mcleodgaming.ssf2.platforms


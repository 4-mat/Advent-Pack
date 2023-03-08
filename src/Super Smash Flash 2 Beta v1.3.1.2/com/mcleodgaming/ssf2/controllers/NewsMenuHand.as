// Decompiled by AS3 Sorcerer 6.30
// www.as3sorcerer.com

//com.mcleodgaming.ssf2.controllers.NewsMenuHand

package com.mcleodgaming.ssf2.controllers
{
    import __AS3__.vec.Vector;
    import flash.display.MovieClip;
    import flash.events.Event;
    import flash.display.DisplayObject;
    import com.mcleodgaming.ssf2.util.*;
    import __AS3__.vec.*;

    public class NewsMenuHand extends SelectHand 
    {

        public var topBoundPush:Function;
        public var bottomBoundPush:Function;

        public function NewsMenuHand(targetMC:MovieClip, buttons:Vector.<NewsButton>, backFunc:Function)
        {
            var convertedButtons:Vector.<HandButton> = new Vector.<HandButton>();
            var i:int;
            while (i < buttons.length)
            {
                convertedButtons.push(buttons[i]);
                i++;
            };
            super(targetMC, convertedButtons, backFunc);
            START_POSITION.x = -246;
            START_POSITION.y = -132;
            BOUNDS_RECT.x = -287;
            BOUNDS_RECT.y = -145;
            BOUNDS_RECT.width = 585;
            BOUNDS_RECT.height = 300;
            resetPosition();
        }

        override protected function checkControls(e:Event):void
        {
            var i:int;
            if (((m_hand.y <= BOUNDS_RECT.y) && (!(this.topBoundPush === null))))
            {
                i = 0;
                while (i < m_players.length)
                {
                    if (m_players[i].IsDown(m_players[i]._UP))
                    {
                        this.topBoundPush();
                        break;
                    };
                    i++;
                };
            }
            else
            {
                if (((m_hand.y >= (BOUNDS_RECT.y + BOUNDS_RECT.height)) && (!(this.bottomBoundPush === null))))
                {
                    i = 0;
                    while (i < m_players.length)
                    {
                        if (m_players[i].IsDown(m_players[i]._DOWN))
                        {
                            this.bottomBoundPush();
                            break;
                        };
                        i++;
                    };
                };
            };
            super.checkControls(e);
        }

        override protected function checkBounds(mc:DisplayObject, coordinateSpaceOverride:DisplayObject=null):Boolean
        {
            return (super.checkBounds(mc, mc.parent.parent));
        }


    }
}//package com.mcleodgaming.ssf2.controllers


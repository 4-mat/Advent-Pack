// Decompiled by AS3 Sorcerer 6.30
// www.as3sorcerer.com

//com.mcleodgaming.ssf2.controllers.StageSelectHand

package com.mcleodgaming.ssf2.controllers
{
    import __AS3__.vec.Vector;
    import com.mcleodgaming.ssf2.util.ResourceManager;
    import flash.display.MovieClip;
    import com.mcleodgaming.ssf2.Main;
    import flash.events.KeyboardEvent;
    import com.mcleodgaming.ssf2.events.GamepadEvent;
    import com.mcleodgaming.ssf2.audio.SoundQueue;
    import flash.events.Event;
    import com.mcleodgaming.ssf2.util.*;
    import __AS3__.vec.*;

    public class StageSelectHand extends SelectHand 
    {

        protected var m_spaceLetGo:Boolean;
        protected var m_stageButtons:Vector.<StageButton>;

        public function StageSelectHand(targetMC:MovieClip, buttons:Vector.<StageButton>, backFunc:Function)
        {
            this.m_stageButtons = buttons;
            var convertedButtons:Vector.<HandButton> = new Vector.<HandButton>();
            var i:int;
            while (i < this.m_stageButtons.length)
            {
                convertedButtons.push(this.m_stageButtons[i]);
                i++;
            };
            super(targetMC, convertedButtons, backFunc);
            this.m_spaceLetGo = false;
            var mappings:Object = ResourceManager.getResourceByID("mappings").getProp("metadata");
            var screen:Object = mappings.stage_select_screen;
            START_POSITION.x = screen.hand_start.x;
            START_POSITION.y = screen.hand_start.y;
            BOUNDS_RECT.x = screen.hand_bounds.x;
            BOUNDS_RECT.y = screen.hand_bounds.y;
            BOUNDS_RECT.width = (screen.hand_bounds.width + 100);
            BOUNDS_RECT.height = screen.hand_bounds.height;
        }

        override public function makeEvents():void
        {
            this.m_spaceLetGo = false;
            super.makeEvents();
            Main.Root.stage.addEventListener(KeyboardEvent.KEY_UP, this.releaseKey);
        }

        override public function killEvents():void
        {
            super.killEvents();
            Main.Root.stage.removeEventListener(KeyboardEvent.KEY_UP, this.releaseKey);
        }

        protected function releaseKey(e:KeyboardEvent):void
        {
            if (e.keyCode == 32)
            {
                this.m_spaceLetGo = true;
            };
        }

        override protected function checkHit(e:Event):void
        {
            var found:Boolean;
            var i:int;
            var j:int;
            var isInputEvent:Boolean = ((e is KeyboardEvent) || (e is GamepadEvent));
            var pressed:Boolean = ((e is KeyboardEvent) && ((e as KeyboardEvent).keyCode == 32));
            if ((!(pressed)))
            {
                this.m_spaceLetGo = true;
            };
            j = 0;
            while (j < m_players.length)
            {
                if (((!(m_players[j].IsDown(m_players[j]._BUTTON2))) && (!(m_players[j].IsDown(m_players[j]._START)))))
                {
                    m_selectLetGo[j] = true;
                };
                if ((!(m_players[j].IsDown(m_players[j]._BUTTON1))))
                {
                    m_backLetGo[j] = true;
                };
                j++;
            };
            if (m_targetMC.root == null)
            {
                this.killEvents();
            }
            else
            {
                if ((!(GameController.isStarted)))
                {
                    found = false;
                    i = 0;
                    while (((i < this.m_stageButtons.length) && (!(found))))
                    {
                        j = 0;
                        while (j < m_players.length)
                        {
                            if (((m_backLetGo[j]) && (m_players[j].IsDown(m_players[j]._BUTTON1))))
                            {
                                m_backLetGo[j] = false;
                                this.killEvents();
                                m_backFunc(null);
                                return;
                            };
                            j++;
                        };
                        if (((checkBounds(this.m_stageButtons[i].ButtonInstance)) && (m_hand.visible)))
                        {
                            if (m_rollOverID != i)
                            {
                                if (m_rollOverID != -1)
                                {
                                    this.m_stageButtons[m_rollOverID].rollout();
                                    this.m_stageButtons[m_rollOverID].mouseout();
                                };
                                this.m_stageButtons[i].rollover();
                                this.m_stageButtons[i].mouseover();
                            };
                            m_rollOverID = i;
                            found = true;
                            j = 0;
                            while (((j < m_players.length) && (isInputEvent)))
                            {
                                if (((m_players[j].IsDown(m_players[j]._BUTTON2)) || (m_players[j].IsDown(m_players[j]._START))))
                                {
                                    if (((!(this.m_stageButtons[i].StageID === "random")) && ((!(ResourceManager.getResourceByID(this.m_stageButtons[i].StageID))) || (!(ResourceManager.getResourceByID(this.m_stageButtons[i].StageID).FileName)))))
                                    {
                                        SoundQueue.instance.playSoundEffect("menu_error");
                                        return;
                                    };
                                    this.killEvents();
                                    this.m_stageButtons[i].click();
                                    return;
                                };
                                j++;
                            };
                        };
                        i++;
                    };
                    evaluateExtraButtons();
                    if ((!(found)))
                    {
                        if (m_rollOverID != -1)
                        {
                            this.m_stageButtons[m_rollOverID].rollout();
                        };
                        m_rollOverID = -1;
                    };
                    i = 0;
                    while ((((i < this.m_stageButtons.length) && (!(found))) && (isInputEvent)))
                    {
                        if (this.m_stageButtons[i].StageID == "random")
                        {
                            j = 0;
                            while (j < m_players.length)
                            {
                                if (((m_players[j].IsDown(m_players[j]._START)) || (pressed)))
                                {
                                    this.killEvents();
                                    this.m_stageButtons[i].rollover();
                                    this.m_stageButtons[i].click();
                                    return;
                                };
                                j++;
                            };
                        };
                        i++;
                    };
                };
            };
            if (pressed)
            {
                this.m_spaceLetGo = false;
            };
        }


    }
}//package com.mcleodgaming.ssf2.controllers


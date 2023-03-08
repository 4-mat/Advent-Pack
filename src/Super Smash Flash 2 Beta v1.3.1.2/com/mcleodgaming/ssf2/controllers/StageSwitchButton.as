// Decompiled by AS3 Sorcerer 6.30
// www.as3sorcerer.com

//com.mcleodgaming.ssf2.controllers.StageSwitchButton

package com.mcleodgaming.ssf2.controllers
{
    import flash.display.MovieClip;
    import com.mcleodgaming.ssf2.audio.SoundQueue;
    import com.mcleodgaming.ssf2.util.SaveData;
    import flash.events.MouseEvent;
    import com.mcleodgaming.ssf2.audio.*;
    import com.mcleodgaming.ssf2.util.*;
    import com.mcleodgaming.ssf2.engine.*;

    public class StageSwitchButton extends HandButton 
    {

        private var m_stageID:String;
        private var m_extraClickFunc:Function;

        public function StageSwitchButton(mc:MovieClip, stageID:String)
        {
            super(mc);
            this.m_stageID = stageID;
            this.m_extraClickFunc = null;
        }

        public function get ID():String
        {
            return (this.m_stageID);
        }

        public function setClickFunc(func:Function):void
        {
            this.m_extraClickFunc = func;
        }

        override protected function button_CLICK(e:MouseEvent):void
        {
            SoundQueue.instance.playSoundEffect("menu_hover");
            var wasOn:Boolean = (m_button.currentFrameLabel == "on");
            m_button.gotoAndStop(((wasOn) ? "off" : "on"));
            SaveData.VSStageDataObj[this.m_stageID] = (!(wasOn));
            if (this.m_extraClickFunc != null)
            {
                this.m_extraClickFunc(this);
            };
        }

        public function getStatus():Boolean
        {
            return (m_button.currentFrameLabel == "on");
        }

        public function setStatus(status:Boolean):void
        {
            m_button.gotoAndStop(((status) ? "on" : "off"));
            if (status)
            {
                delete SaveData.VSStageDataObj[this.m_stageID];
            }
            else
            {
                SaveData.VSStageDataObj[this.m_stageID] = false;
            };
        }


    }
}//package com.mcleodgaming.ssf2.controllers


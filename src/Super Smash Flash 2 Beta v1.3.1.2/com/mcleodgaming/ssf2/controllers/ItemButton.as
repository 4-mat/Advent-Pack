// Decompiled by AS3 Sorcerer 6.30
// www.as3sorcerer.com

//com.mcleodgaming.ssf2.controllers.ItemButton

package com.mcleodgaming.ssf2.controllers
{
    import flash.display.MovieClip;
    import com.mcleodgaming.ssf2.audio.SoundQueue;
    import com.mcleodgaming.ssf2.util.SaveData;
    import flash.events.MouseEvent;
    import com.mcleodgaming.ssf2.audio.*;
    import com.mcleodgaming.ssf2.util.*;

    public class ItemButton extends HandButton 
    {

        private var m_itemName:String;

        public function ItemButton(mc:MovieClip, iName:String)
        {
            super(mc);
            this.m_itemName = iName;
        }

        public function get ItemID():String
        {
            return (this.m_itemName);
        }

        override protected function button_CLICK(e:MouseEvent):void
        {
            SoundQueue.instance.playSoundEffect("menu_select");
            var wasOn:Boolean = (m_button.currentFrameLabel == "on");
            m_button.gotoAndStop(((wasOn) ? "off" : "on"));
            var list:Array = this.m_itemName.split("|");
            var i:Number = 0;
            while (i < list.length)
            {
                SaveData.ItemDataObj[list[i]] = (!(wasOn));
                if (SaveData.ItemDataObj[list[i]])
                {
                    delete SaveData.ItemDataObj[list[i]];
                };
                i++;
            };
            MenuController.itemSwitchMenu.checkAllBtn();
        }

        override protected function button_ROLLOVER(e:MouseEvent):void
        {
            m_button.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_OVER));
        }

        override protected function button_ROLLOUT(e:MouseEvent):void
        {
            m_button.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_OUT));
        }

        public function getStatus():Boolean
        {
            return (m_button.currentFrameLabel == "on");
        }

        public function setStatus(status:Boolean):void
        {
            m_button.gotoAndStop(((status) ? "on" : "off"));
            var list:Array = this.m_itemName.split("|");
            var i:Number = 0;
            while (i < list.length)
            {
                if (status)
                {
                    delete SaveData.ItemDataObj[list[i]];
                }
                else
                {
                    SaveData.ItemDataObj[list[i]] = false;
                };
                i++;
            };
        }


    }
}//package com.mcleodgaming.ssf2.controllers


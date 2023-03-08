// Decompiled by AS3 Sorcerer 6.30
// www.as3sorcerer.com

//com.mcleodgaming.ssf2.controllers.DataButton

package com.mcleodgaming.ssf2.controllers
{
    import flash.display.MovieClip;
    import flash.events.MouseEvent;

    public class DataButton extends HandButton 
    {

        public function DataButton(mc:MovieClip)
        {
            super(mc);
        }

        override protected function button_ROLLOVER(e:MouseEvent):void
        {
            m_button.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_OVER));
        }

        override protected function button_CLICK(e:MouseEvent):void
        {
            m_button.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
        }

        override protected function button_ROLLOUT(e:MouseEvent):void
        {
            m_button.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_OUT));
        }


    }
}//package com.mcleodgaming.ssf2.controllers


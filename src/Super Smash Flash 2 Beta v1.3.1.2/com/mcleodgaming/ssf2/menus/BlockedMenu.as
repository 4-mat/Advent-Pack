// Decompiled by AS3 Sorcerer 6.30
// www.as3sorcerer.com

//com.mcleodgaming.ssf2.menus.BlockedMenu

package com.mcleodgaming.ssf2.menus
{
    import com.mcleodgaming.ssf2.util.ResourceManager;
    import com.mcleodgaming.ssf2.Main;
    import flash.events.MouseEvent;
    import flash.events.Event;
    import com.mcleodgaming.ssf2.util.*;
    import com.mcleodgaming.ssf2.controllers.*;

    public class BlockedMenu extends Menu 
    {

        public function BlockedMenu()
        {
            m_subMenu = ResourceManager.getLibraryMC("menu_blocked");
            m_container.addChild(m_subMenu);
            m_subMenu.x = (Main.Width / 2);
            m_subMenu.y = (Main.Height / 2);
        }

        override public function makeEvents():void
        {
            if (m_showCount == 0)
            {
                findSubMenuButtons();
            };
            super.makeEvents();
            m_subMenu.mglink.addEventListener(MouseEvent.CLICK, this.callLink);
            Main.Root.addEventListener(Event.ADDED, moveToFront);
        }

        override public function killEvents():void
        {
            super.killEvents();
            m_subMenu.mglink.removeEventListener(MouseEvent.CLICK, this.callLink);
            Main.Root.removeEventListener(Event.ADDED, moveToFront);
        }

        private function callLink(e:*):void
        {
            var url:String = "https://www.supersmashflash.com";
            try
            {
                Main.getURL(url, "_blank");
            }
            catch(e:Error)
            {
                trace("Error occurred calling MG URL!");
            };
        }


    }
}//package com.mcleodgaming.ssf2.menus


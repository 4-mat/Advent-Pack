// Decompiled by AS3 Sorcerer 6.30
// www.as3sorcerer.com

//com.mcleodgaming.ssf2.menus.PostUnlockMenu

package com.mcleodgaming.ssf2.menus
{
    import com.mcleodgaming.ssf2.util.FrameTimer;
    import com.mcleodgaming.ssf2.util.ResourceManager;
    import com.mcleodgaming.ssf2.Main;
    import flash.events.MouseEvent;
    import flash.events.Event;
    import com.mcleodgaming.ssf2.controllers.UnlockController;
    import com.mcleodgaming.ssf2.util.Utils;
    import com.mcleodgaming.ssf2.audio.SoundQueue;
    import com.mcleodgaming.ssf2.util.SaveData;
    import com.mcleodgaming.ssf2.controllers.MenuController;
    import com.mcleodgaming.ssf2.util.*;
    import com.mcleodgaming.ssf2.controllers.*;
    import com.mcleodgaming.ssf2.audio.*;
    import com.mcleodgaming.ssf2.engine.*;

    public class PostUnlockMenu extends Menu 
    {

        private var ready:Boolean;
        private var m_keyLetGo:Boolean;
        private var m_delay:FrameTimer;

        public function PostUnlockMenu()
        {
            m_subMenu = ResourceManager.getLibraryMC("menu_postunlock");
            m_subMenu.stop();
            this.ready = false;
            m_container.addChild(m_subMenu);
            m_subMenu.x = (Main.Width / 2);
            m_subMenu.y = (Main.Height / 2);
            this.m_keyLetGo = false;
            this.m_delay = new FrameTimer(60);
        }

        override public function makeEvents():void
        {
            if (m_showCount == 0)
            {
                findSubMenuButtons();
            };
            super.makeEvents();
            m_subMenu.addEventListener(MouseEvent.CLICK, this.CLICKED);
            m_subMenu.addEventListener(Event.ENTER_FRAME, this.nextUnlock);
            this.m_keyLetGo = false;
        }

        override public function killEvents():void
        {
            super.killEvents();
            m_subMenu.removeEventListener(MouseEvent.CLICK, this.CLICKED);
            m_subMenu.removeEventListener(Event.ENTER_FRAME, this.nextUnlock);
        }

        override public function show():void
        {
            if (UnlockController.pendingUnlockScreens.length > 0)
            {
                Utils.tryToGotoAndStop(m_subMenu, UnlockController.pendingUnlockScreens[0].ID);
                UnlockController.pendingUnlockScreens[0].unlock();
                SoundQueue.instance.playSoundEffect("menu_unlock");
                UnlockController.pendingUnlockScreens.shift();
            };
            SoundQueue.instance.stopMusic();
            super.show();
            this.m_delay.reset();
        }

        private function CLICKED(e:MouseEvent):void
        {
            this.ready = true;
        }

        private function nextUnlock(e:Event):void
        {
            this.m_delay.tick();
            if ((!(this.m_delay.IsComplete)))
            {
                return;
            };
            var found:Boolean;
            var i:int;
            while (((i < SaveData.Controllers.length) && (!(this.ready))))
            {
                if (SaveData.Controllers[i] != null)
                {
                    if (SaveData.Controllers[i].IsDown(SaveData.Controllers[i]._BUTTON2))
                    {
                        if (this.m_keyLetGo)
                        {
                            this.ready = true;
                        };
                        found = true;
                    };
                };
                i++;
            };
            if ((!(found)))
            {
                this.m_keyLetGo = true;
            };
            if (this.ready)
            {
                this.ready = false;
                SoundQueue.instance.playSoundEffect("menu_select");
                if (UnlockController.pendingUnlockScreens.length > 0)
                {
                    removeSelf();
                    MenuController.postUnlockMenu.show();
                }
                else
                {
                    if (UnlockController.pendingUnlockFights.length > 0)
                    {
                        removeSelf();
                        MenuController.preUnlockMenu.show();
                    }
                    else
                    {
                        removeSelf();
                        UnlockController.nextMenuFunc();
                    };
                };
            };
        }


    }
}//package com.mcleodgaming.ssf2.menus


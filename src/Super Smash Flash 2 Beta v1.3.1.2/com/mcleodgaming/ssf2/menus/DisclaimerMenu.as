// Decompiled by AS3 Sorcerer 6.30
// www.as3sorcerer.com

//com.mcleodgaming.ssf2.menus.DisclaimerMenu

package com.mcleodgaming.ssf2.menus
{
    import flash.display.Shape;
    import com.mcleodgaming.ssf2.util.FrameTimer;
    import com.mcleodgaming.ssf2.controllers.SelectHand;
    import com.mcleodgaming.ssf2.util.ResourceManager;
    import com.mcleodgaming.ssf2.Main;
    import com.mcleodgaming.ssf2.controllers.MenuController;
    import flash.events.MouseEvent;
    import flash.events.Event;
    import com.mcleodgaming.ssf2.util.SaveData;
    import com.mcleodgaming.ssf2.audio.SoundQueue;
    import flash.display.MovieClip;
    import com.mcleodgaming.ssf2.Version;
    import com.mcleodgaming.ssf2.controllers.HandButton;
    import flash.display.SimpleButton;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import com.mcleodgaming.ssf2.controllers.UnlockController;
    import com.mcleodgaming.ssf2.controllers.Unlockable;
    import com.mcleodgaming.ssf2.util.*;
    import com.mcleodgaming.ssf2.controllers.*;
    import com.mcleodgaming.ssf2.audio.*;
    import __AS3__.vec.*;

    public class DisclaimerMenu extends Menu 
    {

        private var waitASec:Boolean;
        private var m_skipNode:MenuMapperNode;
        private var m_featuredLoadingShape:Shape;
        private var m_featuredSkipBlockTimer:FrameTimer;
        private var m_featuredCustomMenu:CustomAPIMenu;
        private var m_featuredSelectHand:SelectHand;

        public function DisclaimerMenu()
        {
            m_subMenu = ResourceManager.getLibraryMC("menu_disclaimer");
            if (m_subMenu)
            {
                m_subMenu.stop();
                m_container.addChild(m_subMenu);
                this.initMenuMappings();
                m_subMenu.x = (Main.Width / 2);
                m_subMenu.y = (Main.Height / 2);
            };
            this.waitASec = true;
            this.m_featuredSkipBlockTimer = new FrameTimer((30 * 2));
            this.m_featuredLoadingShape = new Shape();
            this.m_featuredLoadingShape.graphics.beginFill(0xEEEEEE, 0.5);
            this.m_featuredLoadingShape.graphics.lineStyle(1, 0x111111, 0.5);
            this.m_featuredLoadingShape.graphics.drawRect(0, 0, 50, 3);
            this.m_featuredLoadingShape.graphics.endFill();
            this.m_featuredLoadingShape.x = 5;
            this.m_featuredLoadingShape.y = (360 - 10);
        }

        override public function initMenuMappings():void
        {
            this.m_skipNode = new MenuMapperNode(m_subMenu);
            this.m_skipNode.updateNodes(null, null, null, null, null, null, this.skipDisclaimer, this.skipDisclaimer);
            m_menuMapper = new MenuMapper(this.m_skipNode);
            m_menuMapper.init();
        }

        override public function makeEvents():void
        {
            if (m_showCount == 0)
            {
                findSubMenuButtons();
            };
            super.makeEvents();
            if (m_subMenu == null)
            {
                removeSelf();
                MenuController.intro3Menu.setVault(false);
                MenuController.intro3Menu.show();
            }
            else
            {
                Main.Root.stage.addEventListener(MouseEvent.CLICK, this.skipDisclaimer);
                Main.Root.stage.addEventListener(Event.ENTER_FRAME, this.checkDisclaimer);
                Main.Root.stage.addEventListener(Event.ENTER_FRAME, manageMenuMappings);
            };
            SaveData.saveGame();
        }

        override public function killEvents():void
        {
            super.killEvents();
            Main.Root.stage.removeEventListener(MouseEvent.CLICK, this.skipDisclaimer);
            Main.Root.stage.removeEventListener(Event.ENTER_FRAME, this.checkDisclaimer);
            Main.Root.stage.removeEventListener(Event.ENTER_FRAME, manageMenuMappings);
        }

        private function skipDisclaimer(e:MouseEvent):void
        {
            if (((!(this.waitASec)) && ((m_subMenu.currentFrame > 90) || (Main.DEBUG))))
            {
                SoundQueue.instance.playSoundEffect("menu_selectstage");
                if (m_subMenu)
                {
                    m_subMenu.stop();
                };
                this.nextMenu();
            };
        }

        private function checkDisclaimer(e:Event):void
        {
            if (m_subMenu)
            {
                if (m_subMenu.currentFrame >= (m_subMenu.totalFrames - 1))
                {
                    m_subMenu.stop();
                    this.nextMenu();
                };
            };
            this.waitASec = false;
        }

        override public function show():void
        {
            this.waitASec = true;
            if (m_subMenu)
            {
                m_subMenu.gotoAndPlay(1);
                super.show();
            }
            else
            {
                this.nextMenu();
            };
            ResourceManager.getResourceByID("mappings").getProp("metadata");
        }

        private function checkFeaturedNewsInputs(e:Event):void
        {
            var i:int;
            this.m_featuredSkipBlockTimer.tick();
            this.m_featuredLoadingShape.scaleX = (1 - (this.m_featuredSkipBlockTimer.CurrentTime / this.m_featuredSkipBlockTimer.MaxTime));
            if (this.m_featuredSkipBlockTimer.IsComplete)
            {
                i = 0;
                while (i < SaveData.Controllers.length)
                {
                    if (((((e is MouseEvent) || (SaveData.Controllers[i].IsDown(SaveData.Controllers[i]._START))) || (SaveData.Controllers[i].IsDown(SaveData.Controllers[i]._BUTTON1))) || (SaveData.Controllers[i].IsDown(SaveData.Controllers[i]._BUTTON2))))
                    {
                        Main.Root.removeEventListener(Event.ENTER_FRAME, this.checkFeaturedNewsInputs);
                        Main.Root.stage.removeEventListener(MouseEvent.CLICK, this.checkFeaturedNewsInputs);
                        this.m_featuredCustomMenu.removeSelf();
                        this.m_featuredCustomMenu.APIInstance.dispose();
                        this.m_featuredSelectHand.killEvents();
                        SaveData.saveGame();
                        this.nextMenu();
                        return;
                    };
                    i++;
                };
            };
        }

        private function nextMenu():void
        {
            var entries:Array;
            var e:int;
            var entry:Object;
            var i:int;
            var customContainerChild:MovieClip;
            var j:int;
            removeSelf();
            if (ResourceManager.getResourceByID("menu_news").Loaded)
            {
                entries = ((ResourceManager.getResourceByID("menu_news").getProp("entries")) || (new Array()));
                e = 0;
                while (e < entries.length)
                {
                    entry = entries[e];
                    if (((((!(SaveData.Once.newsRead[entry.id])) && (entry.featured)) && ((false) || (!((entry.featuredIfVersion) && (!(Version.getVersion() === entry.featuredIfVersion)))))) && ((false) || (!((entry.featuredIfNotVersion) && (Version.getVersion() === entry.featuredIfNotVersion))))))
                    {
                        this.m_featuredSkipBlockTimer.reset();
                        if (entry.unskippableFrames !== undefined)
                        {
                            this.m_featuredSkipBlockTimer.MaxTime = entry.unskippableFrames;
                        };
                        SaveData.Once.newsRead[entry.id] = true;
                        this.m_featuredCustomMenu = new CustomAPIMenu({"classAPI":entry.menuClass});
                        this.m_featuredCustomMenu.show();
                        this.m_featuredSelectHand = new SelectHand(this.m_featuredCustomMenu.Container, new Vector.<HandButton>(), null);
                        this.m_featuredSelectHand.makeEvents();
                        i = 0;
                        while (i < this.m_featuredCustomMenu.Container.numChildren)
                        {
                            if ((this.m_featuredCustomMenu.Container.getChildAt(i) is MovieClip))
                            {
                                customContainerChild = MovieClip(this.m_featuredCustomMenu.Container.getChildAt(i));
                                j = 0;
                                while (j < customContainerChild.numChildren)
                                {
                                    if ((((customContainerChild.getChildAt(j) is MovieClip) && (MovieClip(customContainerChild.getChildAt(j)).buttonMode)) || (customContainerChild.getChildAt(j) is SimpleButton)))
                                    {
                                        this.m_featuredSelectHand.addClickEventClipHitTest(customContainerChild.getChildAt(j));
                                    };
                                    j = (j + 1);
                                };
                            };
                            i = (i + 1);
                        };
                        this.m_featuredSelectHand.resetPosition(new Point(320, 240), new Rectangle(10, 10, 630, 350));
                        SoundQueue.instance.playSoundEffect("menu_unlock");
                        Main.Root.addEventListener(Event.ENTER_FRAME, this.checkFeaturedNewsInputs);
                        Main.Root.stage.addEventListener(MouseEvent.CLICK, this.checkFeaturedNewsInputs);
                        this.m_featuredCustomMenu.Container.addChild(this.m_featuredLoadingShape);
                        return;
                    };
                    e = (e + 1);
                };
            };
            if (UnlockController.checkUnlocked(UnlockController.getUnlockableByID(Unlockable.ALTERNATE_TRACKS)))
            {
                UnlockController.nextMenuFunc = function ():void
                {
                    MenuController.intro3Menu.setVault(false);
                    MenuController.intro3Menu.show();
                };
                UnlockController.pendingUnlockScreens.push(UnlockController.getUnlockableByID(Unlockable.ALTERNATE_TRACKS));
                MenuController.postUnlockMenu.show();
            }
            else
            {
                MenuController.intro3Menu.setVault(false);
                MenuController.intro3Menu.show();
            };
        }


    }
}//package com.mcleodgaming.ssf2.menus


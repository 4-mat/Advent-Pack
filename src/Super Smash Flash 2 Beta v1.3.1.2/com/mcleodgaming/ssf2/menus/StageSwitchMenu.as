// Decompiled by AS3 Sorcerer 6.30
// www.as3sorcerer.com

//com.mcleodgaming.ssf2.menus.StageSwitchMenu

package com.mcleodgaming.ssf2.menus
{
    import com.mcleodgaming.ssf2.controllers.StageSwitchHand;
    import __AS3__.vec.Vector;
    import com.mcleodgaming.ssf2.controllers.StageSwitchButton;
    import com.mcleodgaming.ssf2.util.DisplayObjectTable;
    import flash.display.MovieClip;
    import com.mcleodgaming.ssf2.util.ResourceManager;
    import flash.geom.Rectangle;
    import com.mcleodgaming.ssf2.Main;
    import flash.events.MouseEvent;
    import com.mcleodgaming.ssf2.util.SaveData;
    import com.mcleodgaming.ssf2.audio.SoundQueue;
    import com.mcleodgaming.ssf2.controllers.MenuController;
    import com.mcleodgaming.ssf2.controllers.GameController;
    import com.mcleodgaming.ssf2.util.*;
    import com.mcleodgaming.ssf2.audio.*;
    import com.mcleodgaming.ssf2.controllers.*;
    import com.mcleodgaming.ssf2.engine.*;
    import __AS3__.vec.*;

    public class StageSwitchMenu extends Menu 
    {

        private var selectHand:StageSwitchHand;
        private var stageButtonsMaster:Vector.<StageSwitchButton>;
        private var stageButtonsNormal:Vector.<StageSwitchButton>;
        private var stageButtonsPast:Vector.<StageSwitchButton>;
        private var lastClickedNormal:StageSwitchButton;
        private var lastClickedPast:StageSwitchButton;
        protected var normalTable:DisplayObjectTable;
        protected var pastTable:DisplayObjectTable;
        protected var m_stageMCHash:Object;

        public function StageSwitchMenu()
        {
            var i:int;
            var j:int;
            var child:MovieClip;
            super();
            m_subMenu = ResourceManager.getLibraryMC("menu_stageswitch");
            m_backgroundID = "space";
            this.stageButtonsMaster = new Vector.<StageSwitchButton>();
            this.stageButtonsNormal = new Vector.<StageSwitchButton>();
            this.stageButtonsPast = new Vector.<StageSwitchButton>();
            this.lastClickedNormal = null;
            this.lastClickedPast = null;
            var mappings:Object = ResourceManager.getResourceByID("mappings").getProp("metadata");
            var normalStagesObj:Object = mappings.stage_switch_screen.normal;
            var pastStagesObj:Object = mappings.stage_switch_screen.past;
            var randomStagesObj:Array = mappings.random_stages.stages;
            var stageTypes:Array = ["normal", "past"];
            this.m_stageMCHash = {};
            i = 0;
            while (i < this.StageSwitchIconsMC.numChildren)
            {
                if ((this.StageSwitchIconsMC.getChildAt(i) is MovieClip))
                {
                    child = MovieClip(this.StageSwitchIconsMC.getChildAt(i));
                    child.parent.removeChild(child);
                    i--;
                };
                i++;
            };
            i = 0;
            while (i < randomStagesObj.length)
            {
                if (mappings.stage[randomStagesObj[i]])
                {
                    child = MovieClip(ResourceManager.getLibraryMC((randomStagesObj[i] + "_switch")));
                    child.gotoAndStop(1);
                    child.stageID = ((child.stageID) || (randomStagesObj[i]));
                    if (stageTypes.indexOf(child.stageType) >= 0)
                    {
                        this.m_stageMCHash[child.stageID] = child;
                        this.StageSwitchIconsMC.addChild(child);
                        this.stageButtonsMaster.push(new StageSwitchButton(this.m_stageMCHash[child.stageID], child.stageID));
                        if (child.stageType === "normal")
                        {
                            this.stageButtonsNormal.push(new StageSwitchButton(this.m_stageMCHash[child.stageID], child.stageID));
                        }
                        else
                        {
                            if (child.stageType === "past")
                            {
                                this.stageButtonsPast.push(new StageSwitchButton(this.m_stageMCHash[child.stageID], child.stageID));
                            };
                        };
                    };
                };
                i++;
            };
            this.normalTable = new DisplayObjectTable(new Rectangle(normalStagesObj.position.x, normalStagesObj.position.y, normalStagesObj.icon_size.width, normalStagesObj.icon_size.height));
            this.pastTable = new DisplayObjectTable(new Rectangle(pastStagesObj.position.x, pastStagesObj.position.y, pastStagesObj.icon_size.width, pastStagesObj.icon_size.height));
            i = 0;
            while (i < normalStagesObj.rows.length)
            {
                j = 0;
                while (j < normalStagesObj.rows[i].length)
                {
                    this.normalTable.insertObject(i, this.m_stageMCHash[normalStagesObj.rows[i][j]]);
                    j++;
                };
                i++;
            };
            i = 0;
            while (i < pastStagesObj.rows.length)
            {
                j = 0;
                while (j < pastStagesObj.rows[i].length)
                {
                    this.pastTable.insertObject(i, this.m_stageMCHash[pastStagesObj.rows[i][j]]);
                    j++;
                };
                i++;
            };
            this.updateStages();
            this.checkAllBtn();
            this.selectHand = new StageSwitchHand(m_subMenu, this.stageButtonsMaster, this.back_CLICK);
            this.selectHand.addClickEventClipCheckBounds(m_subMenu.allNormal_btn);
            this.selectHand.addClickEventClipCheckBounds(m_subMenu.allPast_btn);
            this.selectHand.addClickEventClipHitTest(m_subMenu.bg_top.back_btn);
            this.selectHand.addClickEventClipHitTest(m_subMenu.bg_top.home_btn);
            m_container.addChild(m_subMenu);
            m_subMenu.x = (Main.Width / 2);
            m_subMenu.y = (Main.Height / 2);
        }

        public function get StageSwitchIconsMC():MovieClip
        {
            return (m_subMenu.stageButtons);
        }

        override public function makeEvents():void
        {
            if (m_showCount == 0)
            {
                findSubMenuButtons();
                findSpecificMenuButtons(m_subMenu.bg_top);
            };
            super.makeEvents();
            this.selectHand.makeEvents();
            m_subMenu.bg_top.back_btn.addEventListener(MouseEvent.CLICK, this.back_CLICK);
            m_subMenu.bg_top.back_btn.addEventListener(MouseEvent.CLICK, this.back_ROLL_OVER);
            m_subMenu.allNormal_btn.addEventListener(MouseEvent.CLICK, this.allNormal_CLICK);
            m_subMenu.allNormal_btn.addEventListener(MouseEvent.MOUSE_OVER, this.allNormal_MOUSE_OVER);
            m_subMenu.allPast_btn.addEventListener(MouseEvent.CLICK, this.allPast_CLICK);
            m_subMenu.allPast_btn.addEventListener(MouseEvent.MOUSE_OVER, this.allPast_MOUSE_OVER);
            m_subMenu.bg_top.home_btn.addEventListener(MouseEvent.CLICK, this.home_CLICK);
            var i:int;
            i = 0;
            while (i < this.stageButtonsNormal.length)
            {
                this.stageButtonsNormal[i].setClickFunc(this.checkAllBtn);
                this.stageButtonsNormal[i].makeEvents();
                if ((((this.lastClickedNormal == null) && (this.stageButtonsNormal[i].getStatus())) && (this.stageButtonsNormal[i].ButtonInstance.visible)))
                {
                    this.lastClickedNormal = this.stageButtonsNormal[i];
                };
                i++;
            };
            i = 0;
            while (i < this.stageButtonsPast.length)
            {
                this.stageButtonsPast[i].makeEvents();
                this.stageButtonsPast[i].setClickFunc(this.checkAllBtn);
                if ((((this.lastClickedPast == null) && (this.stageButtonsPast[i].getStatus())) && (this.stageButtonsPast[i].ButtonInstance.visible)))
                {
                    this.lastClickedPast = this.stageButtonsPast[i];
                };
                i++;
            };
        }

        override public function killEvents():void
        {
            var i:int;
            super.killEvents();
            this.selectHand.killEvents();
            m_subMenu.bg_top.back_btn.removeEventListener(MouseEvent.CLICK, this.back_CLICK);
            m_subMenu.bg_top.back_btn.removeEventListener(MouseEvent.CLICK, this.back_ROLL_OVER);
            m_subMenu.allNormal_btn.removeEventListener(MouseEvent.CLICK, this.allNormal_CLICK);
            m_subMenu.allNormal_btn.removeEventListener(MouseEvent.MOUSE_OVER, this.allNormal_MOUSE_OVER);
            m_subMenu.allPast_btn.removeEventListener(MouseEvent.CLICK, this.allPast_CLICK);
            m_subMenu.allPast_btn.removeEventListener(MouseEvent.MOUSE_OVER, this.allPast_MOUSE_OVER);
            m_subMenu.bg_top.home_btn.removeEventListener(MouseEvent.CLICK, this.home_CLICK);
            i = 0;
            while (i < this.stageButtonsNormal.length)
            {
                this.stageButtonsNormal[i].killEvents();
                i++;
            };
            i = 0;
            while (i < this.stageButtonsPast.length)
            {
                this.stageButtonsPast[i].killEvents();
                i++;
            };
        }

        override public function show():void
        {
            var k:*;
            if ((!(Main.DEBUG)))
            {
                for (k in this.m_stageMCHash)
                {
                    if (SaveData.Unlocks[k] === false)
                    {
                        this.m_stageMCHash[k].visible = false;
                    };
                };
            };
            this.pastTable.spaceObjects();
            this.normalTable.spaceObjects();
            this.checkAllBtn();
            super.show();
        }

        private function back_CLICK(e:MouseEvent):void
        {
            SoundQueue.instance.playSoundEffect("menu_back");
            removeSelf();
        }

        private function back_ROLL_OVER(e:MouseEvent):void
        {
            SoundQueue.instance.playSoundEffect("menu_hover");
        }

        private function updateStages():void
        {
            var i:int;
            i = 0;
            while (i < this.stageButtonsNormal.length)
            {
                this.stageButtonsNormal[i].ButtonInstance.gotoAndStop(((SaveData.getStageStatus(this.stageButtonsNormal[i].ID)) ? "on" : "off"));
                i++;
            };
            i = 0;
            while (i < this.stageButtonsPast.length)
            {
                this.stageButtonsPast[i].ButtonInstance.gotoAndStop(((SaveData.getStageStatus(this.stageButtonsPast[i].ID)) ? "on" : "off"));
                i++;
            };
        }

        private function allNormal_CLICK(e:MouseEvent):void
        {
            var i:int;
            var totalOn:int;
            SoundQueue.instance.playSoundEffect("menu_select");
            var wasOn:Boolean = (m_subMenu.allNormal_btn.currentFrameLabel == "on");
            m_subMenu.allNormal_btn.gotoAndStop(((wasOn) ? "off" : "on"));
            i = 0;
            while (i < this.stageButtonsNormal.length)
            {
                if (this.stageButtonsNormal[i].ButtonInstance.visible)
                {
                    this.stageButtonsNormal[i].setStatus(wasOn);
                };
                i++;
            };
            i = 0;
            while (i < this.stageButtonsPast.length)
            {
                if (((this.stageButtonsPast[i].ButtonInstance.visible) && (this.stageButtonsPast[i].getStatus())))
                {
                    totalOn++;
                };
                i++;
            };
            if (totalOn == 0)
            {
                if ((!(this.lastClickedNormal)))
                {
                    this.lastClickedNormal = this.stageButtonsNormal[0];
                    this.lastClickedNormal.setStatus(true);
                }
                else
                {
                    this.lastClickedNormal.setStatus(true);
                };
            };
        }

        private function allNormal_MOUSE_OVER(e:MouseEvent):void
        {
            SoundQueue.instance.playSoundEffect("menu_hover");
        }

        private function allPast_CLICK(e:MouseEvent):void
        {
            var i:int;
            var totalOn:int;
            SoundQueue.instance.playSoundEffect("menu_select");
            var wasOn:Boolean = (m_subMenu.allPast_btn.currentFrameLabel == "on");
            m_subMenu.allPast_btn.gotoAndStop(((wasOn) ? "off" : "on"));
            i = 0;
            while (i < this.stageButtonsPast.length)
            {
                if (this.stageButtonsPast[i].ButtonInstance.visible)
                {
                    this.stageButtonsPast[i].setStatus(wasOn);
                };
                i++;
            };
            i = 0;
            while (i < this.stageButtonsNormal.length)
            {
                if (((this.stageButtonsNormal[i].ButtonInstance.visible) && (this.stageButtonsNormal[i].getStatus())))
                {
                    totalOn++;
                };
                i++;
            };
            if (totalOn == 0)
            {
                if ((!(this.lastClickedPast)))
                {
                    this.lastClickedPast = this.stageButtonsPast[1];
                    this.lastClickedPast.setStatus(true);
                }
                else
                {
                    this.lastClickedPast.setStatus(true);
                };
            };
        }

        private function allPast_MOUSE_OVER(e:MouseEvent):void
        {
            SoundQueue.instance.playSoundEffect("menu_hover");
        }

        private function checkAllBtn(e:StageSwitchButton=null):void
        {
            var i:int;
            var total1:int;
            var total2:int;
            var sub1:int;
            var sub2:int;
            var bType:int;
            if (this.stageButtonsNormal.indexOf(e) >= 0)
            {
                bType = 0;
                this.lastClickedNormal = e;
            }
            else
            {
                if (this.stageButtonsPast.indexOf(e) >= 0)
                {
                    bType = 1;
                    this.lastClickedPast = e;
                };
            };
            i = 0;
            while (i < this.stageButtonsNormal.length)
            {
                if (((this.stageButtonsNormal[i].ButtonInstance.visible) && (this.stageButtonsNormal[i].getStatus())))
                {
                    total1++;
                }
                else
                {
                    if ((!(this.stageButtonsNormal[i].ButtonInstance.visible)))
                    {
                        sub1++;
                    };
                };
                i++;
            };
            i = 0;
            while (i < this.stageButtonsPast.length)
            {
                if (((this.stageButtonsPast[i].ButtonInstance.visible) && (this.stageButtonsPast[i].getStatus())))
                {
                    total2++;
                }
                else
                {
                    if ((!(this.stageButtonsPast[i].ButtonInstance.visible)))
                    {
                        sub2++;
                    };
                };
                i++;
            };
            if (bType == 0)
            {
                m_subMenu.allNormal_btn.gotoAndStop(((total1 == (this.stageButtonsNormal.length - sub1)) ? "off" : "on"));
                if ((((total1 == 0) && (total2 == 0)) && (this.lastClickedNormal)))
                {
                    this.lastClickedNormal.setStatus(true);
                };
            };
            if (bType == 1)
            {
                m_subMenu.allPast_btn.gotoAndStop(((total2 == (this.stageButtonsPast.length - sub2)) ? "off" : "on"));
                if ((((total1 == 0) && (total2 == 0)) && (this.lastClickedPast)))
                {
                    this.lastClickedPast.setStatus(true);
                };
            };
        }

        private function home_CLICK(e:MouseEvent):void
        {
            SoundQueue.instance.playSoundEffect("menu_back");
            SoundQueue.instance.stopMusic();
            if (MenuController.CurrentCharacterSelectMenu)
            {
                MenuController.CurrentCharacterSelectMenu.resetScreen();
            };
            GameController.currentGame = null;
            MenuController.removeAllMenus();
            MenuController.titleMenu.show();
        }


    }
}//package com.mcleodgaming.ssf2.menus


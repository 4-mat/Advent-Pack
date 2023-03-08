// Decompiled by AS3 Sorcerer 6.30
// www.as3sorcerer.com

//com.mcleodgaming.ssf2.menus.StageSelectMenu

package com.mcleodgaming.ssf2.menus
{
    import __AS3__.vec.Vector;
    import com.mcleodgaming.ssf2.controllers.StageButton;
    import flash.display.MovieClip;
    import com.mcleodgaming.ssf2.controllers.StageSelectHand;
    import com.mcleodgaming.ssf2.util.DisplayObjectTable;
    import com.mcleodgaming.ssf2.util.ResourceManager;
    import com.mcleodgaming.ssf2.util.Utils;
    import com.mcleodgaming.ssf2.controllers.GameController;
    import flash.geom.Rectangle;
    import com.mcleodgaming.ssf2.Main;
    import flash.events.MouseEvent;
    import com.mcleodgaming.ssf2.util.SaveData;
    import com.mcleodgaming.ssf2.controllers.Game;
    import com.mcleodgaming.ssf2.audio.SoundQueue;
    import com.mcleodgaming.ssf2.controllers.MenuController;
    import com.mcleodgaming.ssf2.util.*;
    import com.mcleodgaming.ssf2.audio.*;
    import com.mcleodgaming.ssf2.controllers.*;
    import com.mcleodgaming.ssf2.engine.*;
    import com.mcleodgaming.ssf2.net.*;
    import __AS3__.vec.*;

    public class StageSelectMenu extends Menu 
    {

        private var stageButtons:Vector.<StageButton>;
        private var previewer:MovieClip;
        private var selectHand:StageSelectHand;
        protected var normalStageTable:DisplayObjectTable;
        protected var pastStageTable:DisplayObjectTable;
        protected var m_stageMCHash:Object;
        private var m_normal_btn:MovieClip;
        private var m_past_btn:MovieClip;
        private var m_unlockable_btn:MovieClip;
        private var m_other_btn:MovieClip;

        public function StageSelectMenu()
        {
            var i:int;
            var j:int;
            var child:MovieClip;
            super();
            m_subMenu = ResourceManager.getLibraryMC("menu_stageselect");
            m_backgroundID = "space";
            this.stageButtons = new Vector.<StageButton>();
            this.previewer = MovieClip(m_subMenu.stage_sample.previewer.addChild(ResourceManager.getLibraryMC("stagePreviewer")));
            this.previewer.name = "mc";
            var mappings:Object = ResourceManager.getResourceByID("mappings").getProp("metadata");
            var normalStagesObj:Object = mappings.stage_select_screen.normal;
            var pastStagesObj:Object = mappings.stage_select_screen.past;
            var allStages:Array = Utils.union(Utils.flatten(Utils.flatten((normalStagesObj.rows as Array)).concat(Utils.flatten((pastStagesObj.rows as Array)))));
            this.m_stageMCHash = {};
            i = 0;
            while (i < this.StageSelectionIconsMC.numChildren)
            {
                if ((this.StageSelectionIconsMC.getChildAt(i) is MovieClip))
                {
                    child = MovieClip(this.StageSelectionIconsMC.getChildAt(i));
                    child.parent.removeChild(child);
                    i--;
                };
                i++;
            };
            this.m_stageMCHash["xpstage"] = m_subMenu.sxp;
            i = 0;
            while (i < allStages.length)
            {
                if ((((mappings.stage[allStages[i]]) || (allStages[i] === "xpstage")) || (allStages[i] === "random")))
                {
                    child = MovieClip(ResourceManager.getLibraryMC((allStages[i] + "_stage_select")));
                    child.gotoAndStop(1);
                    child.stageID = ((child.stageID) || (allStages[i]));
                    this.m_stageMCHash[child.stageID] = child;
                    this.StageSelectionIconsMC.addChild(child);
                    this.stageButtons.push(new StageButton(GameController.currentGame, child, child.stageID));
                };
                i++;
            };
            i = 0;
            while (i < m_subMenu.numChildren)
            {
                if ((m_subMenu.getChildAt(i) is MovieClip))
                {
                    child = MovieClip(m_subMenu.getChildAt(i));
                    if (((child.name === "normal_btn") || (child.name === "past_btn")))
                    {
                        this.m_stageMCHash[child.name] = child;
                    };
                };
                i++;
            };
            this.selectHand = new StageSelectHand(m_subMenu, this.stageButtons, this.backCharSelect_CLICK);
            this.selectHand.addClickEventClipCheckBounds(m_subMenu.normal_btn);
            this.selectHand.addClickEventClipCheckBounds(m_subMenu.past_btn);
            this.selectHand.addClickEventClipHitTest(m_subMenu.bg_top.back_btn);
            this.selectHand.addClickEventClipHitTest(m_subMenu.hazardsbut);
            this.normalStageTable = new DisplayObjectTable(new Rectangle(normalStagesObj.position.x, normalStagesObj.position.y, normalStagesObj.icon_size.width, normalStagesObj.icon_size.height));
            this.pastStageTable = new DisplayObjectTable(new Rectangle(mappings.stage_select_screen.past.position.x, mappings.stage_select_screen.past.position.y, mappings.stage_select_screen.past.icon_size.width, mappings.stage_select_screen.past.icon_size.height));
            i = 0;
            while (i < normalStagesObj.rows.length)
            {
                j = 0;
                while (j < normalStagesObj.rows[i].length)
                {
                    this.normalStageTable.insertObject(i, this.m_stageMCHash[normalStagesObj.rows[i][j]]);
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
                    this.pastStageTable.insertObject(i, this.m_stageMCHash[pastStagesObj.rows[i][j]]);
                    j++;
                };
                i++;
            };
            this.m_normal_btn = m_subMenu.normal_btn;
            this.m_past_btn = m_subMenu.past_btn;
            this.m_unlockable_btn = m_subMenu.unlockable_btn;
            this.m_other_btn = m_subMenu.other_btn;
            this.m_normal_btn.visible = false;
            this.m_past_btn.visible = false;
            this.m_unlockable_btn.visible = false;
            this.m_other_btn.visible = false;
            this.m_normal_btn.gotoAndStop("on");
            this.m_past_btn.gotoAndStop("off");
            this.m_unlockable_btn.gotoAndStop("off");
            this.m_other_btn.gotoAndStop("off");
            m_container.addChild(m_subMenu);
            m_subMenu.x = (Main.Width / 2);
            m_subMenu.y = (Main.Height / 2);
            this.m_stageMCHash["xpstage"].visible = false;
            this.pastStageTable.hideAll();
            this.normalStageTable.showAll();
        }

        public function get StageSelectionIconsMC():MovieClip
        {
            return (m_subMenu.stageSelect);
        }

        override public function makeEvents():void
        {
            if (m_showCount == 0)
            {
                findSubMenuButtons();
                findSpecificMenuButtons(m_subMenu.bg_top);
                findSpecificMenuButtons(m_subMenu);
            };
            super.makeEvents();
            m_subMenu.bg_top.back_btn.addEventListener(MouseEvent.CLICK, this.backCharSelect_CLICK);
            m_subMenu.bg_top.back_btn.addEventListener(MouseEvent.MOUSE_OVER, this.backCharSelect_OVER);
            m_subMenu.hazardsbut.addEventListener(MouseEvent.CLICK, this.hazards_CLICK);
            this.m_normal_btn.addEventListener(MouseEvent.CLICK, this.showNormalStages);
            this.m_past_btn.addEventListener(MouseEvent.CLICK, this.showPastStages);
            this.m_other_btn.addEventListener(MouseEvent.CLICK, this.showOtherStages);
            this.selectHand.makeEvents();
            var i:int;
            while (i < this.stageButtons.length)
            {
                this.stageButtons[i].makeEvents();
                i++;
            };
            this.updateFields();
        }

        override public function killEvents():void
        {
            super.killEvents();
            m_subMenu.bg_top.back_btn.removeEventListener(MouseEvent.CLICK, this.backCharSelect_CLICK);
            m_subMenu.bg_top.back_btn.removeEventListener(MouseEvent.MOUSE_OVER, this.backCharSelect_OVER);
            m_subMenu.hazardsbut.removeEventListener(MouseEvent.CLICK, this.hazards_CLICK);
            this.m_normal_btn.removeEventListener(MouseEvent.CLICK, this.showNormalStages);
            this.m_past_btn.removeEventListener(MouseEvent.CLICK, this.showPastStages);
            this.m_other_btn.removeEventListener(MouseEvent.CLICK, this.showOtherStages);
            this.selectHand.killEvents();
            var i:int;
            while (i < this.stageButtons.length)
            {
                this.stageButtons[i].killEvents();
                i++;
            };
        }

        private function updateFields():void
        {
            if ((!(SaveData.Hazards)))
            {
                m_subMenu.hazardsbut.gotoAndStop("off");
            }
            else
            {
                m_subMenu.hazardsbut.gotoAndStop("on");
            };
        }

        public function setCurrentGame(game:Game):void
        {
            var i:int;
            while (i < this.stageButtons.length)
            {
                this.stageButtons[i].setCurrentGame(game);
                i++;
            };
        }

        private function showNormalStages(e:MouseEvent):void
        {
        }

        private function showPastStages(e:MouseEvent):void
        {
        }

        private function showUnlockableStages(e:MouseEvent):void
        {
        }

        private function showOtherStages(e:MouseEvent):void
        {
        }

        private function resetAll():void
        {
            this.normalStageTable.hideAll();
            this.pastStageTable.hideAll();
            this.m_normal_btn.gotoAndStop("off");
            this.m_past_btn.gotoAndStop("off");
            this.m_unlockable_btn.gotoAndStop("off");
            this.m_other_btn.gotoAndStop("off");
        }

        private function updateIcons():void
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
            }
            else
            {
                this.m_stageMCHash["xpstage"].visible = (!(ResourceManager.getResourceByID("xpstage", true) == null));
            };
            Utils.setBrightness(this.m_unlockable_btn, -100);
            Utils.setBrightness(this.m_other_btn, -100);
            this.m_stageMCHash["xpstage"].visible = Main.DEBUG;
        }

        override public function show():void
        {
            this.resetAll();
            this.pastStageTable.hideAll();
            this.normalStageTable.showAll();
            this.updateIcons();
            this.normalStageTable.spaceObjects();
            this.m_normal_btn.gotoAndStop("on");
            MovieClip(m_subMenu.stage_sample.previewer.getChildByName("mc")).gotoAndStop("paused");
            m_subMenu.stage_sample.stage_txt.text = "";
            this.selectHand.resetPosition();
            GameController.isStarted = false;
            super.show();
        }

        private function backCharSelect_CLICK(e:MouseEvent):void
        {
            removeSelf();
            SoundQueue.instance.playSoundEffect("menu_back");
            MenuController.CurrentCharacterSelectMenu.show();
        }

        private function backCharSelect_OVER(e:MouseEvent):void
        {
            SoundQueue.instance.playSoundEffect("menu_hover");
        }

        private function hazards_CLICK(e:MouseEvent):void
        {
            SoundQueue.instance.playSoundEffect("menu_hover");
            SaveData.toggleHazards();
            if (((MenuController.CurrentCharacterSelectMenu) && (MenuController.CurrentCharacterSelectMenu.GameObj)))
            {
                MenuController.CurrentCharacterSelectMenu.GameObj.LevelData.hazards = SaveData.Hazards;
            };
            this.updateFields();
        }


    }
}//package com.mcleodgaming.ssf2.menus


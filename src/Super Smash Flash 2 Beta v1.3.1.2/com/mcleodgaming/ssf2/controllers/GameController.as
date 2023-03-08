// Decompiled by AS3 Sorcerer 6.30
// www.as3sorcerer.com

//com.mcleodgaming.ssf2.controllers.GameController

package com.mcleodgaming.ssf2.controllers
{
    import com.mcleodgaming.ssf2.engine.StageData;
    import flash.display.MovieClip;
    import com.mcleodgaming.ssf2.menus.HudMenu;
    import com.mcleodgaming.ssf2.menus.ConstantDebuggerMenu;
    import com.mcleodgaming.ssf2.util.VcamSettings;
    import com.mcleodgaming.ssf2.Main;
    import __AS3__.vec.Vector;
    import com.mcleodgaming.ssf2.enums.Mode;
    import com.mcleodgaming.ssf2.util.ResourceManager;
    import com.mcleodgaming.ssf2.util.Utils;
    import com.mcleodgaming.ssf2.util.Resource;
    import com.mcleodgaming.ssf2.enums.ModeFeatures;
    import com.mcleodgaming.ssf2.net.MultiplayerManager;
    import flash.events.Event;
    import com.mcleodgaming.ssf2.items.ItemsListData;
    import com.mcleodgaming.ssf2.engine.HitBoxManager;
    import com.mcleodgaming.ssf2.engine.HitBoxAnimation;
    import com.mcleodgaming.ssf2.util.SaveData;
    import com.mcleodgaming.ssf2.util.Controller;
    import com.mcleodgaming.ssf2.audio.SoundQueue;
    import flash.system.System;
    import com.mcleodgaming.ssf2.engine.*;
    import com.mcleodgaming.ssf2.util.*;
    import com.mcleodgaming.ssf2.audio.*;
    import __AS3__.vec.*;

    public class GameController 
    {

        public static var stageData:StageData;
        public static var tmpStageData:StageData;
        public static var currentGame:Game;
        public static var onlineModeMatchSettings:Object;
        public static var tmpGame:Game;
        public static var weather:MovieClip;
        public static var cutscene:MovieClip;
        public static var tags:MovieClip;
        public static var hud:HudMenu;
        public static var constantDebugger:ConstantDebuggerMenu;
        public static var stage:MovieClip;
        public static var background:MovieClip;
        public static var stageMusic:String;
        public static var loopLoc:Number;
        public static var cameraParameters:VcamSettings;
        public static var isStarted:Boolean;
        private static var matchStarted:Boolean;
        private static var m_prepped:Boolean = false;

        {
            init();
        }


        public static function init():void
        {
            weather = null;
            cutscene = null;
            tags = null;
            hud = null;
            constantDebugger = null;
            stage = null;
            background = null;
            stageMusic = null;
            loopLoc = 0;
            cameraParameters = null;
            matchStarted = false;
        }

        private static function getStatsNameForPlayer(id:int, playerSettings:Vector.<PlayerSetting>):String
        {
            var i:int;
            var statsName:String = playerSettings[id].character;
            if ((!(statsName)))
            {
                i = (id - 1);
                while (i >= 0)
                {
                    if (playerSettings[i].character)
                    {
                        statsName = ((playerSettings[i].character === "random") ? Main.RandCharList[i].StatsName : playerSettings[i].character);
                    };
                    i--;
                };
            }
            else
            {
                if (statsName === "random")
                {
                    statsName = Main.RandCharList[id].StatsName;
                };
            };
            return (statsName);
        }

        private static function setupRandomCostumes():void
        {
            var costumeNum:int;
            var randCostumeArr:Array;
            var found:Boolean;
            var i:int;
            var j:int;
            var statsName:String;
            var altStatsName:String;
            var k:int;
            while (k < currentGame.PlayerSettings.length)
            {
                if (((((!(currentGame.SuddenDeath)) && (!(currentGame.LevelData.teams))) && ((currentGame.PlayerSettings[k].character == "random") || (currentGame.PlayerSettings[k].isRandom))) || ((currentGame.GameMode == Mode.TRAINING) && (!(currentGame.PlayerSettings[k].character)))))
                {
                    costumeNum = 0;
                    randCostumeArr = new Array();
                    found = false;
                    i = 0;
                    j = 0;
                    statsName = GameController.getStatsNameForPlayer(k, currentGame.PlayerSettings);
                    i = 0;
                    while (i < currentGame.PlayerSettings.length)
                    {
                        if (((((currentGame.PlayerSettings[i].exist) && (currentGame.PlayerSettings[i].character)) && (currentGame.PlayerSettings[i].costume == -1)) && (!(i == k))))
                        {
                            found = true;
                        };
                        i++;
                    };
                    if ((!(found)))
                    {
                        randCostumeArr.push(-1);
                    };
                    while (ResourceManager.getCostume(statsName, null, costumeNum) != null)
                    {
                        found = false;
                        i = 0;
                        while (i < currentGame.PlayerSettings.length)
                        {
                            altStatsName = GameController.getStatsNameForPlayer(i, currentGame.PlayerSettings);
                            if (((((currentGame.PlayerSettings[i].exist) && (altStatsName)) && (currentGame.PlayerSettings[i].costume == costumeNum)) && (!(i == k))))
                            {
                                found = true;
                            };
                            i++;
                        };
                        if ((!(found)))
                        {
                            randCostumeArr.push(costumeNum);
                        };
                        costumeNum++;
                    };
                    currentGame.PlayerSettings[k].costume = randCostumeArr[Utils.randomInteger(0, (randCostumeArr.length - 1))];
                }
                else
                {
                    Utils.random();
                };
                k++;
            };
        }

        public static function startMatch(game:Game=null):void
        {
            var currStage:Resource;
            var hasMusic:Boolean;
            var musicID:String;
            var musicResource:Resource;
            var id3:*;
            if (game)
            {
                GameController.currentGame = game;
            };
            if ((!(matchStarted)))
            {
                if (((ModeFeatures.hasFeature(ModeFeatures.MULTIPLAYER_MANAGER, GameController.currentGame.GameMode)) && (!(GameController.currentGame.SuddenDeath))))
                {
                    if (MultiplayerManager.RoomData.matchSettings.gameMode === Mode.ONLINE_ARENA)
                    {
                        GameController.currentGame.CustomModeObj.PreviousMenu = ((MultiplayerManager.IsHost) ? MenuController.arenaCharacterSelectMenu : MenuController.onlineCharacterMenu);
                    };
                };
                Main.Root.visible = false;
                matchStarted = true;
                weather = new MovieClip();
                cutscene = new MovieClip();
                tags = new MovieClip();
                background = new MovieClip();
                hud = new HudMenu();
                constantDebugger = new ConstantDebuggerMenu();
                if (Main.DEBUG)
                {
                    hud.Container.addChild(constantDebugger.Container);
                };
                stage = ResourceManager.getLibraryMC(((GameController.currentGame.LevelData.stage == "xpstage") ? "xpstage" : ("stage_" + GameController.currentGame.LevelData.stage)));
                stage.name = "stageMC";
                Main.Root.addChild(background);
                Main.Root.addChild(stage);
                Main.Root.addChild(tags);
                Main.Root.addChild(weather);
                Main.Root.addChild(cutscene);
                Main.Root.addChild(hud.Container);
                currStage = ResourceManager.getResourceByID(GameController.currentGame.LevelData.stage);
                hasMusic = ((GameController.currentGame.LevelData.musicOverride) ? true : ((currStage.getProp("music")) && (currStage.getProp("music").length)));
                musicID = ((hasMusic) ? ((GameController.currentGame.LevelData.musicOverride) || (currStage.getProp("music")[Main.RandMusicIndex].id)) : null);
                musicResource = ((musicID) ? ResourceManager.getResourceByID(musicID) : null);
                if ((((hasMusic) && (musicResource)) && (musicResource.getProp("id3"))))
                {
                    id3 = musicResource.getProp("id3");
                    if (id3.songName)
                    {
                        hud.displayMusicInfo(id3.songName);
                    };
                };
                stageMusic = null;
                loopLoc = 0;
                if (musicResource)
                {
                    stageMusic = ((musicResource.getProp("music")) || (null));
                    loopLoc = ((musicResource.getProp("musicLoop")) || (0));
                };
                cameraParameters = new VcamSettings(currStage.getProp("camera"));
                prepOtherHitBoxStuff();
                Main.Root.stage.addEventListener(Event.ENTER_FRAME, actuallyStartMatch);
            };
        }

        public static function prepOtherHitBoxStuff():void
        {
            if (m_prepped)
            {
                return;
            };
            m_prepped = true;
            var i:int;
            var j:int;
            var tmpMC:MovieClip;
            var m_managerList:Vector.<String> = new Vector.<String>();
            i = 0;
            while (i < ItemsListData.DATA.length)
            {
                m_managerList.push(ItemsListData.DATA[i].linkage_id);
                i++;
            };
            j = 0;
            while (j < m_managerList.length)
            {
                if (HitBoxManager.HitBoxManageList[m_managerList[j]])
                {
                }
                else
                {
                    tmpMC = ResourceManager.getLibraryMC(m_managerList[j]);
                    if (tmpMC)
                    {
                        i = 0;
                        while (i < tmpMC.totalFrames)
                        {
                            tmpMC.gotoAndStop((i + 1));
                            if (tmpMC.stance)
                            {
                                Utils.removeActionScript(tmpMC.stance);
                                HitBoxAnimation.createHitBoxAnimation(((m_managerList[j] + "_") + tmpMC.currentLabel), tmpMC.stance, tmpMC);
                            };
                            i++;
                        };
                        tmpMC = null;
                    };
                };
                j++;
            };
        }

        private static function actuallyStartMatch(e:Event):void
        {
            Main.Root.stage.removeEventListener(Event.ENTER_FRAME, actuallyStartMatch);
            SaveData.Unlocks.ghostNessSDs = 0;
            var stageAPI:Class;
            var currStage:Resource = ResourceManager.getResourceByID(GameController.currentGame.LevelData.stage);
            if (currStage)
            {
                stageAPI = (((currStage.getProp("stage")) || (currStage.MetaData.BASE_CLASSES.SSF2Stage)) || (null));
            };
            var i:int;
            Utils.setRandSeed(currentGame.LevelData.randSeed);
            Utils.shuffleRandom();
            Main.prepRandomCharacters(currentGame.PlayerSettings.length);
            if (((GameController.currentGame.GameMode === Mode.ONLINE_WAITING_ROOM) && (GameController.currentGame.PlayerSettings[0].character == "random")))
            {
                Main.RandCharList[0] = Main.RandCharList[(MultiplayerManager.PlayerID - 1)];
            };
            GameController.setupRandomCostumes();
            if (ModeFeatures.hasFeature(ModeFeatures.MULTIPLAYER_MANAGER, GameController.currentGame.GameMode))
            {
                GameController.currentGame.fixDuplicateCostumes();
            };
            var controllers:Vector.<Controller> = ((ModeFeatures.hasFeature(ModeFeatures.MULTIPLAYER_MANAGER, GameController.currentGame.GameMode)) ? MultiplayerManager.Controllers : SaveData.Controllers);
            GameController.stageData = new StageData(controllers, Main.Root, stageAPI, stage, hud, cameraParameters, GameController.currentGame, SoundQueue.instance, stageMusic, loopLoc);
            constantDebugger.makeEvents();
            GameController.stageData.startGame();
        }

        public static function endMatch():void
        {
            if (matchStarted)
            {
                GameController.stageData.CamRef.die();
                weather.parent.removeChild(weather);
                cutscene.parent.removeChild(cutscene);
                tags.parent.removeChild(tags);
                stage.parent.removeChild(stage);
                background.parent.removeChild(background);
                hud.removeSelf();
                constantDebugger.killEvents();
                init();
                trace("Game graphics and stage data disposed");
            };
        }

        public static function destroyStageData():void
        {
            if (GameController.stageData)
            {
                GameController.stageData.dispose();
            };
            GameController.stage = null;
            GameController.stageData = null;
            GameController.tmpStageData = null;
            GameController.tmpGame = null;
            Main.clearRandomCharacterPrep();
            SoundQueue.instance.setLoopFunction(SoundQueue.instance.loopMusic);
            System.gc();
        }


    }
}//package com.mcleodgaming.ssf2.controllers


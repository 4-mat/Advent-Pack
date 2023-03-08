// Decompiled by AS3 Sorcerer 6.30
// www.as3sorcerer.com

//com.mcleodgaming.ssf2.controllers.Game

package com.mcleodgaming.ssf2.controllers
{
    import __AS3__.vec.Vector;
    import com.mcleodgaming.ssf2.engine.ReplayData;
    import com.mcleodgaming.ssf2.modes.CustomMode;
    import com.mcleodgaming.ssf2.engine.CustomMatch;
    import com.mcleodgaming.ssf2.Main;
    import com.mcleodgaming.ssf2.util.SaveData;
    import com.mcleodgaming.ssf2.util.Utils;
    import com.mcleodgaming.ssf2.util.ResourceManager;
    import com.mcleodgaming.ssf2.enums.*;
    import com.mcleodgaming.ssf2.engine.*;
    import com.mcleodgaming.ssf2.util.*;
    import com.mcleodgaming.ssf2.audio.*;
    import __AS3__.vec.*;

    public class Game 
    {

        private var m_playerSettings:Vector.<PlayerSetting>;
        private var m_levelData:GameSettings;
        private var m_items:ItemSettings;
        private var m_gameMode:uint;
        private var m_replayData:ReplayData;
        private var m_suddenDeath:Boolean;
        private var m_customMode:CustomMode;
        private var m_customMatch:CustomMatch;

        public function Game(playerLimit:int=-1, gameMode:uint=0)
        {
            if (playerLimit <= 0)
            {
                playerLimit = Main.MAXPLAYERS;
            };
            this.m_gameMode = gameMode;
            this.m_suddenDeath = false;
            this.m_playerSettings = new Vector.<PlayerSetting>();
            this.m_levelData = new GameSettings();
            this.m_items = new ItemSettings();
            this.m_replayData = null;
            var maxPlayers:int = playerLimit;
            var i:int = 1;
            while (i <= maxPlayers)
            {
                this.m_playerSettings.push(new PlayerSetting());
                this.m_playerSettings[(i - 1)].importSettings({
                    "human":(i == 1),
                    "team_prev":((i == 1) ? 1 : 2)
                });
                i++;
            };
            this.m_levelData.hazards = SaveData.Hazards;
        }

        public function get Time():Number
        {
            return (this.m_levelData.time as Number);
        }

        public function set Time(value:Number):void
        {
            this.m_levelData.time = value;
            if (this.m_levelData.time <= 0)
            {
                this.m_levelData.time = 99;
            }
            else
            {
                if (this.m_levelData.time > 99)
                {
                    this.m_levelData.time = 1;
                };
            };
        }

        public function get CustomMatchObj():CustomMatch
        {
            return (this.m_customMatch);
        }

        public function set CustomMatchObj(value:CustomMatch):void
        {
            this.m_customMatch = value;
        }

        public function get CustomModeObj():CustomMode
        {
            return (this.m_customMode);
        }

        public function set CustomModeObj(value:CustomMode):void
        {
            this.m_customMode = value;
        }

        public function get CountDown():Boolean
        {
            return (this.m_levelData.countdown as Boolean);
        }

        public function set CountDown(value:Boolean):void
        {
            this.m_levelData.countdown = value;
        }

        public function get SizeRatio():Number
        {
            return (this.m_levelData.sizeRatio as Number);
        }

        public function get ShowPlayerID():Boolean
        {
            return (this.m_levelData.showPlayerID as Boolean);
        }

        public function set ShowPlayerID(value:Boolean):void
        {
            this.m_levelData.showPlayerID = value;
        }

        public function set SizeRatio(value:Number):void
        {
            this.m_levelData.sizeRatio = value;
        }

        public function get LevelData():GameSettings
        {
            return (this.m_levelData);
        }

        public function set LevelData(value:GameSettings):void
        {
            this.m_levelData = value;
        }

        public function get Lives():Number
        {
            return (this.m_levelData.lives as Number);
        }

        public function set Lives(value:Number):void
        {
            this.m_levelData.lives = value;
            if (this.m_levelData.lives <= 0)
            {
                this.m_levelData.lives = 99;
            }
            else
            {
                if (this.m_levelData.lives > 99)
                {
                    this.m_levelData.lives = 1;
                };
            };
            var i:int;
            while (i < this.m_playerSettings.length)
            {
                this.m_playerSettings[i].lives = this.m_levelData.lives;
                i++;
            };
        }

        public function get UsingStamina():Boolean
        {
            return (this.m_levelData.usingStamina);
        }

        public function set UsingStamina(value:Boolean):void
        {
            this.m_levelData.usingStamina = value;
        }

        public function get UsingTime():Boolean
        {
            return (this.m_levelData.usingTime);
        }

        public function set UsingTime(value:Boolean):void
        {
            this.m_levelData.usingTime = value;
        }

        public function get UsingLives():Boolean
        {
            return (this.m_levelData.usingLives);
        }

        public function set UsingLives(value:Boolean):void
        {
            this.m_levelData.usingLives = value;
        }

        public function get FinalSmashMeter():Boolean
        {
            return (this.m_levelData.finalSmashMeter);
        }

        public function set FinalSmashMeter(value:Boolean):void
        {
            this.m_levelData.finalSmashMeter = value;
            var i:int;
            while (i < this.m_playerSettings.length)
            {
                this.m_playerSettings[i].finalSmashMeter = this.m_levelData.finalSmashMeter;
                i++;
            };
        }

        public function get ScoreDisplay():Boolean
        {
            return (this.m_levelData.scoreDisplay);
        }

        public function set ScoreDisplay(value:Boolean):void
        {
            this.m_levelData.scoreDisplay = value;
        }

        public function get HudDisplay():Boolean
        {
            return (this.m_levelData.hudDisplay);
        }

        public function set HudDisplay(value:Boolean):void
        {
            this.m_levelData.hudDisplay = value;
        }

        public function get PauseEnabled():Boolean
        {
            return (this.m_levelData.pauseEnabled);
        }

        public function set PauseEnabled(value:Boolean):void
        {
            this.m_levelData.pauseEnabled = value;
        }

        public function get TotalPlayers():Number
        {
            var count:Number = 0;
            var i:int;
            while (i < this.m_playerSettings.length)
            {
                if (((!(this.m_playerSettings[i].character == null)) && (!(this.m_playerSettings[i].character == null))))
                {
                    count++;
                };
                i++;
            };
            return (count);
        }

        public function get DamageRatio():Number
        {
            return (this.m_levelData.damageRatio as Number);
        }

        public function set DamageRatio(value:Number):void
        {
            this.m_levelData.damageRatio = value;
            if (this.m_levelData.damageRatio > 2)
            {
                this.m_levelData.damageRatio = 2;
            }
            else
            {
                if (this.m_levelData.damageRatio < 0.5)
                {
                    this.m_levelData.damageRatio = 0.5;
                };
            };
            var i:int;
            while (i < this.m_playerSettings.length)
            {
                this.m_playerSettings[i].damageRatio = this.m_levelData.damageRatio;
                i++;
            };
        }

        public function set ItemFrequency(value:Number):void
        {
            this.m_items.frequency = value;
            if (this.m_items.frequency > 5)
            {
                this.m_items.frequency = 5;
            }
            else
            {
                if (this.m_items.frequency < 0)
                {
                    this.m_items.frequency = 0;
                };
            };
        }

        public function get Items():ItemSettings
        {
            return (this.m_items);
        }

        public function set Items(value:ItemSettings):void
        {
            this.m_items = value;
        }

        public function get StartDamage():Number
        {
            return (this.m_levelData.startDamage as Number);
        }

        public function set StartDamage(value:Number):void
        {
            this.m_levelData.startDamage = value;
            if (this.m_levelData.startDamage > 999)
            {
                this.m_levelData.startDamage = 999;
            }
            else
            {
                if (this.m_levelData.startDamage < 0)
                {
                    this.m_levelData.startDamage = 0;
                };
            };
            var i:int;
            while (i < this.m_playerSettings.length)
            {
                this.m_playerSettings[i].startDamage = this.m_levelData.startDamage;
                i++;
            };
        }

        public function get SuddenDeath():Boolean
        {
            return (this.m_suddenDeath);
        }

        public function set SuddenDeath(value:Boolean):void
        {
            this.m_suddenDeath = value;
        }

        public function get GameMode():uint
        {
            return (this.m_gameMode);
        }

        public function set GameMode(value:uint):void
        {
            this.m_gameMode = value;
        }

        public function get PlayerSettings():Vector.<PlayerSetting>
        {
            return (this.m_playerSettings);
        }

        public function get ReplayDataObj():ReplayData
        {
            return (this.m_replayData);
        }

        public function set ReplayDataObj(value:ReplayData):void
        {
            this.m_replayData = value;
        }

        public function set PlayerSettings(settings:Vector.<PlayerSetting>):void
        {
            this.m_playerSettings = settings;
        }

        public function loadSavedVSOptions():void
        {
            var currGame:Object = SaveData.getSavedVSOptions();
            this.LevelData.time = currGame.VS_Time;
            this.LevelData.showPlayerID = currGame.VS_DisplayPlayer;
            this.LevelData.lives = currGame.VS_Lives;
            this.LevelData.startDamage = currGame.VS_StartDamage;
            this.LevelData.startStamina = currGame.VS_StartStamina;
            this.LevelData.usingLives = currGame.VS_UsingLives;
            this.LevelData.usingTime = currGame.VS_UsingTime;
            this.LevelData.usingStamina = currGame.VS_UsingStamina;
            this.LevelData.teamDamage = currGame.teamDamage;
            this.LevelData.damageRatio = currGame.VS_DamageRatio;
            this.LevelData.scoreLimit = currGame.arenaScore;
            this.LevelData.finalSmashMeter = currGame.VS_FinalSmashMeter;
            this.LevelData.scoreDisplay = currGame.VS_ScoreDisplay;
            this.LevelData.hudDisplay = currGame.VS_HudDisplay;
            this.LevelData.pauseEnabled = currGame.VS_PauseEnabled;
            var i:int;
            while (i < this.m_playerSettings.length)
            {
                this.m_playerSettings[i].finalSmashMeter = currGame.VS_FinalSmashMeter;
                this.m_playerSettings[i].damageRatio = currGame.VS_DamageRatio;
                this.m_playerSettings[i].lives = currGame.VS_Lives;
                this.m_playerSettings[i].level = currGame[("VS_CPULevel" + (i + 1))];
                i++;
            };
            this.m_items.frequency = currGame.VS_ItemFreq;
            this.m_items.items = Utils.cloneObject(currGame.VS_Items);
        }

        public function fixDuplicateCostumes():void
        {
            var invalidCostumes:Array;
            var j:int;
            var availableCostumes:Array;
            var i:int;
            while (i < this.m_playerSettings.length)
            {
                if ((((this.m_playerSettings[i].character) && (!(this.m_playerSettings[i].character === "xp"))) && (!(this.m_playerSettings[i].character === "random"))))
                {
                    invalidCostumes = [];
                    j = 0;
                    while (j < this.m_playerSettings.length)
                    {
                        if (j !== i)
                        {
                            if (((this.m_playerSettings[i].character === this.m_playerSettings[j].character) && (this.m_playerSettings[i].costume === this.m_playerSettings[j].costume)))
                            {
                                invalidCostumes.push(this.m_playerSettings[i].costume);
                            };
                        };
                        j++;
                    };
                    if ((!(invalidCostumes.length)))
                    {
                    }
                    else
                    {
                        availableCostumes = ResourceManager.getAllCostumes(this.m_playerSettings[i].character, null);
                        if (invalidCostumes.indexOf(-1) < 0)
                        {
                            this.m_playerSettings[i].costume = -1;
                        }
                        else
                        {
                            j = 0;
                            while (j < availableCostumes.length)
                            {
                                if (invalidCostumes.indexOf(j) < 0)
                                {
                                    this.m_playerSettings[i].costume = j;
                                    break;
                                };
                                j++;
                            };
                        };
                    };
                };
                i++;
            };
        }

        public function exportSettings():Object
        {
            var obj:Object = new Object();
            obj.levelData = this.m_levelData.exportSettings();
            obj.items = this.m_items.exportSettings();
            obj.playerSettings = [];
            var i:int;
            while (i < this.m_playerSettings.length)
            {
                obj.playerSettings.push(this.m_playerSettings[i].exportSettings());
                i++;
            };
            return (obj);
        }

        public function importSettings(obj:Object):void
        {
            this.m_levelData.importSettings(obj.levelData);
            this.m_items.importSettings(obj.items);
            this.m_playerSettings = new Vector.<PlayerSetting>();
            var i:int;
            while (i < obj.playerSettings.length)
            {
                this.m_playerSettings.push(new PlayerSetting());
                this.m_playerSettings[i].importSettings(obj.playerSettings[i]);
                i++;
            };
        }


    }
}//package com.mcleodgaming.ssf2.controllers


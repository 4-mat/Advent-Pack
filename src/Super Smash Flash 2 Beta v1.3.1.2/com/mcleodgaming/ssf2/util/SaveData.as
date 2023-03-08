// Decompiled by AS3 Sorcerer 6.30
// www.as3sorcerer.com

//com.mcleodgaming.ssf2.util.SaveData

package com.mcleodgaming.ssf2.util
{
    import flash.net.SharedObject;
    import __AS3__.vec.Vector;
    import com.mcleodgaming.mgn.net.ProtocolSetting;
    import com.mcleodgaming.ssf2.Main;
    import flash.events.NetStatusEvent;
    import flash.filesystem.File;
    import com.mcleodgaming.ssf2.audio.SoundQueue;
    import flash.utils.ByteArray;
    import flash.filesystem.FileStream;
    import flash.filesystem.FileMode;
    import com.mcleodgaming.ssf2.controllers.Game;
    import com.mcleodgaming.ssf2.input.Gamepad;
    import com.mcleodgaming.ssf2.engine.*;
    import __AS3__.vec.*;

    public class SaveData 
    {

        private static var m_sharedObject:SharedObject;
        private static var m_localObject:Object;
        private static const m_currentSaveFileName:String = "ssf2_beta_1_3_1.dat";
        private static const m_previousSaveFileNames:Array = ["ssf2_beta.dat", "ssf2_beta_1_1.dat", "ssf2_beta_1_2.dat", "ssf2_beta_1_2_1.dat", "ssf2_beta_1_2_2.dat", "ssf2_beta_1_2_3.dat", "ssf2_beta_1_2_4.dat", "ssf2_beta_1_2_5.dat", "ssf2_beta_1_3_0.dat"];
        private static const m_saveFileFriendlyNamesList:Array = [{
            "pattern":/^ssf2_beta(?:\.dat)?$/,
            "value":"SSF2 Beta 1.0.*"
        }, {
            "pattern":/^ssf2_beta_1_1(?:\.dat)?$/,
            "value":"SSF2 Beta 1.1.*"
        }, {
            "pattern":/^ssf2_beta_1_2(?:\.dat)?$/,
            "value":"SSF2 Beta 1.2.0.*"
        }, {
            "pattern":/^ssf2_beta_1_2_1(?:\.dat)?$/,
            "value":"SSF2 Beta 1.2.1.*"
        }, {
            "pattern":/^ssf2_beta_1_2_2(?:\.dat)?$/,
            "value":"SSF2 Beta 1.2.2.*"
        }, {
            "pattern":/^ssf2_beta_1_2_3(?:\.dat)?$/,
            "value":"SSF2 Beta 1.2.3.*"
        }, {
            "pattern":/^ssf2_beta_1_2_4(?:\.dat)?$/,
            "value":"SSF2 Beta 1.2.4.*"
        }, {
            "pattern":/^ssf2_beta_1_2_5(?:\.dat)?$/,
            "value":"SSF2 Beta 1.2.5.*"
        }, {
            "pattern":/^ssf2_beta_1_3_0(?:\.dat)?$/,
            "value":"SSF2 Beta 1.3.0.*"
        }];
        public static var Controllers:Vector.<Controller>;
        public static var corrupted:Boolean = false;
        private static var _lastPowerCheck:Date;

        {
            init();
        }


        public static function saveDataFileToFriendlyName(name:String):String
        {
            var i:int;
            while (i < SaveData.m_saveFileFriendlyNamesList.length)
            {
                if (SaveData.m_saveFileFriendlyNamesList[i].pattern.test(name))
                {
                    return (SaveData.m_saveFileFriendlyNamesList[i].value);
                };
                i++;
            };
            return (name);
        }

        public static function init():void
        {
            _lastPowerCheck = new Date();
        }

        public static function initializeSaveData(upgradeOldData:Boolean=true):void
        {
            var i:int;
            trace("SaveData initialized");
            loadGame(upgradeOldData);
            if ((((m_localObject.game == undefined) || (m_localObject.game.exists == undefined)) || (m_localObject.game.exists == false)))
            {
                m_localObject.game = SaveDataMigrations.migrate(SaveDataMigrations.getInitialData());
                ProtocolSetting.tcpIP = m_localObject.game.options.tcpIP;
                ProtocolSetting.tcpPort = m_localObject.game.options.tcpPort;
                ProtocolSetting.udpIP = m_localObject.game.options.udpIP;
                ProtocolSetting.udpPort = m_localObject.game.options.udpPort;
                SaveData.Controllers = new Vector.<Controller>();
                i = 0;
                while (i < Main.MAXPLAYERS)
                {
                    if (i === 0)
                    {
                        SaveData.Controllers.push(new Controller((i + 1), {
                            "UP":87,
                            "DOWN":83,
                            "LEFT":65,
                            "RIGHT":68,
                            "BUTTON1":79,
                            "BUTTON2":80,
                            "GRAB":85,
                            "START":8,
                            "TAUNT":49,
                            "SHIELD":73,
                            "JUMP":0,
                            "JUMP2":0,
                            "C_UP":0,
                            "C_DOWN":0,
                            "C_LEFT":0,
                            "C_RIGHT":0,
                            "DASH":0,
                            "AUTO_DASH":0,
                            "DT_DASH":1,
                            "TAP_JUMP":1
                        }));
                    }
                    else
                    {
                        if (i === 1)
                        {
                            SaveData.Controllers.push(new Controller((i + 1), {
                                "UP":38,
                                "DOWN":40,
                                "LEFT":37,
                                "RIGHT":39,
                                "BUTTON1":98,
                                "BUTTON2":99,
                                "GRAB":101,
                                "START":96,
                                "TAUNT":100,
                                "SHIELD":97,
                                "JUMP":0,
                                "JUMP2":0,
                                "C_UP":0,
                                "C_DOWN":0,
                                "C_LEFT":0,
                                "C_RIGHT":0,
                                "DASH":0,
                                "AUTO_DASH":0,
                                "DT_DASH":1,
                                "TAP_JUMP":1
                            }));
                        }
                        else
                        {
                            SaveData.Controllers.push(new Controller((i + 1), {
                                "UP":0,
                                "DOWN":0,
                                "LEFT":0,
                                "RIGHT":0,
                                "BUTTON1":0,
                                "BUTTON2":0,
                                "GRAB":0,
                                "START":0,
                                "TAUNT":0,
                                "SHIELD":0,
                                "JUMP":0,
                                "JUMP2":0,
                                "C_UP":0,
                                "C_DOWN":0,
                                "C_LEFT":0,
                                "C_RIGHT":0,
                                "DASH":0,
                                "AUTO_DASH":0,
                                "DT_DASH":1,
                                "TAP_JUMP":1
                            }));
                        };
                    };
                    m_localObject.game.controlSettings[("player" + (i + 1))] = SaveData.Controllers[i].getControls();
                    i++;
                };
                saveGame();
            }
            else
            {
                SaveDataMigrations.migrate(m_localObject.game);
                m_localObject.game.records.misc.powerCount++;
                ProtocolSetting.tcpIP = m_localObject.game.options.tcpIP;
                ProtocolSetting.tcpPort = m_localObject.game.options.tcpPort;
                ProtocolSetting.udpIP = m_localObject.game.options.udpIP;
                ProtocolSetting.udpPort = m_localObject.game.options.udpPort;
                SaveData.Controllers = new Vector.<Controller>();
                i = 0;
                while (i < Main.MAXPLAYERS)
                {
                    SaveData.Controllers.push(new Controller((i + 1), {
                        "UP":0,
                        "DOWN":0,
                        "LEFT":0,
                        "RIGHT":0,
                        "BUTTON1":0,
                        "BUTTON2":0,
                        "GRAB":0,
                        "START":0,
                        "TAUNT":0,
                        "SHIELD":0,
                        "JUMP":0,
                        "JUMP2":0,
                        "C_UP":0,
                        "C_DOWN":0,
                        "C_LEFT":0,
                        "C_RIGHT":0,
                        "DASH":0,
                        "AUTO_DASH":0,
                        "DT_DASH":1,
                        "TAP_JUMP":1
                    }));
                    if (m_localObject.game.controlSettings[("player" + (i + 1))])
                    {
                        SaveData.Controllers[i].setControls(m_localObject.game.controlSettings[("player" + (i + 1))]);
                    };
                    i++;
                };
            };
        }

        private static function onStatus(e:NetStatusEvent):void
        {
            if (e.info.level == "error")
            {
                trace('You need to allow the Flash Player enough memory in order to save your game. Right click the game, go to "Settings", click the Folder icon, and allow unlimited save space.');
            };
        }

        public static function eraseGame():void
        {
            var saveFile:File;
            saveFile = File.applicationStorageDirectory.resolvePath(m_currentSaveFileName);
            try
            {
                if (saveFile.exists)
                {
                    saveFile.deleteFile();
                };
            }
            catch(e)
            {
                trace("Problem deleting data...");
            };
            initializeSaveData(false);
            SoundQueue.instance.updateVolumeLevel();
            Main.setFullScreenMode(SaveData.Quality.fullscreen_quality);
            Main.Root.stage.quality = SaveData.Quality.display_quality;
        }

        public static function saveGame():void
        {
            var saveFile:File;
            var bArr:ByteArray;
            var fileWriter:FileStream;
            var timeDiff:int = int((((new Date().getTime() - _lastPowerCheck.getTime()) / 1000) * Main.FRAMERATE));
            _lastPowerCheck = new Date();
            SaveData.PowerTime = (SaveData.PowerTime + timeDiff);
            var savedata:String = JSON.stringify(m_localObject);
            saveFile = File.applicationStorageDirectory.resolvePath(m_currentSaveFileName);
            try
            {
                bArr = new ByteArray();
                bArr.writeUTFBytes(Base64.encode(JSON.stringify(m_localObject)));
                bArr.compress();
                fileWriter = new FileStream();
                fileWriter.open(saveFile, FileMode.WRITE);
                fileWriter.writeBytes(bArr);
                fileWriter.close();
            }
            catch(e)
            {
                trace("Problem saving data...");
            };
            trace("Save Data Updated");
        }

        private static function importSaveFile(file:String):Boolean
        {
            var saveFile:File;
            var bArr:ByteArray;
            var fileReader:FileStream;
            saveFile = File.applicationStorageDirectory.resolvePath(file);
            if (saveFile.exists)
            {
                try
                {
                    bArr = new ByteArray();
                    fileReader = new FileStream();
                    fileReader.open(saveFile, FileMode.READ);
                    fileReader.readBytes(bArr);
                    fileReader.close();
                    bArr.uncompress();
                    try
                    {
                        m_localObject = JSON.parse(Base64.decode(bArr.readUTFBytes(bArr.length)));
                        return (true);
                    }
                    catch(e)
                    {
                        bArr.position = 0;
                        m_localObject = JSON.parse(Base64.decode(bArr.readUTF()));
                        return (true);
                    };
                }
                catch(e)
                {
                    m_localObject = {};
                    SaveData.corrupted = true;
                };
            };
            return (false);
        }

        public static function loadGame(upgradeOldData:Boolean=true):void
        {
            var saveFile:File;
            var i:int;
            saveFile = File.applicationStorageDirectory.resolvePath(m_currentSaveFileName);
            if ((!(saveFile.exists)))
            {
                i = (SaveData.m_previousSaveFileNames.length - 1);
                while ((((i >= 0) && (!(SaveData.corrupted))) && (upgradeOldData)))
                {
                    if (importSaveFile(SaveData.m_previousSaveFileNames[i]))
                    {
                        return;
                    };
                    i--;
                };
                m_localObject = {};
            }
            else
            {
                importSaveFile(m_currentSaveFileName);
            };
        }

        public static function getExistingOldSaveFileNames():Vector.<String>
        {
            var file:String;
            var results:Vector.<String> = new Vector.<String>();
            var i:int;
            while (i < SaveData.m_previousSaveFileNames.length)
            {
                file = SaveData.m_previousSaveFileNames[i];
                if (File.applicationStorageDirectory.resolvePath(file).exists)
                {
                    results.push(file);
                };
                i++;
            };
            return (results);
        }

        public static function getSavedVSOptions():Object
        {
            return (m_localObject.game.options);
        }

        public static function setSavedVSOptions(game:Game):void
        {
            var i:*;
            m_localObject.game.options.teamDamage = game.LevelData.teamDamage;
            m_localObject.game.options.VS_Time = game.LevelData.time;
            m_localObject.game.options.VS_DamageRatio = game.LevelData.damageRatio;
            m_localObject.game.options.VS_FinalSmashMeter = game.LevelData.finalSmashMeter;
            m_localObject.game.options.VS_ScoreDisplay = game.LevelData.scoreDisplay;
            m_localObject.game.options.VS_HudDisplay = game.LevelData.hudDisplay;
            m_localObject.game.options.VS_PauseEnabled = game.LevelData.pauseEnabled;
            m_localObject.game.options.VS_DisplayPlayer = game.LevelData.showPlayerID;
            m_localObject.game.options.VS_Lives = game.LevelData.lives;
            m_localObject.game.options.VS_StartDamage = game.LevelData.startDamage;
            m_localObject.game.options.VS_ItemFreq = game.Items.frequency;
            m_localObject.game.options.VS_UsingLives = game.LevelData.usingLives;
            m_localObject.game.options.VS_UsingTime = game.LevelData.usingTime;
            m_localObject.game.options.VS_StartStamina = game.LevelData.startStamina;
            m_localObject.game.options.VS_UsingStamina = game.LevelData.usingStamina;
            m_localObject.game.options.arenaScore = game.LevelData.scoreLimit;
            var p:int;
            while (p < game.PlayerSettings.length)
            {
                m_localObject.game.options[("VS_CPULevel" + (p + 1))] = game.PlayerSettings[p].level;
                p++;
            };
            m_localObject.game.options.VS_Items = {};
            for (i in game.Items.items)
            {
                if (game.Items.items[i] === false)
                {
                    m_localObject.game.options.VS_Items[i] = game.Items.items[i];
                };
            };
        }

        public static function get RawLocalObject():Object
        {
            return (m_localObject);
        }

        public static function get UsingTime():Boolean
        {
            return (m_localObject.game.options.VS_UsingTime);
        }

        public static function get UsingLives():Boolean
        {
            return (m_localObject.game.options.VS_UsingLives);
        }

        public static function get UsingStamina():Boolean
        {
            return (m_localObject.game.options.VS_UsingStamina);
        }

        public static function get ShowPlayerID():Boolean
        {
            return (m_localObject.game.options.VS_DisplayPlayer);
        }

        public static function get DamageRatio():Number
        {
            return (m_localObject.game.options.VS_DamageRatio);
        }

        public static function get StartDamage():Number
        {
            return (m_localObject.game.options.VS_StartDamage);
        }

        public static function get StartStamina():Number
        {
            return (m_localObject.game.options.VS_StartStamina);
        }

        public static function get Time():Number
        {
            return (m_localObject.game.options.VS_Time as Number);
        }

        public static function get Lives():Number
        {
            return (m_localObject.game.options.VS_Lives);
        }

        public static function get ItemDataObj():Object
        {
            return (m_localObject.game.options.VS_Items);
        }

        public static function set ItemDataObj(value:Object):void
        {
            m_localObject.game.options.VS_Items = value;
        }

        public static function get VSStageDataObj():Object
        {
            return (m_localObject.game.options.VS_Stages);
        }

        public static function get ItemFrequency():Number
        {
            return (m_localObject.game.options.VS_ItemFreq);
        }

        public static function toggleTime(inc:Boolean):void
        {
            m_localObject.game.options.VS_Time = ((inc) ? (m_localObject.game.options.VS_Time + 1) : (m_localObject.game.options.VS_Time - 1));
            if (m_localObject.game.options.VS_Time <= 0)
            {
                m_localObject.game.options.VS_Time = 99;
            }
            else
            {
                if (m_localObject.game.options.VS_Time > 99)
                {
                    m_localObject.game.options.VS_Time = 1;
                };
            };
        }

        public static function toggleStock(inc:Boolean):void
        {
            m_localObject.game.options.VS_Lives = ((inc) ? (m_localObject.game.options.VS_Lives + 1) : (m_localObject.game.options.VS_Lives - 1));
            if (m_localObject.game.options.VS_Lives <= 0)
            {
                m_localObject.game.options.VS_Lives = 99;
            }
            else
            {
                if (m_localObject.game.options.VS_Lives > 99)
                {
                    m_localObject.game.options.VS_Lives = 1;
                };
            };
        }

        public static function toggleDamageRatio(inc:Boolean):void
        {
            m_localObject.game.options.VS_DamageRatio = ((inc) ? (m_localObject.game.options.VS_DamageRatio + 0.1) : (m_localObject.game.options.VS_DamageRatio - 0.1));
            if (m_localObject.game.options.VS_DamageRatio > 2)
            {
                m_localObject.game.options.VS_DamageRatio = 2;
            }
            else
            {
                if (m_localObject.game.options.VS_DamageRatio < 0.5)
                {
                    m_localObject.game.options.VS_DamageRatio = 0.5;
                };
            };
            m_localObject.game.options.VS_DamageRatio = (Math.round((m_localObject.game.options.VS_DamageRatio * 10)) / 10);
        }

        public static function toggleItemFrequency(inc:Boolean):void
        {
            m_localObject.game.options.VS_ItemFreq = ((inc) ? (m_localObject.game.options.VS_ItemFreq + 1) : (m_localObject.game.options.VS_ItemFreq - 1));
            if (m_localObject.game.options.VS_ItemFreq > 5)
            {
                m_localObject.game.options.VS_ItemFreq = 5;
            }
            else
            {
                if (m_localObject.game.options.VS_ItemFreq < 0)
                {
                    m_localObject.game.options.VS_ItemFreq = 0;
                };
            };
        }

        public static function setStartDamage(num:Number):void
        {
            m_localObject.game.options.VS_StartDamage = num;
            if (m_localObject.game.options.VS_StartDamage > 999)
            {
                m_localObject.game.options.VS_StartDamage = 0;
            }
            else
            {
                if (m_localObject.game.options.VS_StartDamage < 0)
                {
                    m_localObject.game.options.VS_StartDamage = 999;
                };
            };
        }

        public static function setStartStamina(num:Number):void
        {
            m_localObject.game.options.VS_StartStamina = num;
            if (m_localObject.game.options.VS_StartStamina > 999)
            {
                m_localObject.game.options.VS_StartStamina = 1;
            }
            else
            {
                if (m_localObject.game.options.VS_StartStamina < 1)
                {
                    m_localObject.game.options.VS_StartStamina = 999;
                };
            };
        }

        public static function toggleUsingTime():void
        {
            m_localObject.game.options.VS_UsingTime = (!(m_localObject.game.options.VS_UsingTime));
            if (((!(m_localObject.game.options.VS_UsingLives)) && (!(m_localObject.game.options.VS_UsingTime))))
            {
                m_localObject.game.options.VS_UsingLives = true;
            };
        }

        public static function toggleUsingLives():void
        {
            m_localObject.game.options.VS_UsingLives = (!(m_localObject.game.options.VS_UsingLives));
            if (((!(m_localObject.game.options.VS_UsingTime)) && (!(m_localObject.game.options.VS_UsingLives))))
            {
                m_localObject.game.options.VS_UsingTime = true;
            };
        }

        public static function toggleUsingStamina():void
        {
            m_localObject.game.options.VS_UsingStamina = (!(SaveData.UsingStamina));
        }

        public static function toggleShowPlayerID():void
        {
            m_localObject.game.options.VS_DisplayPlayer = (!(m_localObject.game.options.VS_DisplayPlayer));
        }

        public static function toggleHazards():void
        {
            m_localObject.game.options.hazards = (!(m_localObject.game.options.hazards));
        }

        public static function toggleTeamDamage():void
        {
            m_localObject.game.options.teamDamage = (!(m_localObject.game.options.teamDamage));
        }

        public static function exportSaveData(dataSettings:DataSettings=null):void
        {
            var saveFile:File;
            var tempBArr:ByteArray;
            var fileReader:FileStream;
            var settings:DataSettings = ((dataSettings) ? dataSettings : new DataSettings());
            var data:Object;
            if (dataSettings.saveFileVersion)
            {
                saveFile = File.applicationStorageDirectory.resolvePath(dataSettings.saveFileVersion);
                if ((!(saveFile.exists)))
                {
                    return;
                };
                try
                {
                    tempBArr = new ByteArray();
                    fileReader = new FileStream();
                    fileReader.open(saveFile, FileMode.READ);
                    fileReader.readBytes(tempBArr);
                    fileReader.close();
                    tempBArr.uncompress();
                    try
                    {
                        data = JSON.parse(Base64.decode(tempBArr.readUTFBytes(tempBArr.length)));
                    }
                    catch(e)
                    {
                        tempBArr.position = 0;
                        data = JSON.parse(Base64.decode(tempBArr.readUTF()));
                    };
                }
                catch(e)
                {
                    return;
                };
            }
            else
            {
                data = Utils.cloneObject(m_localObject);
            };
            if ((!(settings.records)))
            {
                delete data.game.records;
            };
            if ((!(settings.options)))
            {
                delete data.game.options;
                delete data.game.quality;
            };
            if ((!(settings.unlocks)))
            {
                delete data.game.unlocks;
            };
            if ((!(settings.controls)))
            {
                delete data.game.gamepads;
                delete data.game.portInputs;
                delete data.game.controlSettings;
            };
            var str:String = "";
            str = JSON.stringify(data);
            var bArr:ByteArray = new ByteArray();
            bArr.writeUTFBytes(str);
            bArr.compress();
            Utils.saveFile(bArr, "New SSF2 Save.ssfsav");
        }

        public static function importSaveData(dataStr:String, dataSettings:DataSettings=null):Boolean
        {
            var data:Object;
            var k:* = undefined;
            var playerNumSplit:Array;
            var pid:int;
            var settings:DataSettings = ((dataSettings) ? dataSettings : new DataSettings());
            var success:Boolean = true;
            try
            {
                data = JSON.parse(dataStr);
                if (((!(data.game)) || (!(data.game.migration))))
                {
                    return (false);
                };
                data.game = SaveDataMigrations.migrate(data.game);
            }
            catch(e)
            {
                return (false);
            };
            if (settings.records)
            {
                if (data.game.records)
                {
                    m_localObject.game.records = data.game.records;
                    trace(("Imported records: " + JSON.stringify(data.game.records)));
                };
            };
            if (settings.options)
            {
                if (data.game.options)
                {
                    m_localObject.game.options = data.game.options;
                    trace(("Imported options: " + JSON.stringify(data.game.options)));
                };
                if (data.game.quality)
                {
                    m_localObject.game.quality = data.game.quality;
                    trace(("Imported quality settings: " + JSON.stringify(data.game.quality)));
                };
            };
            if (settings.unlocks)
            {
                if (data.game.unlocks)
                {
                    m_localObject.game.unlocks = data.game.unlocks;
                    trace(("Imported unlocks: " + JSON.stringify(data.game.unlocks)));
                };
            };
            if (settings.controls)
            {
                if (data.game.gamepads)
                {
                    m_localObject.game.gamepads = data.game.gamepads;
                    trace(("Imported gamepads: " + JSON.stringify(data.game.gamepads)));
                };
                if (data.game.portInputs)
                {
                    m_localObject.game.portInputs = data.game.portInputs;
                    trace(("Imported port inputs: " + JSON.stringify(data.game.portInputs)));
                };
                if (data.game.controlSettings)
                {
                    m_localObject.game.controlSettings = data.game.controlSettings;
                    for (k in m_localObject.game.controlSettings)
                    {
                        playerNumSplit = k.split("player");
                        if (((playerNumSplit.length === 2) && (!(isNaN(parseInt(playerNumSplit[1]))))))
                        {
                            pid = parseInt(playerNumSplit[1]);
                            if (pid <= SaveData.Controllers.length)
                            {
                                SaveData.Controllers[(pid - 1)].setControls(m_localObject.game.controlSettings[k]);
                            };
                        };
                    };
                    trace(("Imported control settings: " + JSON.stringify(data.game.controlSettings)));
                };
            };
            SoundQueue.instance.updateVolumeLevel();
            Main.setFullScreenMode(SaveData.Quality.fullscreen_quality);
            Main.Root.stage.quality = SaveData.Quality.display_quality;
            SaveData.saveGame();
            return (success);
        }

        public static function getItemStatus(itemName:String):Boolean
        {
            var arr:Array = itemName.split("|");
            return (!(m_localObject.game.options.VS_Items[arr[0]] === false));
        }

        public static function getStageStatus(stageName:String):Boolean
        {
            return (!(m_localObject.game.options.VS_Stages[stageName] === false));
        }

        public static function getNameSettings(name:String):Object
        {
            var i:*;
            var obj:Object = Names;
            if ((!(obj)))
            {
                return (null);
            };
            for (i in obj)
            {
                if (obj[i].name == Base64.encode(name))
                {
                    return (obj[i]);
                };
            };
            return (null);
        }

        public static function createNameSettings(name:String):void
        {
            if (getNameSettings(name))
            {
                return;
            };
            Names[Base64.encode(name)] = {};
            Names[Base64.encode(name)].name = Base64.encode(name);
            Names[Base64.encode(name)].controls = {};
            Names[Base64.encode(name)].randCharacters = {};
        }

        public static function deleteNameSettings(name:String):void
        {
            var i:*;
            var obj:Object = Names;
            if ((!(obj)))
            {
                return;
            };
            for (i in obj)
            {
                if (obj[i].name == Base64.decode(name))
                {
                    obj[i] = null;
                    delete obj[i];
                    return;
                };
            };
        }

        public static function reimportNamedPlayerControls(pid:int, name:String):void
        {
            var previousControls:Object = SaveData.Gamepads[SaveData.Controllers[(pid - 1)].GamepadInstance.Name].ports[("port" + SaveData.Controllers[(pid - 1)].GamepadInstance.Port)];
            var nameControls:Object = SaveData.Gamepads[SaveData.Controllers[(pid - 1)].GamepadInstance.Name].names[name];
            if (((!(nameControls)) && (previousControls)))
            {
                nameControls = Utils.cloneObject(previousControls);
                SaveData.Gamepads[SaveData.Controllers[(pid - 1)].GamepadInstance.Name].names[name] = nameControls;
            }
            else
            {
                if ((!(nameControls)))
                {
                    nameControls = (SaveData.Gamepads[SaveData.Controllers[(pid - 1)].GamepadInstance.Name].names[name] = {});
                };
            };
            SaveData.Controllers[(pid - 1)]._TAP_JUMP = nameControls.TAP_JUMP;
            SaveData.Controllers[(pid - 1)]._AUTO_DASH = nameControls.AUTO_DASH;
            SaveData.Controllers[(pid - 1)]._DT_DASH = nameControls.DT_DASH;
            SaveData.Controllers[(pid - 1)].GamepadInstance.importControls(nameControls);
        }

        public static function reimportSlottedPlayerControls(pid:int):void
        {
            var portControls:Object = SaveData.Gamepads[SaveData.Controllers[(pid - 1)].GamepadInstance.Name].ports[("port" + SaveData.Controllers[(pid - 1)].GamepadInstance.Port)];
            if (SaveData.Controllers[(pid - 1)].GamepadInstance)
            {
                SaveData.Controllers[(pid - 1)].GamepadInstance.importControls(portControls);
            }
            else
            {
                SaveData.Controllers[(pid - 1)].setControls(SaveData.ControlSettings[("player" + pid)]);
            };
            SaveData.Controllers[(pid - 1)]._TAP_JUMP = SaveData.ControlSettings[("player" + pid)].TAP_JUMP;
            SaveData.Controllers[(pid - 1)]._AUTO_DASH = SaveData.ControlSettings[("player" + pid)].AUTO_DASH;
            SaveData.Controllers[(pid - 1)]._DT_DASH = SaveData.ControlSettings[("player" + pid)].DT_DASH;
        }

        public static function getTargetTestData(levelID:String, characterID:String):Object
        {
            if (((levelID == null) || (characterID == null)))
            {
                return (null);
            };
            if (characterID === "sheik")
            {
                characterID = "zelda";
            };
            if (((Records.targets.wins[levelID]) && (Records.targets.wins[levelID][characterID])))
            {
                return (Utils.cloneObject(Records.targets.wins[levelID][characterID]));
            };
            return (null);
        }

        public static function setTargetTestData(levelID:String, characterID:String, data:Object):void
        {
            if (characterID === "sheik")
            {
                characterID = "zelda";
            };
            if ((!(Records.targets.wins[levelID])))
            {
                Records.targets.wins[levelID] = {};
            };
            Records.targets.wins[levelID][characterID] = data;
        }

        public static function getCrystalSmashData(levelID:String, characterID:String):Object
        {
            if (((levelID == null) || (characterID == null)))
            {
                return (null);
            };
            if (characterID === "sheik")
            {
                characterID = "zelda";
            };
            if (((Records.crystals.wins[levelID]) && (Records.crystals.wins[levelID][characterID])))
            {
                return (Utils.cloneObject(Records.crystals.wins[levelID][characterID]));
            };
            return (null);
        }

        public static function setCrystalSmashData(levelID:String, characterID:String, data:Object):void
        {
            if (characterID === "sheik")
            {
                characterID = "zelda";
            };
            if ((!(Records.crystals.wins[levelID])))
            {
                Records.crystals.wins[levelID] = {};
            };
            Records.crystals.wins[levelID][characterID] = data;
        }

        public static function getClassicModeData(characterID:String):Object
        {
            if (characterID == null)
            {
                return (null);
            };
            if (characterID === "sheik")
            {
                characterID = "zelda";
            };
            if (Records.classic.wins[characterID])
            {
                return (Utils.cloneObject(Records.classic.wins[characterID]));
            };
            return (null);
        }

        public static function setClassicModeData(characterID:String, data:Object):void
        {
            if (characterID === "sheik")
            {
                characterID = "zelda";
            };
            Records.classic.wins[characterID] = data;
        }

        public static function getAllStarModeData(characterID:String):Object
        {
            if (characterID == null)
            {
                return (null);
            };
            if (characterID === "sheik")
            {
                characterID = "zelda";
            };
            if (Records.allstar.wins[characterID])
            {
                return (Utils.cloneObject(Records.allstar.wins[characterID]));
            };
            return (null);
        }

        public static function setAllStarModeData(characterID:String, data:Object):void
        {
            if (characterID === "sheik")
            {
                characterID = "zelda";
            };
            Records.allstar.wins[characterID] = data;
        }

        public static function getMultiManModeData(modeID:String, characterID:String):Object
        {
            if (characterID == null)
            {
                return (null);
            };
            if (characterID === "sheik")
            {
                characterID = "zelda";
            };
            if (((Records.multiman.modes[modeID]) && (Records.multiman.modes[modeID][characterID])))
            {
                return (Utils.cloneObject(Records.multiman.modes[modeID][characterID]));
            };
            return (null);
        }

        public static function setMultiManModeData(modeID:String, characterID:String, data:Object):void
        {
            if (characterID === "sheik")
            {
                characterID = "zelda";
            };
            if ((!(Records.multiman.modes[modeID])))
            {
                Records.multiman.modes[modeID] = {};
            };
            Records.multiman.modes[modeID][characterID] = data;
        }

        public static function getHRCModeData(stageID:String, characterID:String):Object
        {
            if (((characterID == null) || (stageID == null)))
            {
                return (null);
            };
            if (characterID === "sheik")
            {
                characterID = "zelda";
            };
            if (((Records.hrc.wins[stageID]) && (Records.hrc.wins[stageID][characterID])))
            {
                return (Utils.cloneObject(Records.hrc.wins[stageID][characterID]));
            };
            return (null);
        }

        public static function setHRCModeData(stageID:String, characterID:String, data:Object):void
        {
            if (characterID === "sheik")
            {
                characterID = "zelda";
            };
            if ((!(Records.hrc.wins[stageID])))
            {
                Records.hrc.wins[stageID] = {};
            };
            Records.hrc.wins[stageID][characterID] = data;
        }

        public static function setP2PSettings(udpIP:String, udpPort:int, tcpIP:String, tcpPort:int):void
        {
            m_localObject.game.options.udpIP = udpIP;
            m_localObject.game.options.udpPort = udpPort;
            m_localObject.game.options.tcpIP = tcpIP;
            m_localObject.game.options.tcpPort = tcpPort;
            ProtocolSetting.udpPort = udpPort;
            ProtocolSetting.udpIP = udpIP;
            ProtocolSetting.tcpPort = tcpPort;
            ProtocolSetting.tcpIP = tcpIP;
        }

        public static function getP2PSettings():Object
        {
            return ({
                "udpIP":m_localObject.game.options.udpIP,
                "udpPort":m_localObject.game.options.udpPort,
                "tcpIP":m_localObject.game.options.tcpIP,
                "tcpPort":m_localObject.game.options.tcpPort
            });
        }

        public static function get FinalFormMusic():Boolean
        {
            return (m_localObject.game.options.finalFormMusic as Boolean);
        }

        public static function set FinalFormMusic(value:Boolean):void
        {
            m_localObject.game.options.finalFormMusic = value;
        }

        public static function get ControlSettings():Object
        {
            return (m_localObject.game.controlSettings);
        }

        public static function set ControlSettings(value:Object):void
        {
            m_localObject.game.controlSettings = value;
        }

        public static function get Hazards():Boolean
        {
            return (m_localObject.game.options.hazards as Boolean);
        }

        public static function set Hazards(value:Boolean):void
        {
            m_localObject.game.options.hazards = value;
        }

        public static function get ReplayAutoSave():Boolean
        {
            return (m_localObject.game.options.replayAutoSave as Boolean);
        }

        public static function set ReplayAutoSave(value:Boolean):void
        {
            m_localObject.game.options.replayAutoSave = value;
        }

        public static function get TeamDamage():Boolean
        {
            return (m_localObject.game.options.teamDamage as Boolean);
        }

        public static function set TeamDamage(value:Boolean):void
        {
            m_localObject.game.options.teamDamage = value;
        }

        public static function get FinalSmashMeter():Boolean
        {
            return (m_localObject.game.options.VS_FinalSmashMeter as Boolean);
        }

        public static function set FinalSmashMeter(value:Boolean):void
        {
            m_localObject.game.options.VS_FinalSmashMeter = value;
        }

        public static function get ScoreDisplay():Boolean
        {
            return (m_localObject.game.options.VS_ScoreDisplay as Boolean);
        }

        public static function set ScoreDisplay(value:Boolean):void
        {
            m_localObject.game.options.VS_ScoreDisplay = value;
        }

        public static function get HudDisplay():Boolean
        {
            return (m_localObject.game.options.VS_HudDisplay as Boolean);
        }

        public static function set HudDisplay(value:Boolean):void
        {
            m_localObject.game.options.VS_HudDisplay = value;
        }

        public static function get PauseEnabled():Boolean
        {
            return (m_localObject.game.options.VS_PauseEnabled as Boolean);
        }

        public static function set PauseEnabled(value:Boolean):void
        {
            m_localObject.game.options.VS_PauseEnabled = value;
        }

        public static function get SEVolumeLevel():Number
        {
            return (m_localObject.game.options.SEvolumeLevel as Number);
        }

        public static function set SEVolumeLevel(value:Number):void
        {
            m_localObject.game.options.SEvolumeLevel = value;
        }

        public static function get VAVolumeLevel():Number
        {
            return (m_localObject.game.options.VAvolumeLevel as Number);
        }

        public static function set VAVolumeLevel(value:Number):void
        {
            m_localObject.game.options.VAvolumeLevel = value;
        }

        public static function get BGVolumeLevel():Number
        {
            return (m_localObject.game.options.BGvolumeLevel as Number);
        }

        public static function set BGVolumeLevel(value:Number):void
        {
            m_localObject.game.options.BGvolumeLevel = value;
        }

        public static function get PowerCount():Number
        {
            return (m_localObject.game.records.misc.powerCount as Number);
        }

        public static function set PowerCount(value:Number):void
        {
            m_localObject.game.records.misc.powerCount = value;
        }

        public static function get PowerTime():Number
        {
            return (m_localObject.game.records.misc.powerTime as Number);
        }

        public static function set PowerTime(value:Number):void
        {
            m_localObject.game.records.misc.powerTime = value;
        }

        public static function get PlayTime():Number
        {
            return (m_localObject.game.records.misc.playTime as Number);
        }

        public static function set PlayTime(value:Number):void
        {
            m_localObject.game.records.misc.playTime = value;
        }

        public static function get VSPlayTime():Number
        {
            return (m_localObject.game.records.vs.playTime as Number);
        }

        public static function set VSPlayTime(value:Number):void
        {
            m_localObject.game.records.vs.playTime = value;
        }

        public static function get TimeMatchTotal():Number
        {
            return (m_localObject.game.records.vs.timeMatchTotal as Number);
        }

        public static function set TimeMatchTotal(value:Number):void
        {
            m_localObject.game.records.vs.timeMatchTotal = value;
        }

        public static function get StockMatchTotal():Number
        {
            return (m_localObject.game.records.vs.stockMatchTotal as Number);
        }

        public static function set StockMatchTotal(value:Number):void
        {
            m_localObject.game.records.vs.stockMatchTotal = value;
        }

        public static function get VSCPULevel1():Number
        {
            return (m_localObject.game.options.VS_CPULevel1 as Number);
        }

        public static function get VSCPULevel2():Number
        {
            return (m_localObject.game.options.VS_CPULevel2 as Number);
        }

        public static function get VSCPULevel3():Number
        {
            return (m_localObject.game.options.VS_CPULevel3 as Number);
        }

        public static function get VSCPULevel4():Number
        {
            return (m_localObject.game.options.VS_CPULevel4 as Number);
        }

        public static function set VSCPULevel1(value:Number):void
        {
            m_localObject.game.options.VS_CPULevel1 = value;
        }

        public static function set VSCPULevel2(value:Number):void
        {
            m_localObject.game.options.VS_CPULevel2 = value;
        }

        public static function set VSCPULevel3(value:Number):void
        {
            m_localObject.game.options.VS_CPULevel3 = value;
        }

        public static function set VSCPULevel4(value:Number):void
        {
            m_localObject.game.options.VS_CPULevel4 = value;
        }

        public static function get MatchResets():Number
        {
            return (m_localObject.game.records.misc.matchResets as Number);
        }

        public static function set MatchResets(value:Number):void
        {
            m_localObject.game.records.misc.matchResets = value;
        }

        public static function get RememberMe():String
        {
            return ((m_localObject.game.options.rememberMe) ? (m_localObject.game.options.rememberMe as String) : null);
        }

        public static function set RememberMe(value:String):void
        {
            m_localObject.game.options.rememberMe = value;
        }

        public static function get Quality():Object
        {
            return (m_localObject.game.quality);
        }

        public static function get Names():Object
        {
            return (m_localObject.game.options.names as Object);
        }

        public static function get AirDodge():String
        {
            return (m_localObject.game.options.airDodge as String);
        }

        public static function set AirDodge(value:String):void
        {
            m_localObject.game.options.airDodge = value;
        }

        public static function get Records():Object
        {
            return (m_localObject.game.records);
        }

        public static function get Unlocks():Object
        {
            return (m_localObject.game.unlocks as Object);
        }

        public static function get Gamepads():Object
        {
            return (m_localObject.game.gamepads as Object);
        }

        public static function get PortInputs():Object
        {
            return (m_localObject.game.portInputs as Object);
        }

        public static function getGamepadInputData(gamepadName:String, port:int, portName:String, input:String):Object
        {
            SaveData.Gamepads[gamepadName] = ((SaveData.Gamepads[gamepadName]) || ({
                "names":{},
                "ports":{}
            }));
            SaveData.Gamepads[gamepadName][((port > 0) ? "ports" : "names")][portName] = ((SaveData.Gamepads[gamepadName][((port > 0) ? "ports" : "names")][portName]) || ({}));
            SaveData.Gamepads[gamepadName][((port > 0) ? "ports" : "names")][portName][input] = ((SaveData.Gamepads[gamepadName][((port > 0) ? "ports" : "names")][portName][input]) || ({
                "inputs":[],
                "inputsInverse":[],
                "deadZone":Gamepad.DEADZONE_DEFAULT,
                "dashZone":Gamepad.DASHZONE_DEFAULT
            }));
            return (SaveData.Gamepads[gamepadName][((port > 0) ? "ports" : "names")][portName][input]);
        }

        public static function get Once():Object
        {
            return (m_localObject.game.once);
        }


    }
}//package com.mcleodgaming.ssf2.util


// Decompiled by AS3 Sorcerer 6.30
// www.as3sorcerer.com

//com.mcleodgaming.ssf2.modes.ClassicMode

package com.mcleodgaming.ssf2.modes
{
    import com.mcleodgaming.ssf2.controllers.Game;
    import com.mcleodgaming.ssf2.util.SaveData;
    import com.mcleodgaming.ssf2.enums.Difficulty;
    import com.mcleodgaming.ssf2.controllers.UnlockController;
    import com.mcleodgaming.ssf2.controllers.Unlockable;
    import com.mcleodgaming.ssf2.controllers.*;
    import com.mcleodgaming.ssf2.enums.*;
    import com.mcleodgaming.ssf2.util.*;

    public class ClassicMode extends CustomMode 
    {

        public function ClassicMode(game:Game, modeSettings:Object, stats:Object=null, stub:Boolean=false)
        {
            super(game, modeSettings, stats, stub);
        }

        override public function saveModeData(data:Object):Boolean
        {
            var i:int;
            var id:String;
            var score:int;
            var modeStub:CustomMode;
            if (GameInstance.ReplayDataObj)
            {
                return (false);
            };
            var wasRecord:Boolean;
            var oldRecord:Object;
            if (data)
            {
                if (data.type === "targetTest")
                {
                    modeStub = new TargetTestMode(m_initialGameSettings, m_modeSettings, m_stats, true);
                    wasRecord = modeStub.saveModeData(data);
                    modeStub.APIInstance.dispose();
                    return (wasRecord);
                };
                if (data.type === "crystalSmash")
                {
                    modeStub = new CrystalSmashMode(m_initialGameSettings, m_modeSettings, m_stats, true);
                    wasRecord = modeStub.saveModeData(data);
                    modeStub.APIInstance.dispose();
                    return (wasRecord);
                };
                if (data.type !== "classicMode")
                {
                    throw (new Error("Error, expected type to equal 'classicMode'"));
                };
                if ((!(data.matchData)))
                {
                    throw (new Error("Error, matchData was not provided to saveModeData() for classic mode"));
                };
                if (typeof(data.matchData.score) === "undefined")
                {
                    throw (new Error("Error, classic mode was missing score value"));
                };
                if (typeof(data.matchData.continues) === "undefined")
                {
                    throw (new Error("Error, classic mode was missing continues value"));
                };
                score = data.matchData.score;
                oldRecord = SaveData.getClassicModeData(m_initialGameSettings.PlayerSettings[0].character);
                if (((!(oldRecord)) || (score > oldRecord.score)))
                {
                    wasRecord = true;
                    SaveData.setClassicModeData(m_initialGameSettings.PlayerSettings[0].character, {"score":score});
                };
                if ((((m_initialGameSettings.PlayerSettings[0].character === "goku") && (m_initialGameSettings.LevelData.difficulty >= Difficulty.HARD)) && (data.matchData.continues === 0)))
                {
                    UnlockController.getUnlockableByID(Unlockable.WORLD_TOURNAMENT).TriggerUnlock = true;
                };
                if ((((m_initialGameSettings.PlayerSettings[0].character.match(/link|zelda|sheik/)) && (m_initialGameSettings.LevelData.difficulty >= Difficulty.NORMAL)) && (data.matchData.continues === 0)))
                {
                    SaveData.Unlocks.zeldaHyrule64Condition = true;
                    SaveData.Unlocks.linkHyrule64Condition = true;
                };
                if (((m_initialGameSettings.LevelData.difficulty >= Difficulty.HARD) && (data.matchData.continues === 0)))
                {
                    UnlockController.getUnlockableByID(Unlockable.METAL_CAVERN).TriggerUnlock = true;
                };
                if (SaveData.Unlocks.mk64Condition)
                {
                    UnlockController.getUnlockableByID(Unlockable.MUSHROOM_KINGDOM_64).TriggerUnlock = true;
                };
                if (score >= 550000)
                {
                    UnlockController.getUnlockableByID(Unlockable.URBAN_CHAMPION).TriggerUnlock = true;
                };
            };
            SaveData.saveGame();
            return (wasRecord);
        }


    }
}//package com.mcleodgaming.ssf2.modes


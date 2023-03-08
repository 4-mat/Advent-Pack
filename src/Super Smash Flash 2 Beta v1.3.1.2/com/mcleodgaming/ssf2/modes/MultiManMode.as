// Decompiled by AS3 Sorcerer 6.30
// www.as3sorcerer.com

//com.mcleodgaming.ssf2.modes.MultiManMode

package com.mcleodgaming.ssf2.modes
{
    import com.mcleodgaming.ssf2.controllers.Game;
    import com.mcleodgaming.ssf2.util.SaveData;
    import com.mcleodgaming.ssf2.menus.MultiManMenu;
    import com.mcleodgaming.ssf2.controllers.*;
    import com.mcleodgaming.ssf2.enums.*;
    import com.mcleodgaming.ssf2.util.*;

    public class MultiManMode extends CustomMode 
    {

        public function MultiManMode(game:Game, modeSettings:Object, stats:Object=null, stub:Boolean=false)
        {
            super(game, modeSettings, stats, stub);
        }

        override public function saveModeData(data:Object):Boolean
        {
            var i:int;
            var id:String;
            var score:int;
            var scoreType:String;
            if (GameInstance.ReplayDataObj)
            {
                return (false);
            };
            var wasRecord:Boolean;
            var oldRecord:Object;
            if (data)
            {
                if (data.type !== "multiman")
                {
                    throw (new Error("Error, expected type to equal 'multiman'"));
                };
                if ((!(data.matchData)))
                {
                    throw (new Error("Error, matchData was not provided to saveModeData() for multi-man mode"));
                };
                if (typeof(data.matchData.score) === "undefined")
                {
                    throw (new Error("Error, multi-man mode was missing score value"));
                };
                if (typeof(data.matchData.scoreType) === "undefined")
                {
                    throw (new Error("Error, multi-man match was missing scoreType value"));
                };
                if ((!(data.matchData.scoreType.match(/^(time|kos)$/))))
                {
                    throw (new Error("Error, multi-man match scoreType value must be 'time' or 'kos'"));
                };
                score = data.matchData.score;
                scoreType = data.matchData.scoreType;
                oldRecord = SaveData.getMultiManModeData(MultiManMenu.SELECTED_MULTI_MAN_MODE, m_initialGameSettings.PlayerSettings[0].character);
                if ((!(oldRecord)))
                {
                    wasRecord = true;
                    SaveData.setMultiManModeData(MultiManMenu.SELECTED_MULTI_MAN_MODE, m_initialGameSettings.PlayerSettings[0].character, {
                        "score":score,
                        "scoreType":scoreType
                    });
                }
                else
                {
                    if (scoreType === "kos")
                    {
                        if (((!(oldRecord.scoreType === "time")) && (score > oldRecord.score)))
                        {
                            wasRecord = true;
                            SaveData.setMultiManModeData(MultiManMenu.SELECTED_MULTI_MAN_MODE, m_initialGameSettings.PlayerSettings[0].character, {
                                "score":score,
                                "scoreType":scoreType
                            });
                        };
                    }
                    else
                    {
                        if (scoreType === "time")
                        {
                            if (((oldRecord.scoreType === "kos") || (score < oldRecord.score)))
                            {
                                wasRecord = true;
                                SaveData.setMultiManModeData(MultiManMenu.SELECTED_MULTI_MAN_MODE, m_initialGameSettings.PlayerSettings[0].character, {
                                    "score":score,
                                    "scoreType":scoreType
                                });
                            };
                        };
                    };
                };
            };
            SaveData.saveGame();
            return (wasRecord);
        }


    }
}//package com.mcleodgaming.ssf2.modes


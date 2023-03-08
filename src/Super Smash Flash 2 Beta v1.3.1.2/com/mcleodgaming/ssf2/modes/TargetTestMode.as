// Decompiled by AS3 Sorcerer 6.30
// www.as3sorcerer.com

//com.mcleodgaming.ssf2.modes.TargetTestMode

package com.mcleodgaming.ssf2.modes
{
    import com.mcleodgaming.ssf2.controllers.Game;
    import com.mcleodgaming.ssf2.util.ResourceManager;
    import com.mcleodgaming.ssf2.util.SaveData;
    import com.mcleodgaming.ssf2.controllers.*;
    import com.mcleodgaming.ssf2.enums.*;
    import com.mcleodgaming.ssf2.util.*;

    public class TargetTestMode extends CustomMode 
    {

        public function TargetTestMode(game:Game, modeSettings:Object, stats:Object=null, stub:Boolean=false)
        {
            super(game, modeSettings, stats, stub);
        }

        override public function saveModeData(data:Object):Boolean
        {
            var i:int;
            var id:String;
            var score:int;
            var fps:Number;
            var targetMatches:Array;
            if (GameInstance.ReplayDataObj)
            {
                return (false);
            };
            var wasRecord:Boolean;
            var oldRecord:Object;
            if (data)
            {
                if (data.type !== "targetTest")
                {
                    throw (new Error("Error, expected type to equal 'targetTest'"));
                };
                if ((!(data.matchData)))
                {
                    throw (new Error("Error, matchData was not provided to endMode() for target test match"));
                };
                if ((!(data.matchData.targetMatchID)))
                {
                    throw (new Error("Error, target test match was missing targetMatchID value"));
                };
                if ((!(data.matchData.fps)))
                {
                    throw (new Error("Error, target test match was missing fps value"));
                };
                if ((!(data.matchData.time)))
                {
                    throw (new Error("Error, target test match time value is required"));
                };
                if ((!(data.matchData.character)))
                {
                    throw (new Error("Error, target test match character value is required"));
                };
                id = null;
                targetMatches = ResourceManager.getResourceByID("targets_mode").getProp("targetStageList");
                i = 0;
                while (i < targetMatches.length)
                {
                    if (targetMatches[i].id === data.matchData.targetMatchID)
                    {
                        id = targetMatches[i].id;
                    };
                    i++;
                };
                if ((!(id)))
                {
                    throw (new Error("Error, target test match was missing an ID"));
                };
                oldRecord = SaveData.getTargetTestData(data.matchData.targetMatchID, data.matchData.character);
                score = data.matchData.time;
                fps = data.matchData.fps;
                if (((!(oldRecord)) || (score < oldRecord.score)))
                {
                    wasRecord = true;
                    SaveData.setTargetTestData(data.matchData.targetMatchID, data.matchData.character, {
                        "score":score,
                        "score_fps":fps
                    });
                };
            };
            SaveData.saveGame();
            return (wasRecord);
        }


    }
}//package com.mcleodgaming.ssf2.modes


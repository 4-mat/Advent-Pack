// Decompiled by AS3 Sorcerer 6.30
// www.as3sorcerer.com

//com.mcleodgaming.ssf2.engine.StageSetting

package com.mcleodgaming.ssf2.engine
{
    import __AS3__.vec.Vector;
    import com.mcleodgaming.ssf2.util.ResourceManager;
    import com.mcleodgaming.ssf2.util.SaveData;
    import com.mcleodgaming.ssf2.Main;
    import com.mcleodgaming.ssf2.util.Utils;
    import com.mcleodgaming.ssf2.util.*;
    import __AS3__.vec.*;

    public class StageSetting 
    {


        public static function getStagesArray(includeHidden:Boolean=false):Vector.<String>
        {
            var settingsArray:Vector.<String> = new Vector.<String>();
            var mappings:Object = ResourceManager.getResourceByID("mappings").getProp("metadata");
            var stagesObj:Array = mappings.random_stages.stages;
            var i:int;
            while (i < stagesObj.length)
            {
                if (((((Main.DEBUG) || (includeHidden)) || ((!(includeHidden)) && (!(SaveData.Unlocks[stagesObj[i]] === false)))) && (mappings.stage[stagesObj[i]])))
                {
                    settingsArray.push(stagesObj[i]);
                };
                i++;
            };
            return (settingsArray);
        }

        public static function getRandomStage(includeHidden:Boolean=false, includeDisabled:Boolean=false):String
        {
            var settingsArray:Vector.<String> = getStagesArray(includeHidden);
            var i:int = (settingsArray.length - 1);
            while (((i >= 0) && (!(includeDisabled))))
            {
                if (SaveData.VSStageDataObj[settingsArray[i]] === false)
                {
                    settingsArray.splice(i, 1);
                };
                i--;
            };
            if (settingsArray.length == 0)
            {
                return ("battlefield");
            };
            return (settingsArray[Utils.randomInteger(0, (settingsArray.length - 1))]);
        }


    }
}//package com.mcleodgaming.ssf2.engine


// Decompiled by AS3 Sorcerer 6.30
// www.as3sorcerer.com

//com.mcleodgaming.ssf2.items.ItemsListData

package com.mcleodgaming.ssf2.items
{
    import com.mcleodgaming.ssf2.util.ResourceManager;
    import com.mcleodgaming.ssf2.util.SaveData;
    import com.mcleodgaming.ssf2.util.Utils;
    import com.mcleodgaming.ssf2.util.*;
    import com.mcleodgaming.ssf2.engine.*;

    public class ItemsListData 
    {

        public static var DATA:Array = null;
        public static var OBJECTS:Object;


        public static function init():void
        {
            DATA = ResourceManager.getItemStats();
            OBJECTS = {};
            var i:int;
            while (i < DATA.length)
            {
                OBJECTS[DATA[i].statsName] = DATA[i];
                i++;
            };
        }

        public static function getItemByID(id:String):Object
        {
            return ((OBJECTS[id]) ? OBJECTS[id] : null);
        }

        public static function getItemStatsList(includeHidden:Boolean=true, includeDisabled:Boolean=true):Array
        {
            var list:Array = [];
            var statsCopy:Array = ResourceManager.getItemStats();
            var i:int;
            while (i < statsCopy.length)
            {
                if ((((includeDisabled) || (SaveData.ItemDataObj[statsCopy[i].statsName] === undefined)) && ((includeHidden) || (!(SaveData.Unlocks[statsCopy[i].statsName] === false)))))
                {
                    list.push(statsCopy[i]);
                };
                i++;
            };
            return (list);
        }

        public static function getRandomItemStats(includeHidden:Boolean=true, includeDisabled:Boolean=true):Object
        {
            var list:Array = ItemsListData.getItemStatsList(includeHidden, includeDisabled);
            return ((list.length === 0) ? null : list[Utils.randomInteger(0, list.length)]);
        }


    }
}//package com.mcleodgaming.ssf2.items


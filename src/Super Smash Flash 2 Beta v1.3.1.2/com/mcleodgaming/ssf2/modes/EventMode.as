// Decompiled by AS3 Sorcerer 6.30
// www.as3sorcerer.com

//com.mcleodgaming.ssf2.modes.EventMode

package com.mcleodgaming.ssf2.modes
{
    import com.mcleodgaming.ssf2.controllers.Game;
    import com.mcleodgaming.ssf2.util.ResourceManager;
    import com.mcleodgaming.ssf2.util.SaveData;
    import com.mcleodgaming.ssf2.controllers.UnlockController;
    import com.mcleodgaming.ssf2.controllers.Unlockable;
    import com.mcleodgaming.ssf2.controllers.*;
    import com.mcleodgaming.ssf2.enums.*;
    import com.mcleodgaming.ssf2.util.*;

    public class EventMode extends CustomMode 
    {

        private const rankings:Array = ["S", "A", "B", "C", "D", "E", "F"];

        public function EventMode(game:Game, modeSettings:Object, stats:Object=null, stub:Boolean=false)
        {
            super(game, modeSettings, stats, stub);
        }

        override public function saveModeData(data:Object):Boolean
        {
            var i:int;
            var id:String;
            var score:int;
            var scoreType:String;
            var rank:String;
            var fps:Number;
            var eventMatches:Array;
            var wasRecord:Boolean;
            var oldRecord:Object;
            if (data)
            {
                if (data.type !== "eventMatch")
                {
                    throw (new Error("Error, expected type to equal 'eventMatch'"));
                };
                if ((!(data.matchData)))
                {
                    throw (new Error("Error, matchData was not provided to saveModeData() for event match"));
                };
                if ((!(data.eventMatchID)))
                {
                    throw (new Error("Error, eventMatchID was not provided to saveModeData() for event match"));
                };
                if ((!(data.matchData.fps)))
                {
                    throw (new Error("Error, event match was missing fps value"));
                };
                if ((!(data.matchData.rank)))
                {
                    throw (new Error("Error, event match rank value was undefined and is required"));
                };
                if ((!(data.matchData.rank.match(/^(s|a|b|c|d|e|f)$/i))))
                {
                    throw (new Error("Error, invalid match ranking, should be valued S, A, B, C, D, E, or F"));
                };
                if (typeof(data.matchData.score) === "undefined")
                {
                    throw (new Error("Error, event match was missing score value"));
                };
                if (typeof(data.matchData.scoreType) === "undefined")
                {
                    throw (new Error("Error, event match was missing scoreType value"));
                };
                if ((!(data.matchData.scoreType.match(/^(time|points|damage|stamina|kos)$/))))
                {
                    throw (new Error("Error, event match scoreType value must be 'time', 'points', 'damage', 'stamina', or 'kos'"));
                };
                id = null;
                eventMatches = ResourceManager.getResourceByID("event_mode").getProp("eventList");
                i = 0;
                while (i < eventMatches.length)
                {
                    if (eventMatches[i].id === data.eventMatchID)
                    {
                        id = eventMatches[i].id;
                    };
                    i++;
                };
                if ((!(id)))
                {
                    throw (new Error("Error, event match ID not found"));
                };
                rank = data.matchData.rank.toUpperCase();
                score = data.matchData.score;
                scoreType = data.matchData.scoreType;
                fps = data.matchData.fps;
                if ((!(SaveData.Records.events.wins[id])))
                {
                    SaveData.Records.events.wins[id] = new Object();
                    SaveData.Records.events.wins[id].rank = rank;
                    SaveData.Records.events.wins[id].score = score;
                    SaveData.Records.events.wins[id].scoreType = scoreType;
                    SaveData.Records.events.wins[id].fps = fps;
                    wasRecord = true;
                }
                else
                {
                    if (((this.rankings.indexOf(rank) < this.rankings.indexOf(SaveData.Records.events.wins[id].rank)) || ((rank === SaveData.Records.events.wins[id].rank) && (((scoreType.match(/points|stamina|kos/)) && (score > SaveData.Records.events.wins[id].score)) || ((scoreType.match(/time|damage/)) && (score < SaveData.Records.events.wins[id].score))))))
                    {
                        SaveData.Records.events.wins[id].rank = rank;
                        SaveData.Records.events.wins[id].score = score;
                        SaveData.Records.events.wins[id].scoreType = scoreType;
                        SaveData.Records.events.wins[id].fps = fps;
                        wasRecord = true;
                    };
                };
                if (this.verifyMatchesBefore(true, 1, "F"))
                {
                    UnlockController.getUnlockableByID(Unlockable.EVENT_ALL_STAR_01).TriggerUnlock = true;
                };
                if (this.verifyMatchesBefore(true, 2, "F"))
                {
                    UnlockController.getUnlockableByID(Unlockable.EVENT_ALL_STAR_06).TriggerUnlock = true;
                };
                if (this.verifyMatchesBefore(true, 3, "F"))
                {
                    UnlockController.getUnlockableByID(Unlockable.EVENT_ALL_STAR_07).TriggerUnlock = true;
                };
                if (this.verifyMatchesBefore(true, 4, "F"))
                {
                    UnlockController.getUnlockableByID(Unlockable.EVENT_ALL_STAR_08).TriggerUnlock = true;
                };
                if (this.verifyMatchesBefore(true, 5, "F"))
                {
                    UnlockController.getUnlockableByID(Unlockable.EVENT_ALL_STAR_09).TriggerUnlock = true;
                };
                if (this.verifyMatchesBefore(true, 6, "F"))
                {
                    UnlockController.getUnlockableByID(Unlockable.EVENT_ALL_STAR_BETA).TriggerUnlock = true;
                };
                if (this.verifyMatchesBefore(false, 11, "F"))
                {
                    UnlockController.getUnlockableByID(Unlockable.EVENTS_11_20).TriggerUnlock = true;
                };
                if (this.verifyMatchesBefore(false, 21, "F"))
                {
                    UnlockController.getUnlockableByID(Unlockable.EVENTS_21_30).TriggerUnlock = true;
                };
                if (this.verifyMatchesBefore(false, 31, "F"))
                {
                    UnlockController.getUnlockableByID(Unlockable.EVENTS_31_36).TriggerUnlock = true;
                };
                if (this.verifyMatchesBefore(false, 37, "F"))
                {
                    UnlockController.getUnlockableByID(Unlockable.EVENTS_37_44).TriggerUnlock = true;
                };
                if (this.verifyMatchesBefore(false, 45, "F"))
                {
                    UnlockController.getUnlockableByID(Unlockable.EVENTS_45_50).TriggerUnlock = true;
                };
                if (this.verifyMatchesBefore(false, 51, "A"))
                {
                    UnlockController.getUnlockableByID(Unlockable.EVENT_ARANK).TriggerUnlock = true;
                    UnlockController.getUnlockableByID(Unlockable.EVENTS_51).TriggerUnlock = true;
                };
                if (this.verifyMatchesBefore(false, 52, "S"))
                {
                    UnlockController.getUnlockableByID(Unlockable.EVENT_SRANK).TriggerUnlock = true;
                };
            };
            SaveData.saveGame();
            return (wasRecord);
        }

        protected function verifyMatchesBefore(allStar:Boolean, number:int, atLeastRank:String):Boolean
        {
            atLeastRank = atLeastRank.toUpperCase();
            var events:Array = ResourceManager.getResourceByID("event_mode").getProp("eventList");
            var allStarNumber:int;
            var eventNumber:int;
            var i:int;
            while (i < events.length)
            {
                if (events[i].allStar)
                {
                    allStarNumber++;
                    if (((allStar) && (number === allStarNumber)))
                    {
                        return (true);
                    };
                    if (((!(SaveData.Records.events.wins[events[i].id])) || (this.rankings.indexOf(SaveData.Records.events.wins[events[i].id].rank) > this.rankings.indexOf(atLeastRank))))
                    {
                        return (false);
                    };
                }
                else
                {
                    eventNumber++;
                    if (((!(allStar)) && (number === eventNumber)))
                    {
                        return (true);
                    };
                    if (((!(SaveData.Records.events.wins[events[i].id])) || (this.rankings.indexOf(SaveData.Records.events.wins[events[i].id].rank) > this.rankings.indexOf(atLeastRank))))
                    {
                        return (false);
                    };
                };
                i++;
            };
            return (true);
        }


    }
}//package com.mcleodgaming.ssf2.modes


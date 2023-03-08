// Decompiled by AS3 Sorcerer 6.30
// www.as3sorcerer.com

//com.mcleodgaming.ssf2.api.SSF2CustomMatch

package com.mcleodgaming.ssf2.api
{
    import com.mcleodgaming.ssf2.engine.CustomMatch;
    import com.mcleodgaming.ssf2.controllers.Game;

    public class SSF2CustomMatch extends SSF2BaseAPIObject 
    {

        protected var _ownerCasted:CustomMatch;

        public function SSF2CustomMatch(api:Class, owner:CustomMatch):void
        {
            super(api, owner);
            this._ownerCasted = owner;
        }

        public function getGameSettings():Object
        {
            var game:Game = this._ownerCasted.getGameSettings();
            if (game)
            {
                return (game.exportSettings());
            };
            return (null);
        }

        public function matchSetup(settings:Game):Game
        {
            var results:Object = _api.matchSetup(settings.exportSettings());
            var game:Game = new Game();
            game.GameMode = settings.GameMode;
            game.importSettings(results);
            return (game);
        }


    }
}//package com.mcleodgaming.ssf2.api


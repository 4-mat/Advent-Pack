// Decompiled by AS3 Sorcerer 6.30
// www.as3sorcerer.com

//com.mcleodgaming.ssf2.api.SSF2Beacon

package com.mcleodgaming.ssf2.api
{
    import com.mcleodgaming.ssf2.engine.Beacon;

    public class SSF2Beacon extends SSF2GameObject 
    {

        protected var _ownerCasted:Beacon;

        public function SSF2Beacon(api:Class, owner:Beacon):void
        {
            super(api, owner);
            this._ownerCasted = owner;
        }

    }
}//package com.mcleodgaming.ssf2.api


// Decompiled by AS3 Sorcerer 6.30
// www.as3sorcerer.com

//com.mcleodgaming.ssf2.api.SSF2Target

package com.mcleodgaming.ssf2.api
{
    import com.mcleodgaming.ssf2.engine.TargetTestTarget;

    public class SSF2Target extends SSF2GameObject 
    {

        protected var _ownerCasted:TargetTestTarget;

        public function SSF2Target(api:Class, owner:TargetTestTarget):void
        {
            super(api, owner);
            this._ownerCasted = owner;
        }

        public function breakTarget():void
        {
            this._ownerCasted.breakTarget();
        }

        public function destroy():void
        {
            this._ownerCasted.destroy();
        }

        public function addMovement(movement:Object):void
        {
            this._ownerCasted.addMovement(movement);
        }

        public function clearMovement():void
        {
            this._ownerCasted.clearMovement();
        }

        public function setHurtInterrupt(fn:Function):void
        {
            _ownerCastedBase.HurtInterrupt = fn;
        }


    }
}//package com.mcleodgaming.ssf2.api


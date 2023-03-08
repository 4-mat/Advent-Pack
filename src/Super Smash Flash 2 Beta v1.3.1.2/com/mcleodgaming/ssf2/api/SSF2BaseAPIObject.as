// Decompiled by AS3 Sorcerer 6.30
// www.as3sorcerer.com

//com.mcleodgaming.ssf2.api.SSF2BaseAPIObject

package com.mcleodgaming.ssf2.api
{
    public class SSF2BaseAPIObject 
    {

        protected var _api:*;
        protected var _owner:*;
        protected var _metadata:Object;
        protected var _initialized:Boolean;

        public function SSF2BaseAPIObject(api:Class, owner:*):void
        {
            this._api = ((api) ? new api(this) : null);
            this._owner = owner;
            this._metadata = {};
            this._initialized = false;
        }

        public function get metadata():Object
        {
            return (this._metadata);
        }

        public function get owner():*
        {
            return (this._owner);
        }

        public function get instance():*
        {
            return (this._api);
        }

        public function dispose():void
        {
            if (this._api)
            {
                if (("dispose" in this._api))
                {
                    this._api.dispose();
                };
                if (("__dispose" in this._api))
                {
                    this._api.__dispose();
                };
            };
            this._api = null;
            this._owner = null;
            this._metadata = null;
            this._initialized = false;
        }

        public function initialize():void
        {
            if (((this._api) && (!(this._initialized))))
            {
                this._initialized = true;
                this._api.initialize();
            };
        }

        public function update():void
        {
            if (this._api)
            {
                this._api.update();
            };
        }


    }
}//package com.mcleodgaming.ssf2.api


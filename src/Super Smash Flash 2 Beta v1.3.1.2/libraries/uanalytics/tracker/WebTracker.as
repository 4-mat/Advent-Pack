// Decompiled by AS3 Sorcerer 6.30
// www.as3sorcerer.com

//libraries.uanalytics.tracker.WebTracker

package libraries.uanalytics.tracker
{
    import flash.net.SharedObject;
    import libraries.uanalytics.tracking.Configuration;
    import libraries.uanalytics.tracking.HitModel;
    import flash.system.ApplicationDomain;
    import libraries.uanalytics.tracker.senders.LoaderHitSender;
    import libraries.uanalytics.tracking.RateLimiter;
    import libraries.uanalytics.tracking.Tracker;
    import libraries.uanalytics.utils.generateUUID;
    import flash.events.NetStatusEvent;
    import flash.net.SharedObjectFlushStatus;

    public class WebTracker extends DefaultTracker 
    {

        protected var _storage:SharedObject;

        public function WebTracker(trackingId:String="", config:Configuration=null)
        {
            super(trackingId, config);
        }

        override protected function _ctor(trackingId:String=""):void
        {
            var S:Class;
            _model = new HitModel();
            _temporary = new HitModel();
            if (_config.senderType != "")
            {
                S = (ApplicationDomain.currentDomain.getDefinition(_config.senderType) as Class);
                _sender = new S(this);
            }
            else
            {
                _sender = new LoaderHitSender(this);
            };
            _limiter = new RateLimiter(20, 2, 1);
            if (trackingId != "")
            {
                set(TRACKING_ID, trackingId);
            };
            var cid:String = this._getClientID();
            if (cid != "")
            {
                set(CLIENT_ID, cid);
            };
            set(Tracker.DATA_SOURCE, DataSource.WEB);
        }

        override protected function _getClientID():String
        {
            var cid:String;
            var flushStatus:String;
            this._storage = SharedObject.getLocal(_config.storageName);
            if ((!(this._storage.data.clientid)))
            {
                cid = generateUUID();
                this._storage.data.clientid = cid;
                flushStatus = null;
                try
                {
                    flushStatus = this._storage.flush(0x0400);
                }
                catch(e:Error)
                {
                };
                if (flushStatus != null)
                {
                    switch (flushStatus)
                    {
                        case SharedObjectFlushStatus.PENDING:
                            this._storage.addEventListener(NetStatusEvent.NET_STATUS, this.onFlushStatus);
                            break;
                        case SharedObjectFlushStatus.FLUSHED:
                            break;
                    };
                };
            }
            else
            {
                cid = this._storage.data.clientid;
            };
            return (cid);
        }

        protected function onFlushStatus(event:NetStatusEvent):void
        {
            this._storage.removeEventListener(NetStatusEvent.NET_STATUS, this.onFlushStatus);
            switch (event.info.code)
            {
                case "SharedObject.Flush.Success":
                    break;
                case "SharedObject.Flush.Failed":
                    break;
            };
        }


    }
}//package libraries.uanalytics.tracker


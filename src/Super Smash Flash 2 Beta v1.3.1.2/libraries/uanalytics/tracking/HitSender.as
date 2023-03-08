// Decompiled by AS3 Sorcerer 6.30
// www.as3sorcerer.com

//libraries.uanalytics.tracking.HitSender

package libraries.uanalytics.tracking
{
    import __AS3__.vec.Vector;

    public class HitSender implements AnalyticsSender 
    {


        protected function _addParameter(name:String, value:String):String
        {
            var str:String = "";
            str = (str + "&");
            str = (str + this._appendEncoded(name.substring(1)));
            str = (str + "=");
            str = (str + this._appendEncoded(value));
            return (str);
        }

        protected function _appendEncoded(value:String):String
        {
            return (encodeURIComponent(value));
        }

        protected function _buildHit(model:HitModel):String
        {
            var name:String;
            var value:String;
            var i:uint;
            var str:String = "";
            str = (str + "v=1");
            if (Configuration.SDKversion != "")
            {
                str = (str + this._addParameter("&_v", Configuration.SDKversion));
            };
            var names:Vector.<String> = model.getFieldNames();
            names.sort(Array.CASEINSENSITIVE);
            i = 0;
            while (i < names.length)
            {
                name = names[i];
                if (((name.length > 0) && (name.charAt(0) == Metadata.FIELD_PREFIX)))
                {
                    value = model.get(name);
                    if (value != null)
                    {
                        str = (str + this._addParameter(name, value));
                    };
                };
                i++;
            };
            return (str);
        }

        public function send(model:HitModel):void
        {
        }


    }
}//package libraries.uanalytics.tracking


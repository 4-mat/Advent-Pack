// Decompiled by AS3 Sorcerer 6.30
// www.as3sorcerer.com

//libraries.uanalytics.tracking.HitModel

package libraries.uanalytics.tracking
{
    import flash.utils.Dictionary;
    import __AS3__.vec.Vector;
    import __AS3__.vec.*;

    public class HitModel 
    {

        private var _data:Dictionary;
        private var _metadata:Metadata;

        public function HitModel()
        {
            this._metadata = new Metadata();
            this.clear();
        }

        public function set(field:String, value:String):void
        {
            this._data[this._metadata.getHitModelKey(field)] = value;
        }

        public function get(field:String):String
        {
            return (this._data[this._metadata.getHitModelKey(field)]);
        }

        public function add(model:HitModel):void
        {
            var key:String;
            for (key in model._data)
            {
                this._data[key] = model._data[key];
            };
        }

        public function clone():HitModel
        {
            var key:String;
            var copy:HitModel = new HitModel();
            for (key in this._data)
            {
                copy._data[key] = this._data[key];
            };
            return (copy);
        }

        public function clear():void
        {
            this._data = new Dictionary();
        }

        public function getFieldNames():Vector.<String>
        {
            var keys:String;
            var data:Vector.<String> = new Vector.<String>();
            for (keys in this._data)
            {
                data.push(keys);
            };
            return (data);
        }


    }
}//package libraries.uanalytics.tracking


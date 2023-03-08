// Decompiled by AS3 Sorcerer 6.30
// www.as3sorcerer.com

//com.mcleodgaming.mgn.net.DataFrameGroup

package com.mcleodgaming.mgn.net
{
    import __AS3__.vec.Vector;
    import __AS3__.vec.*;

    public class DataFrameGroup 
    {

        private var _frame:uint;
        private var _fulfillCount:int;
        private var _dataFrameGroup:Vector.<DataFrame>;
        private var _complete:Boolean;

        public function DataFrameGroup(frame:uint, size:int)
        {
            this._frame = frame;
            this._fulfillCount = 0;
            this._dataFrameGroup = new Vector.<DataFrame>();
            while (size > 0)
            {
                size--;
                this._dataFrameGroup.push(new DataFrame());
            };
            this._complete = false;
        }

        public function get Complete():Boolean
        {
            return (this._complete);
        }

        public function get Size():int
        {
            return (this._dataFrameGroup.length);
        }

        public function get Frame():uint
        {
            return (this._frame);
        }

        public function set Frame(value:uint):void
        {
            this._frame = value;
        }

        public function getDataFrameFor(index:int):DataFrame
        {
            return (this._dataFrameGroup[index]);
        }

        public function updateDataFrameFor(index:int, data:Object):void
        {
            if (index >= this._dataFrameGroup.length)
            {
                trace("Warning: Missing slot for data frame! Perhaps was disconnected?");
                return;
            };
            if (this._dataFrameGroup[index].updateData(data))
            {
                this._fulfillCount++;
                if (this._fulfillCount >= this._dataFrameGroup.length)
                {
                    this._complete = true;
                };
            };
        }


    }
}//package com.mcleodgaming.mgn.net


// Decompiled by AS3 Sorcerer 6.30
// www.as3sorcerer.com

//fl.events.DataGridEvent

package fl.events
{
    import flash.events.Event;

    public class DataGridEvent extends ListEvent 
    {

        public static const COLUMN_STRETCH:String = "columnStretch";
        public static const HEADER_RELEASE:String = "headerRelease";
        public static const ITEM_EDIT_BEGINNING:String = "itemEditBeginning";
        public static const ITEM_EDIT_BEGIN:String = "itemEditBegin";
        public static const ITEM_EDIT_END:String = "itemEditEnd";
        public static const ITEM_FOCUS_IN:String = "itemFocusIn";
        public static const ITEM_FOCUS_OUT:String = "itemFocusOut";

        protected var _dataField:String;
        protected var _itemRenderer:Object;
        protected var _reason:String;

        public function DataGridEvent(_arg_1:String, _arg_2:Boolean=false, _arg_3:Boolean=false, _arg_4:int=-1, _arg_5:int=-1, _arg_6:Object=null, _arg_7:String=null, _arg_8:String=null)
        {
            super(_arg_1, _arg_2, _arg_3, _arg_4, _arg_5);
            this._itemRenderer = _arg_6;
            this._dataField = _arg_7;
            this._reason = _arg_8;
        }

        public function get itemRenderer():Object
        {
            return (this._itemRenderer);
        }

        public function get dataField():String
        {
            return (this._dataField);
        }

        public function set dataField(_arg_1:String):void
        {
            this._dataField = _arg_1;
        }

        public function get reason():String
        {
            return (this._reason);
        }

        override public function toString():String
        {
            return (formatToString("DataGridEvent", "type", "bubbles", "cancelable", "columnIndex", "rowIndex", "itemRenderer", "dataField", "reason"));
        }

        override public function clone():Event
        {
            return (new DataGridEvent(type, bubbles, cancelable, columnIndex, int(rowIndex), this._itemRenderer, this._dataField, this._reason));
        }


    }
}//package fl.events


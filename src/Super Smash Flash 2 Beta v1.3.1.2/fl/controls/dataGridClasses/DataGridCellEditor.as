// Decompiled by AS3 Sorcerer 6.30
// www.as3sorcerer.com

//fl.controls.dataGridClasses.DataGridCellEditor

package fl.controls.dataGridClasses
{
    import fl.controls.TextInput;
    import fl.controls.listClasses.ICellRenderer;
    import fl.controls.listClasses.ListData;

    [Style(name="textFormat", type="flash.text.TextFormat")]
    [Style(name="upSkin", type="Class")]
    [Style(name="textPadding", type="Number", format="Length")]
    public class DataGridCellEditor extends TextInput implements ICellRenderer 
    {

        private static var defaultStyles:Object = {
            "textPadding":1,
            "textFormat":null,
            "upSkin":"DataGridCellEditor_skin"
        };

        protected var _listData:ListData;
        protected var _data:Object;

        public function DataGridCellEditor():void
        {
        }

        public static function getStyleDefinition():Object
        {
            return (defaultStyles);
        }


        public function get listData():ListData
        {
            return (this._listData);
        }

        public function set listData(_arg_1:ListData):void
        {
            this._listData = _arg_1;
            text = this._listData.label;
        }

        public function get data():Object
        {
            return (this._data);
        }

        public function set data(_arg_1:Object):void
        {
            this._data = _arg_1;
        }

        public function get selected():Boolean
        {
            return (false);
        }

        public function set selected(_arg_1:Boolean):void
        {
        }

        public function setMouseState(_arg_1:String):void
        {
        }


    }
}//package fl.controls.dataGridClasses


// Decompiled by AS3 Sorcerer 6.30
// www.as3sorcerer.com

//fl.controls.dataGridClasses.DataGridColumn

package fl.controls.dataGridClasses
{
    import fl.controls.DataGrid;
    import fl.core.InvalidationType;

    public class DataGridColumn 
    {

        private var _columnName:String;
        private var _headerText:String;
        private var _minWidth:Number = 20;
        private var _width:Number = 100;
        private var _visible:Boolean = true;
        private var _cellRenderer:Object;
        private var _headerRenderer:Object;
        private var _labelFunction:Function;
        private var _sortCompareFunction:Function;
        private var _imeMode:String;
        public var owner:DataGrid;
        public var colNum:Number;
        public var explicitWidth:Number;
        public var sortable:Boolean = true;
        public var resizable:Boolean = true;
        public var editable:Boolean = true;
        public var itemEditor:Object = "fl.controls.dataGridClasses.DataGridCellEditor";
        public var editorDataField:String = "text";
        public var dataField:String;
        public var sortDescending:Boolean = false;
        public var sortOptions:uint = 0;
        private var forceImport:DataGridCellEditor;

        public function DataGridColumn(_arg_1:String=null)
        {
            if (_arg_1)
            {
                this.dataField = _arg_1;
                this.headerText = _arg_1;
            };
        }

        public function get cellRenderer():Object
        {
            return (this._cellRenderer);
        }

        public function set cellRenderer(_arg_1:Object):void
        {
            this._cellRenderer = _arg_1;
            if (this.owner)
            {
                this.owner.invalidate(InvalidationType.DATA);
            };
        }

        public function get headerRenderer():Object
        {
            return (this._headerRenderer);
        }

        public function set headerRenderer(_arg_1:Object):void
        {
            this._headerRenderer = _arg_1;
            if (this.owner)
            {
                this.owner.invalidate(InvalidationType.DATA);
            };
        }

        public function get headerText():String
        {
            return ((this._headerText != null) ? this._headerText : this.dataField);
        }

        public function set headerText(_arg_1:String):void
        {
            this._headerText = _arg_1;
            if (this.owner)
            {
                this.owner.invalidate(InvalidationType.DATA);
            };
        }

        public function get imeMode():String
        {
            return (this._imeMode);
        }

        public function set imeMode(_arg_1:String):void
        {
            this._imeMode = _arg_1;
        }

        public function get labelFunction():Function
        {
            return (this._labelFunction);
        }

        public function set labelFunction(_arg_1:Function):void
        {
            if (this._labelFunction == _arg_1)
            {
                return;
            };
            this._labelFunction = _arg_1;
            if (this.owner)
            {
                this.owner.invalidate(InvalidationType.DATA);
            };
        }

        public function get minWidth():Number
        {
            return (this._minWidth);
        }

        public function set minWidth(_arg_1:Number):void
        {
            this._minWidth = _arg_1;
            if (this._width < _arg_1)
            {
                this._width = _arg_1;
            };
            if (this.owner)
            {
                this.owner.invalidate(InvalidationType.SIZE);
            };
        }

        public function get sortCompareFunction():Function
        {
            return (this._sortCompareFunction);
        }

        public function set sortCompareFunction(_arg_1:Function):void
        {
            this._sortCompareFunction = _arg_1;
        }

        public function get visible():Boolean
        {
            return (this._visible);
        }

        public function set visible(_arg_1:Boolean):void
        {
            if (this._visible != _arg_1)
            {
                this._visible = _arg_1;
                if (this.owner)
                {
                    this.owner.invalidate(InvalidationType.SIZE);
                };
            };
        }

        public function get width():Number
        {
            return (this._width);
        }

        public function set width(_arg_1:Number):void
        {
            var _local_2:Boolean;
            this.explicitWidth = _arg_1;
            if (this.owner != null)
            {
                _local_2 = this.resizable;
                this.resizable = false;
                this.owner.resizeColumn(this.colNum, _arg_1);
                this.resizable = _local_2;
            }
            else
            {
                this._width = _arg_1;
            };
        }

        public function setWidth(_arg_1:Number):void
        {
            this._width = _arg_1;
        }

        public function itemToLabel(data:Object):String
        {
            if ((!(data)))
            {
                return (" ");
            };
            if (this.labelFunction != null)
            {
                return (this.labelFunction(data));
            };
            if (this.owner.labelFunction != null)
            {
                return (this.owner.labelFunction(data, this));
            };
            if (((typeof(data) == "object") || (typeof(data) == "xml")))
            {
                try
                {
                    data = data[this.dataField];
                }
                catch(e:Error)
                {
                    data = null;
                };
            };
            if ((data is String))
            {
                return (String(data));
            };
            try
            {
                return (data.toString());
            }
            catch(e:Error)
            {
            };
            return (" ");
        }

        public function toString():String
        {
            return ("[object DataGridColumn]");
        }


    }
}//package fl.controls.dataGridClasses


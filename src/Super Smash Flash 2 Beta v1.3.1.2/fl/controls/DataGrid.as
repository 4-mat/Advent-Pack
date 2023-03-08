// Decompiled by AS3 Sorcerer 6.30
// www.as3sorcerer.com

//fl.controls.DataGrid

package fl.controls
{
    import fl.managers.IFocusManagerComponent;
    import fl.controls.dataGridClasses.HeaderRenderer;
    import flash.display.Sprite;
    import flash.utils.Dictionary;
    import fl.events.DataGridEvent;
    import flash.events.MouseEvent;
    import fl.data.DataProvider;
    import fl.core.InvalidationType;
    import fl.controls.listClasses.ICellRenderer;
    import fl.controls.dataGridClasses.DataGridColumn;
    import flash.display.Graphics;
    import fl.core.UIComponent;
    import flash.display.DisplayObject;
    import flash.events.Event;
    import fl.controls.listClasses.ListData;
    import flash.geom.Point;
    import fl.events.DataGridEventReason;
    import flash.display.DisplayObjectContainer;
    import flash.ui.Mouse;
    import fl.managers.IFocusManager;
    import flash.display.InteractiveObject;
    import flash.utils.describeType;
    import flash.events.FocusEvent;
    import flash.ui.Keyboard;
    import flash.events.KeyboardEvent;
    import fl.events.DataChangeEvent;

    [Event(name="headerRelease", type="fl.events.DataGridEvent")]
    [Event(name="columnStretch", type="fl.events.DataGridEvent")]
    [Event(name="itemEditBeginning", type="fl.events.DataGridEvent")]
    [Event(name="itemEditBegin", type="fl.events.DataGridEvent")]
    [Event(name="itemEditEnd", type="fl.events.DataGridEvent")]
    [Event(name="itemFocusIn", type="fl.events.DataGridEvent")]
    [Event(name="itemFocusOut", type="fl.events.DataGridEvent")]
    [Style(name="columnStretchCursorSkin", type="Class")]
    [Style(name="columnDividerSkin", type="Class")]
    [Style(name="headerUpSkin", type="Class")]
    [Style(name="headerOverSkin", type="Class")]
    [Style(name="headerDownSkin", type="Class")]
    [Style(name="headerDisabledSkin", type="Class")]
    [Style(name="headerSortArrowDescSkin", type="Class")]
    [Style(name="headerSortArrowAscSkin", type="Class")]
    [Style(name="headerTextFormat", type="flash.text.TextFormat")]
    [Style(name="headerDisabledTextFormat", type="flash.text.TextFormat")]
    [Style(name="headerTextPadding", type="Number", format="Length")]
    [Style(name="headerRenderer", type="Class")]
    [InspectableList("allowMultipleSelection", "editable", "headerHeight", "horizontalLineScrollSize", "horizontalPageScrollSize", "horizontalScrollPolicy", "resizableColumns", "rowHeight", "showHeaders", "sortableColumns", "verticalLineScrollSize", "verticalPageScrollSize", "verticalScrollPolicy")]
    public class DataGrid extends SelectableList implements IFocusManagerComponent 
    {

        private static var defaultStyles:Object = {
            "headerUpSkin":"HeaderRenderer_upSkin",
            "headerDownSkin":"HeaderRenderer_downSkin",
            "headerOverSkin":"HeaderRenderer_overSkin",
            "headerDisabledSkin":"HeaderRenderer_disabledSkin",
            "headerSortArrowDescSkin":"HeaderSortArrow_descIcon",
            "headerSortArrowAscSkin":"HeaderSortArrow_ascIcon",
            "columnStretchCursorSkin":"ColumnStretch_cursor",
            "columnDividerSkin":null,
            "headerTextFormat":null,
            "headerDisabledTextFormat":null,
            "headerTextPadding":5,
            "headerRenderer":HeaderRenderer,
            "focusRectSkin":null,
            "focusRectPadding":null,
            "skin":"DataGrid_skin"
        };
        protected static const HEADER_STYLES:Object = {
            "disabledSkin":"headerDisabledSkin",
            "downSkin":"headerDownSkin",
            "overSkin":"headerOverSkin",
            "upSkin":"headerUpSkin",
            "textFormat":"headerTextFormat",
            "disabledTextFormat":"headerDisabledTextFormat",
            "textPadding":"headerTextPadding"
        };
        public static var createAccessibilityImplementation:Function;

        protected var _rowHeight:Number = 20;
        protected var _headerHeight:Number = 25;
        protected var _showHeaders:Boolean = true;
        protected var _columns:Array;
        protected var _minColumnWidth:Number;
        protected var header:Sprite;
        protected var headerMask:Sprite;
        protected var headerSortArrow:Sprite;
        protected var _cellRenderer:Object;
        protected var _headerRenderer:Object;
        protected var _labelFunction:Function;
        protected var visibleColumns:Array;
        protected var displayableColumns:Array;
        protected var columnsInvalid:Boolean = true;
        protected var minColumnWidthInvalid:Boolean = false;
        protected var activeCellRenderersMap:Dictionary;
        protected var availableCellRenderersMap:Dictionary;
        protected var dragHandlesMap:Dictionary;
        protected var columnStretchIndex:Number = -1;
        protected var columnStretchStartX:Number;
        protected var columnStretchStartWidth:Number;
        protected var columnStretchCursor:Sprite;
        protected var _sortIndex:int = -1;
        protected var lastSortIndex:int = -1;
        protected var _sortDescending:Boolean = false;
        protected var _editedItemPosition:Object;
        protected var editedItemPositionChanged:Boolean = false;
        protected var proposedEditedItemPosition:*;
        protected var actualRowIndex:int;
        protected var actualColIndex:int;
        protected var isPressed:Boolean = false;
        protected var losingFocus:Boolean = false;
        protected var maxHeaderHeight:Number = 25;
        protected var currentHoveredRow:int = -1;
        [Inspectable(defaultValue="false")]
        public var editable:Boolean = false;
        [Inspectable(defaultValue="true")]
        public var resizableColumns:Boolean = true;
        [Inspectable(defaultValue="true")]
        public var sortableColumns:Boolean = true;
        public var itemEditorInstance:Object;

        public function DataGrid()
        {
            if (this._columns == null)
            {
                this._columns = [];
            };
            _horizontalScrollPolicy = ScrollPolicy.OFF;
            this.activeCellRenderersMap = new Dictionary(true);
            this.availableCellRenderersMap = new Dictionary(true);
            addEventListener(DataGridEvent.ITEM_EDIT_BEGINNING, this.itemEditorItemEditBeginningHandler, false, -50);
            addEventListener(DataGridEvent.ITEM_EDIT_BEGIN, this.itemEditorItemEditBeginHandler, false, -50);
            addEventListener(DataGridEvent.ITEM_EDIT_END, this.itemEditorItemEditEndHandler, false, -50);
            addEventListener(MouseEvent.MOUSE_DOWN, this.mouseDownHandler);
            addEventListener(MouseEvent.MOUSE_UP, this.mouseUpHandler);
        }

        public static function getStyleDefinition():Object
        {
            return (mergeStyles(defaultStyles, SelectableList.getStyleDefinition(), ScrollBar.getStyleDefinition()));
        }


        override public function set dataProvider(_arg_1:DataProvider):void
        {
            super.dataProvider = _arg_1;
            if (this._columns == null)
            {
                this._columns = [];
            };
            if (this._columns.length == 0)
            {
                this.createColumnsFromDataProvider();
            };
            this.removeCellRenderers();
        }

        [Inspectable(defaultValue="true", verbose="1")]
        override public function set enabled(_arg_1:Boolean):void
        {
            super.enabled = _arg_1;
            this.header.mouseChildren = _enabled;
        }

        override public function setSize(_arg_1:Number, _arg_2:Number):void
        {
            super.setSize(_arg_1, _arg_2);
            this.columnsInvalid = true;
        }

        [Inspectable(defaultValue="off", enumeration="on,off,auto")]
        override public function get horizontalScrollPolicy():String
        {
            return (_horizontalScrollPolicy);
        }

        override public function set horizontalScrollPolicy(_arg_1:String):void
        {
            super.horizontalScrollPolicy = _arg_1;
            this.columnsInvalid = true;
        }

        public function get columns():Array
        {
            return (this._columns.slice(0));
        }

        public function set columns(_arg_1:Array):void
        {
            this.removeCellRenderers();
            this._columns = [];
            var _local_2:uint;
            while (_local_2 < _arg_1.length)
            {
                this.addColumn(_arg_1[_local_2]);
                _local_2++;
            };
        }

        public function get minColumnWidth():Number
        {
            return (this._minColumnWidth);
        }

        public function set minColumnWidth(_arg_1:Number):void
        {
            this._minColumnWidth = _arg_1;
            this.columnsInvalid = true;
            this.minColumnWidthInvalid = true;
            invalidate(InvalidationType.SIZE);
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
            invalidate(InvalidationType.DATA);
        }

        override public function get rowCount():uint
        {
            return (Math.ceil((this.calculateAvailableHeight() / this.rowHeight)));
        }

        public function set rowCount(_arg_1:uint):void
        {
            var _local_2:Number = Number(getStyleValue("contentPadding"));
            var _local_3:Number = (((_horizontalScrollPolicy == ScrollPolicy.ON) || ((_horizontalScrollPolicy == ScrollPolicy.AUTO) && (hScrollBar))) ? 15 : 0);
            height = ((((this.rowHeight * _arg_1) + (2 * _local_2)) + _local_3) + ((this.showHeaders) ? this.headerHeight : 0));
        }

        [Inspectable(defaultValue="20")]
        public function get rowHeight():Number
        {
            return (this._rowHeight);
        }

        public function set rowHeight(_arg_1:Number):void
        {
            this._rowHeight = Math.max(0, _arg_1);
            invalidate(InvalidationType.SIZE);
        }

        [Inspectable(defaultValue="25")]
        public function get headerHeight():Number
        {
            return (this._headerHeight);
        }

        public function set headerHeight(_arg_1:Number):void
        {
            this.maxHeaderHeight = _arg_1;
            this._headerHeight = Math.max(0, _arg_1);
            invalidate(InvalidationType.SIZE);
        }

        [Inspectable(defaultValue="true")]
        public function get showHeaders():Boolean
        {
            return (this._showHeaders);
        }

        public function set showHeaders(_arg_1:Boolean):void
        {
            this._showHeaders = _arg_1;
            invalidate(InvalidationType.SIZE);
        }

        public function get sortIndex():int
        {
            return (this._sortIndex);
        }

        public function get sortDescending():Boolean
        {
            return (this._sortDescending);
        }

        public function get imeMode():String
        {
            return (_imeMode);
        }

        public function set imeMode(_arg_1:String):void
        {
            _imeMode = _arg_1;
        }

        public function get editedItemRenderer():ICellRenderer
        {
            if ((!(this.itemEditorInstance)))
            {
                return (null);
            };
            return (this.getCellRendererAt(this.actualRowIndex, this.actualColIndex));
        }

        public function get editedItemPosition():Object
        {
            if (this._editedItemPosition)
            {
                return ({
                    "rowIndex":this._editedItemPosition.rowIndex,
                    "columnIndex":this._editedItemPosition.columnIndex
                });
            };
            return (this._editedItemPosition);
        }

        public function set editedItemPosition(_arg_1:Object):void
        {
            var _local_2:Object = {
                "rowIndex":_arg_1.rowIndex,
                "columnIndex":_arg_1.columnIndex
            };
            this.setEditedItemPosition(_local_2);
        }

        protected function calculateAvailableHeight():Number
        {
            var _local_1:Number = Number(getStyleValue("contentPadding"));
            var _local_2:Number = (((_horizontalScrollPolicy == ScrollPolicy.ON) || ((_horizontalScrollPolicy == ScrollPolicy.AUTO) && (_maxHorizontalScrollPosition > 0))) ? 15 : 0);
            return (((height - (_local_1 * 2)) - _local_2) - ((this.showHeaders) ? this.headerHeight : 0));
        }

        public function addColumn(_arg_1:*):DataGridColumn
        {
            return (this.addColumnAt(_arg_1, this._columns.length));
        }

        public function addColumnAt(_arg_1:*, _arg_2:uint):DataGridColumn
        {
            var _local_3:DataGridColumn;
            var _local_5:uint;
            if (_arg_2 < this._columns.length)
            {
                this._columns.splice(_arg_2, 0, "");
                _local_5 = (_arg_2 + 1);
                while (_local_5 < this._columns.length)
                {
                    _local_3 = (this._columns[_local_5] as DataGridColumn);
                    _local_3.colNum = _local_5;
                    _local_5++;
                };
            };
            var _local_4:* = _arg_1;
            if ((!(_local_4 is DataGridColumn)))
            {
                if ((_local_4 is String))
                {
                    _local_4 = new DataGridColumn(_local_4);
                }
                else
                {
                    _local_4 = new DataGridColumn();
                };
            };
            _local_3 = (_local_4 as DataGridColumn);
            _local_3.owner = this;
            _local_3.colNum = _arg_2;
            this._columns[_arg_2] = _local_3;
            invalidate(InvalidationType.SIZE);
            this.columnsInvalid = true;
            return (_local_3);
        }

        public function removeColumnAt(_arg_1:uint):DataGridColumn
        {
            var _local_3:uint;
            var _local_2:DataGridColumn = (this._columns[_arg_1] as DataGridColumn);
            if (_local_2 != null)
            {
                this.removeCellRenderersByColumn(_local_2);
                this._columns.splice(_arg_1, 1);
                _local_3 = _arg_1;
                while (_local_3 < this._columns.length)
                {
                    _local_2 = (this._columns[_local_3] as DataGridColumn);
                    if (_local_2)
                    {
                        _local_2.colNum = _local_3;
                    };
                    _local_3++;
                };
                invalidate(InvalidationType.SIZE);
                this.columnsInvalid = true;
            };
            return (_local_2);
        }

        public function removeAllColumns():void
        {
            if (this._columns.length > 0)
            {
                this.removeCellRenderers();
                this._columns = [];
                invalidate(InvalidationType.SIZE);
                this.columnsInvalid = true;
            };
        }

        public function getColumnAt(_arg_1:uint):DataGridColumn
        {
            return (this._columns[_arg_1] as DataGridColumn);
        }

        public function getColumnIndex(_arg_1:String):int
        {
            var _local_3:DataGridColumn;
            var _local_2:uint;
            while (_local_2 < this._columns.length)
            {
                _local_3 = (this._columns[_local_2] as DataGridColumn);
                if (_local_3.dataField == _arg_1)
                {
                    return (_local_2);
                };
                _local_2++;
            };
            return (-1);
        }

        public function getColumnCount():uint
        {
            return (this._columns.length);
        }

        public function spaceColumnsEqually():void
        {
            var _local_1:Number;
            var _local_2:int;
            var _local_3:DataGridColumn;
            drawNow();
            if (this.displayableColumns.length > 0)
            {
                _local_1 = (availableWidth / this.displayableColumns.length);
                _local_2 = 0;
                while (_local_2 < this.displayableColumns.length)
                {
                    _local_3 = (this.displayableColumns[_local_2] as DataGridColumn);
                    _local_3.width = _local_1;
                    _local_2++;
                };
                invalidate(InvalidationType.SIZE);
                this.columnsInvalid = true;
            };
        }

        public function editField(_arg_1:uint, _arg_2:String, _arg_3:Object):void
        {
            var _local_4:Object = getItemAt(_arg_1);
            _local_4[_arg_2] = _arg_3;
            replaceItemAt(_local_4, _arg_1);
        }

        override public function itemToCellRenderer(_arg_1:Object):ICellRenderer
        {
            return (null);
        }

        override protected function configUI():void
        {
            useFixedHorizontalScrolling = false;
            super.configUI();
            this.headerMask = new Sprite();
            var _local_1:Graphics = this.headerMask.graphics;
            _local_1.beginFill(0, 0.3);
            _local_1.drawRect(0, 0, 100, 100);
            _local_1.endFill();
            this.headerMask.visible = false;
            addChild(this.headerMask);
            this.header = new Sprite();
            addChild(this.header);
            this.header.mask = this.headerMask;
            _horizontalScrollPolicy = ScrollPolicy.OFF;
            _verticalScrollPolicy = ScrollPolicy.AUTO;
        }

        override protected function draw():void
        {
            var _local_1:Boolean = (!(contentHeight == (this.rowHeight * length)));
            contentHeight = (this.rowHeight * length);
            if (isInvalid(InvalidationType.STYLES))
            {
                setStyles();
                drawBackground();
                if (contentPadding != getStyleValue("contentPadding"))
                {
                    invalidate(InvalidationType.SIZE, false);
                };
                if (((!(this._cellRenderer == getStyleValue("cellRenderer"))) || (!(this._headerRenderer == getStyleValue("headerRenderer")))))
                {
                    _invalidateList();
                    this._cellRenderer = getStyleValue("cellRenderer");
                    this._headerRenderer = getStyleValue("headerRenderer");
                };
            };
            if (isInvalid(InvalidationType.SIZE))
            {
                this.columnsInvalid = true;
            };
            if (((isInvalid(InvalidationType.SIZE, InvalidationType.STATE)) || (_local_1)))
            {
                this.drawLayout();
                drawDisabledOverlay();
            };
            if (isInvalid(InvalidationType.RENDERER_STYLES))
            {
                this.updateRendererStyles();
            };
            if (isInvalid(InvalidationType.STYLES, InvalidationType.SIZE, InvalidationType.DATA, InvalidationType.SCROLL, InvalidationType.SELECTED))
            {
                this.drawList();
            };
            updateChildren();
            validate();
        }

        override protected function drawLayout():void
        {
            vOffset = ((this.showHeaders) ? this.headerHeight : 0);
            super.drawLayout();
            contentScrollRect = listHolder.scrollRect;
            if (this.showHeaders)
            {
                this.headerHeight = this.maxHeaderHeight;
                if (Math.floor((availableHeight - this.headerHeight)) <= 0)
                {
                    this._headerHeight = availableHeight;
                };
                list.y = this.headerHeight;
                contentScrollRect = listHolder.scrollRect;
                contentScrollRect.y = (contentPadding + this.headerHeight);
                contentScrollRect.height = (availableHeight - this.headerHeight);
                listHolder.y = (contentPadding + this.headerHeight);
                this.headerMask.x = contentPadding;
                this.headerMask.y = contentPadding;
                this.headerMask.width = availableWidth;
                this.headerMask.height = this.headerHeight;
            }
            else
            {
                contentScrollRect.y = contentPadding;
                listHolder.y = 0;
            };
            listHolder.scrollRect = contentScrollRect;
        }

        override protected function drawList():void
        {
            var _local_3:Number;
            var _local_4:Number;
            var _local_5:uint;
            var _local_6:Object;
            var _local_7:ICellRenderer;
            var _local_8:Array;
            var _local_9:DataGridColumn;
            var _local_13:Sprite;
            var _local_14:UIComponent;
            var _local_18:Number;
            var _local_19:DataGridColumn;
            var _local_20:Object;
            var _local_21:Array;
            var _local_22:Dictionary;
            var _local_23:Object;
            var _local_24:HeaderRenderer;
            var _local_25:Sprite;
            var _local_26:Graphics;
            var _local_27:Boolean;
            var _local_28:String;
            if (this.showHeaders)
            {
                this.header.visible = true;
                this.header.x = (contentPadding - _horizontalScrollPosition);
                this.header.y = contentPadding;
                listHolder.y = (contentPadding + this.headerHeight);
                _local_18 = Math.floor((availableHeight - this.headerHeight));
                _verticalScrollBar.setScrollProperties(_local_18, 0, (contentHeight - _local_18), _verticalScrollBar.pageScrollSize);
            }
            else
            {
                this.header.visible = false;
                listHolder.y = contentPadding;
            };
            listHolder.x = contentPadding;
            contentScrollRect = listHolder.scrollRect;
            contentScrollRect.x = _horizontalScrollPosition;
            contentScrollRect.y = (vOffset + (Math.floor(_verticalScrollPosition) % this.rowHeight));
            listHolder.scrollRect = contentScrollRect;
            listHolder.cacheAsBitmap = useBitmapScrolling;
            var _local_1:uint = uint(Math.min(Math.max((length - 1), 0), Math.floor((_verticalScrollPosition / this.rowHeight))));
            var _local_2:uint = Math.min(Math.max((length - 1), 0), ((_local_1 + this.rowCount) + 1));
            var _local_10:Boolean = list.hitTestPoint(stage.mouseX, stage.mouseY);
            this.calculateColumnSizes();
            var _local_11:Dictionary = (renderedItems = new Dictionary(true));
            if (length > 0)
            {
                _local_5 = _local_1;
                while (_local_5 <= _local_2)
                {
                    _local_11[_dataProvider.getItemAt(_local_5)] = true;
                    _local_5++;
                };
            };
            _local_3 = 0;
            var _local_12:DataGridColumn = (this.visibleColumns[0] as DataGridColumn);
            _local_5 = 0;
            while (_local_5 < this.displayableColumns.length)
            {
                _local_19 = (this.displayableColumns[_local_5] as DataGridColumn);
                if (_local_19 != _local_12)
                {
                    _local_3 = (_local_3 + _local_19.width);
                }
                else
                {
                    break;
                };
                _local_5++;
            };
            while (this.header.numChildren > 0)
            {
                this.header.removeChildAt(0);
            };
            this.dragHandlesMap = new Dictionary(true);
            var _local_15:Array = [];
            var _local_16:uint = this.visibleColumns.length;
            var _local_17:uint;
            while (_local_17 < _local_16)
            {
                _local_9 = (this.visibleColumns[_local_17] as DataGridColumn);
                _local_15.push(_local_9.colNum);
                if (this.showHeaders)
                {
                    _local_23 = ((_local_9.headerRenderer != null) ? _local_9.headerRenderer : this._headerRenderer);
                    _local_24 = (getDisplayObjectInstance(_local_23) as HeaderRenderer);
                    if (_local_24 != null)
                    {
                        _local_24.addEventListener(MouseEvent.CLICK, this.handleHeaderRendererClick, false, 0, true);
                        _local_24.x = _local_3;
                        _local_24.y = 0;
                        _local_24.setSize(_local_9.width, this.headerHeight);
                        _local_24.column = _local_9.colNum;
                        _local_24.label = _local_9.headerText;
                        this.header.addChildAt(_local_24, _local_17);
                        copyStylesToChild(_local_24, HEADER_STYLES);
                        if ((((this.sortIndex == -1) && (this.lastSortIndex == -1)) || (!(_local_9.colNum == this.sortIndex))))
                        {
                            _local_24.setStyle("icon", null);
                        }
                        else
                        {
                            _local_24.setStyle("icon", ((this.sortDescending) ? getStyleValue("headerSortArrowAscSkin") : getStyleValue("headerSortArrowDescSkin")));
                        };
                        if ((((_local_17 < (_local_16 - 1)) && (this.resizableColumns)) && (_local_9.resizable)))
                        {
                            _local_25 = new Sprite();
                            _local_26 = _local_25.graphics;
                            _local_26.beginFill(0, 0);
                            _local_26.drawRect(0, 0, 3, this.headerHeight);
                            _local_26.endFill();
                            _local_25.x = ((_local_3 + _local_9.width) - 2);
                            _local_25.y = 0;
                            _local_25.alpha = 0;
                            _local_25.addEventListener(MouseEvent.MOUSE_OVER, this.handleHeaderResizeOver, false, 0, true);
                            _local_25.addEventListener(MouseEvent.MOUSE_OUT, this.handleHeaderResizeOut, false, 0, true);
                            _local_25.addEventListener(MouseEvent.MOUSE_DOWN, this.handleHeaderResizeDown, false, 0, true);
                            this.header.addChild(_local_25);
                            this.dragHandlesMap[_local_25] = _local_9.colNum;
                        };
                        if ((((_local_17 == (_local_16 - 1)) && (_horizontalScrollPosition == 0)) && (availableWidth > (_local_3 + _local_9.width))))
                        {
                            _local_4 = Math.floor((availableWidth - _local_3));
                            _local_24.setSize(_local_4, this.headerHeight);
                        }
                        else
                        {
                            _local_4 = _local_9.width;
                        };
                        _local_24.drawNow();
                    };
                };
                _local_20 = ((_local_9.cellRenderer != null) ? _local_9.cellRenderer : this._cellRenderer);
                _local_21 = this.availableCellRenderersMap[_local_9];
                _local_8 = this.activeCellRenderersMap[_local_9];
                if (_local_8 == null)
                {
                    this.activeCellRenderersMap[_local_9] = (_local_8 = []);
                };
                if (_local_21 == null)
                {
                    this.availableCellRenderersMap[_local_9] = (_local_21 = []);
                };
                _local_22 = new Dictionary(true);
                while (_local_8.length > 0)
                {
                    _local_7 = _local_8.pop();
                    _local_6 = _local_7.data;
                    if (((_local_11[_local_6] == null) || (invalidItems[_local_6] == true)))
                    {
                        _local_21.push(_local_7);
                    }
                    else
                    {
                        _local_22[_local_6] = _local_7;
                        invalidItems[_local_6] = true;
                    };
                    list.removeChild((_local_7 as DisplayObject));
                };
                if (length > 0)
                {
                    _local_5 = _local_1;
                    while (_local_5 <= _local_2)
                    {
                        _local_27 = false;
                        _local_6 = _dataProvider.getItemAt(_local_5);
                        if (_local_22[_local_6] != null)
                        {
                            _local_27 = true;
                            _local_7 = _local_22[_local_6];
                            delete _local_22[_local_6];
                        }
                        else
                        {
                            if (_local_21.length > 0)
                            {
                                _local_7 = (_local_21.pop() as ICellRenderer);
                            }
                            else
                            {
                                _local_7 = (getDisplayObjectInstance(_local_20) as ICellRenderer);
                                _local_13 = (_local_7 as Sprite);
                                if (_local_13 != null)
                                {
                                    _local_13.addEventListener(MouseEvent.CLICK, this.handleCellRendererClick, false, 0, true);
                                    _local_13.addEventListener(MouseEvent.ROLL_OVER, this.handleCellRendererMouseEvent, false, 0, true);
                                    _local_13.addEventListener(MouseEvent.ROLL_OUT, this.handleCellRendererMouseEvent, false, 0, true);
                                    _local_13.addEventListener(Event.CHANGE, handleCellRendererChange, false, 0, true);
                                    _local_13.doubleClickEnabled = true;
                                    _local_13.addEventListener(MouseEvent.DOUBLE_CLICK, handleCellRendererDoubleClick, false, 0, true);
                                    if (_local_13["setStyle"] != null)
                                    {
                                        for (_local_28 in rendererStyles)
                                        {
                                            var _local_31:* = _local_13;
                                            (_local_31["setStyle"](_local_28, rendererStyles[_local_28]));
                                        };
                                    };
                                };
                            };
                        };
                        list.addChild((_local_7 as Sprite));
                        _local_8.push(_local_7);
                        _local_7.x = _local_3;
                        _local_7.y = (this.rowHeight * (_local_5 - _local_1));
                        _local_7.setSize(((_local_17 == (_local_16 - 1)) ? _local_4 : _local_9.width), this.rowHeight);
                        if ((!(_local_27)))
                        {
                            _local_7.data = _local_6;
                        };
                        _local_7.listData = new ListData(this.columnItemToLabel(_local_9.colNum, _local_6), null, this, _local_5, _local_5, _local_9.colNum);
                        if (((_local_10) && (this.isHovered(_local_7))))
                        {
                            _local_7.setMouseState("over");
                            this.currentHoveredRow = _local_5;
                        }
                        else
                        {
                            _local_7.setMouseState("up");
                        };
                        _local_7.selected = (!(_selectedIndices.indexOf(_local_5) == -1));
                        if ((_local_7 is UIComponent))
                        {
                            _local_14 = (_local_7 as UIComponent);
                            _local_14.drawNow();
                        };
                        _local_5++;
                    };
                };
                _local_3 = (_local_3 + _local_9.width);
                _local_17++;
            };
            _local_5 = 0;
            while (_local_5 < this._columns.length)
            {
                if (_local_15.indexOf(_local_5) == -1)
                {
                    this.removeCellRenderersByColumn((this._columns[_local_5] as DataGridColumn));
                };
                _local_5++;
            };
            if (this.editedItemPositionChanged)
            {
                this.editedItemPositionChanged = false;
                this.commitEditedItemPosition(this.proposedEditedItemPosition);
                this.proposedEditedItemPosition = undefined;
            };
            invalidItems = new Dictionary(true);
        }

        override protected function updateRendererStyles():void
        {
            var _local_2:Object;
            var _local_3:uint;
            var _local_4:uint;
            var _local_5:String;
            var _local_1:Array = [];
            for (_local_2 in this.availableCellRenderersMap)
            {
                _local_1 = _local_1.concat(this.availableCellRenderersMap[_local_2]);
            };
            for (_local_2 in this.activeCellRenderersMap)
            {
                _local_1 = _local_1.concat(this.activeCellRenderersMap[_local_2]);
            };
            _local_3 = _local_1.length;
            _local_4 = 0;
            while (_local_4 < _local_3)
            {
                if (_local_1[_local_4]["setStyle"] != null)
                {
                    for (_local_5 in updatedRendererStyles)
                    {
                        _local_1[_local_4].setStyle(_local_5, updatedRendererStyles[_local_5]);
                    };
                    _local_1[_local_4].drawNow();
                };
                _local_4++;
            };
            updatedRendererStyles = {};
        }

        protected function removeCellRenderers():void
        {
            var _local_1:uint;
            while (_local_1 < this._columns.length)
            {
                this.removeCellRenderersByColumn((this._columns[_local_1] as DataGridColumn));
                _local_1++;
            };
        }

        protected function removeCellRenderersByColumn(_arg_1:DataGridColumn):void
        {
            if (_arg_1 == null)
            {
                return;
            };
            var _local_2:Array = this.activeCellRenderersMap[_arg_1];
            if (_local_2 != null)
            {
                while (_local_2.length > 0)
                {
                    list.removeChild((_local_2.pop() as DisplayObject));
                };
            };
        }

        override protected function handleCellRendererMouseEvent(_arg_1:MouseEvent):void
        {
            var _local_3:int;
            var _local_4:String;
            var _local_5:uint;
            var _local_6:DataGridColumn;
            var _local_7:ICellRenderer;
            var _local_2:ICellRenderer = (_arg_1.target as ICellRenderer);
            if (_local_2)
            {
                _local_3 = _local_2.listData.row;
                if (_arg_1.type == MouseEvent.ROLL_OVER)
                {
                    _local_4 = "over";
                }
                else
                {
                    if (_arg_1.type == MouseEvent.ROLL_OUT)
                    {
                        _local_4 = "up";
                    };
                };
                if (_local_4)
                {
                    _local_5 = 0;
                    while (_local_5 < this.visibleColumns.length)
                    {
                        _local_6 = (this.visibleColumns[_local_5] as DataGridColumn);
                        _local_7 = this.getCellRendererAt(_local_3, _local_6.colNum);
                        if (_local_7)
                        {
                            _local_7.setMouseState(_local_4);
                        };
                        if (_local_3 != this.currentHoveredRow)
                        {
                            _local_7 = this.getCellRendererAt(this.currentHoveredRow, _local_6.colNum);
                            if (_local_7)
                            {
                                _local_7.setMouseState("up");
                            };
                        };
                        _local_5++;
                    };
                };
            };
            super.handleCellRendererMouseEvent(_arg_1);
        }

        protected function isHovered(_arg_1:ICellRenderer):Boolean
        {
            var _local_2:uint = uint(Math.min(Math.max((length - 1), 0), Math.floor((_verticalScrollPosition / this.rowHeight))));
            var _local_3:Number = ((_arg_1.listData.row - _local_2) * this.rowHeight);
            var _local_4:Point = list.globalToLocal(new Point(0, stage.mouseY));
            return ((_local_4.y > _local_3) && (_local_4.y < (_local_3 + this.rowHeight)));
        }

        override protected function setHorizontalScrollPosition(_arg_1:Number, _arg_2:Boolean=false):void
        {
            if (_arg_1 == _horizontalScrollPosition)
            {
                return;
            };
            contentScrollRect = listHolder.scrollRect;
            contentScrollRect.x = _arg_1;
            listHolder.scrollRect = contentScrollRect;
            list.x = 0;
            this.header.x = -(_arg_1);
            super.setHorizontalScrollPosition(_arg_1, true);
            invalidate(InvalidationType.SCROLL);
            this.columnsInvalid = true;
        }

        override protected function setVerticalScrollPosition(_arg_1:Number, _arg_2:Boolean=false):void
        {
            if (this.itemEditorInstance)
            {
                this.endEdit(DataGridEventReason.OTHER);
            };
            invalidate(InvalidationType.SCROLL);
            super.setVerticalScrollPosition(_arg_1, true);
        }

        public function columnItemToLabel(_arg_1:uint, _arg_2:Object):String
        {
            var _local_3:DataGridColumn = (this._columns[_arg_1] as DataGridColumn);
            if (_local_3 != null)
            {
                return (_local_3.itemToLabel(_arg_2));
            };
            return (" ");
        }

        protected function calculateColumnSizes():void
        {
            var _local_1:Number;
            var _local_2:int;
            var _local_3:int;
            var _local_5:DataGridColumn;
            var _local_6:DataGridColumn;
            var _local_7:Number;
            var _local_8:int;
            var _local_9:Number;
            var _local_10:int;
            var _local_11:Number;
            var _local_12:Number;
            var _local_13:Number;
            var _local_14:Number;
            var _local_4:Number = 0;
            if (this._columns.length == 0)
            {
                this.visibleColumns = [];
                this.displayableColumns = [];
                return;
            };
            if (this.columnsInvalid)
            {
                this.columnsInvalid = false;
                this.visibleColumns = [];
                if (this.minColumnWidthInvalid)
                {
                    _local_2 = this._columns.length;
                    _local_3 = 0;
                    while (_local_3 < _local_2)
                    {
                        this._columns[_local_3].minWidth = this.minColumnWidth;
                        _local_3++;
                    };
                    this.minColumnWidthInvalid = false;
                };
                this.displayableColumns = null;
                _local_2 = this._columns.length;
                _local_3 = 0;
                while (_local_3 < _local_2)
                {
                    if (((this.displayableColumns) && (this._columns[_local_3].visible)))
                    {
                        this.displayableColumns.push(this._columns[_local_3]);
                    }
                    else
                    {
                        if (((!(this.displayableColumns)) && (!(this._columns[_local_3].visible))))
                        {
                            this.displayableColumns = new Array(_local_3);
                            _local_8 = 0;
                            while (_local_8 < _local_3)
                            {
                                this.displayableColumns[_local_8] = this._columns[_local_8];
                                _local_8++;
                            };
                        };
                    };
                    _local_3++;
                };
                if ((!(this.displayableColumns)))
                {
                    this.displayableColumns = this._columns;
                };
                if (this.horizontalScrollPolicy == ScrollPolicy.OFF)
                {
                    _local_2 = this.displayableColumns.length;
                    _local_3 = 0;
                    while (_local_3 < _local_2)
                    {
                        this.visibleColumns.push(this.displayableColumns[_local_3]);
                        _local_3++;
                    };
                }
                else
                {
                    _local_2 = this.displayableColumns.length;
                    _local_9 = 0;
                    _local_3 = 0;
                    while (_local_3 < _local_2)
                    {
                        _local_5 = (this.displayableColumns[_local_3] as DataGridColumn);
                        if ((((_local_9 + _local_5.width) > _horizontalScrollPosition) && (_local_9 < (_horizontalScrollPosition + availableWidth))))
                        {
                            this.visibleColumns.push(_local_5);
                        };
                        _local_9 = (_local_9 + _local_5.width);
                        _local_3++;
                    };
                };
            };
            if (this.horizontalScrollPolicy == ScrollPolicy.OFF)
            {
                _local_10 = 0;
                _local_11 = 0;
                _local_2 = this.visibleColumns.length;
                _local_3 = 0;
                while (_local_3 < _local_2)
                {
                    _local_5 = (this.visibleColumns[_local_3] as DataGridColumn);
                    if (_local_5.resizable)
                    {
                        if ((!(isNaN(_local_5.explicitWidth))))
                        {
                            _local_11 = (_local_11 + _local_5.width);
                        }
                        else
                        {
                            _local_10++;
                            _local_11 = (_local_11 + _local_5.minWidth);
                        };
                    }
                    else
                    {
                        _local_11 = (_local_11 + _local_5.width);
                    };
                    _local_4 = (_local_4 + _local_5.width);
                    _local_3++;
                };
                _local_13 = availableWidth;
                if (((availableWidth > _local_11) && (_local_10)))
                {
                    _local_2 = this.visibleColumns.length;
                    _local_3 = 0;
                    while (_local_3 < _local_2)
                    {
                        _local_5 = (this.visibleColumns[_local_3] as DataGridColumn);
                        if (((_local_5.resizable) && (isNaN(_local_5.explicitWidth))))
                        {
                            _local_6 = _local_5;
                            if (_local_4 > availableWidth)
                            {
                                _local_12 = ((_local_6.width - _local_6.minWidth) / (_local_4 - _local_11));
                            }
                            else
                            {
                                _local_12 = (_local_6.width / _local_4);
                            };
                            _local_7 = (_local_6.width - ((_local_4 - availableWidth) * _local_12));
                            _local_14 = _local_5.minWidth;
                            _local_5.setWidth(Math.max(_local_7, _local_14));
                        };
                        _local_13 = (_local_13 - _local_5.width);
                        _local_3++;
                    };
                    if (((_local_13) && (_local_6)))
                    {
                        _local_6.setWidth((_local_6.width + _local_13));
                    };
                }
                else
                {
                    _local_2 = this.visibleColumns.length;
                    _local_3 = 0;
                    while (_local_3 < _local_2)
                    {
                        _local_6 = (this.visibleColumns[_local_3] as DataGridColumn);
                        _local_12 = (_local_6.width / _local_4);
                        _local_7 = (availableWidth * _local_12);
                        _local_6.setWidth(_local_7);
                        _local_6.explicitWidth = NaN;
                        _local_13 = (_local_13 - _local_7);
                        _local_3++;
                    };
                    if (((_local_13) && (_local_6)))
                    {
                        _local_6.setWidth((_local_6.width + _local_13));
                    };
                };
            };
        }

        override protected function calculateContentWidth():void
        {
            var _local_1:int;
            var _local_2:int;
            var _local_3:DataGridColumn;
            if (this._columns.length == 0)
            {
                contentWidth = 0;
                return;
            };
            if (this.minColumnWidthInvalid)
            {
                _local_1 = this._columns.length;
                _local_2 = 0;
                while (_local_2 < _local_1)
                {
                    _local_3 = (this._columns[_local_2] as DataGridColumn);
                    _local_3.minWidth = this.minColumnWidth;
                    _local_2++;
                };
                this.minColumnWidthInvalid = false;
            };
            if (this.horizontalScrollPolicy == ScrollPolicy.OFF)
            {
                contentWidth = availableWidth;
            }
            else
            {
                contentWidth = 0;
                _local_1 = this._columns.length;
                _local_2 = 0;
                while (_local_2 < _local_1)
                {
                    _local_3 = (this._columns[_local_2] as DataGridColumn);
                    if (_local_3.visible)
                    {
                        contentWidth = (contentWidth + _local_3.width);
                    };
                    _local_2++;
                };
                if (((!(isNaN(_horizontalScrollPosition))) && ((_horizontalScrollPosition + availableWidth) > contentWidth)))
                {
                    this.setHorizontalScrollPosition((contentWidth - availableWidth));
                };
            };
        }

        protected function handleHeaderRendererClick(_arg_1:MouseEvent):void
        {
            var _local_5:uint;
            var _local_6:DataGridEvent;
            if ((!(_enabled)))
            {
                return;
            };
            var _local_2:HeaderRenderer = (_arg_1.currentTarget as HeaderRenderer);
            var _local_3:uint = _local_2.column;
            var _local_4:DataGridColumn = (this._columns[_local_3] as DataGridColumn);
            if (((this.sortableColumns) && (_local_4.sortable)))
            {
                _local_5 = this._sortIndex;
                this._sortIndex = _local_3;
                _local_6 = new DataGridEvent(DataGridEvent.HEADER_RELEASE, false, true, _local_3, -1, _local_2, ((_local_4) ? _local_4.dataField : null));
                if (((!(dispatchEvent(_local_6))) || (!(_selectable))))
                {
                    this._sortIndex = this.lastSortIndex;
                    return;
                };
                this.lastSortIndex = _local_5;
                this.sortByColumn(_local_3);
                invalidate(InvalidationType.DATA);
            };
        }

        public function resizeColumn(_arg_1:int, _arg_2:Number):void
        {
            var _local_4:int;
            var _local_5:Number;
            var _local_6:int;
            var _local_7:DataGridColumn;
            var _local_8:DataGridColumn;
            var _local_9:int;
            var _local_10:Number;
            var _local_11:Number;
            var _local_12:Number;
            if (this._columns.length == 0)
            {
                return;
            };
            var _local_3:DataGridColumn = (this._columns[_arg_1] as DataGridColumn);
            if ((!(_local_3)))
            {
                return;
            };
            if (((!(this.visibleColumns)) || (this.visibleColumns.length == 0)))
            {
                _local_3.setWidth(_arg_2);
                return;
            };
            if (_arg_2 < _local_3.minWidth)
            {
                _arg_2 = _local_3.minWidth;
            };
            if (((_horizontalScrollPolicy == ScrollPolicy.ON) || (_horizontalScrollPolicy == ScrollPolicy.AUTO)))
            {
                _local_3.setWidth(_arg_2);
                _local_3.explicitWidth = _arg_2;
            }
            else
            {
                _local_4 = this.getVisibleColumnIndex(_local_3);
                if (_local_4 != -1)
                {
                    _local_5 = 0;
                    _local_6 = this.visibleColumns.length;
                    _local_9 = (_local_4 + 1);
                    while (_local_9 < _local_6)
                    {
                        _local_7 = (this.visibleColumns[_local_9] as DataGridColumn);
                        if (((_local_7) && (_local_7.resizable)))
                        {
                            _local_5 = (_local_5 + _local_7.width);
                        };
                        _local_9++;
                    };
                    _local_11 = ((_local_3.width - _arg_2) + _local_5);
                    if (_local_5)
                    {
                        _local_3.setWidth(_arg_2);
                        _local_3.explicitWidth = _arg_2;
                    };
                    _local_12 = 0;
                    _local_9 = (_local_4 + 1);
                    while (_local_9 < _local_6)
                    {
                        _local_7 = (this.visibleColumns[_local_9] as DataGridColumn);
                        if (_local_7.resizable)
                        {
                            _local_10 = ((_local_7.width * _local_11) / _local_5);
                            if (_local_10 < _local_7.minWidth)
                            {
                                _local_10 = _local_7.minWidth;
                            };
                            _local_7.setWidth(_local_10);
                            _local_12 = (_local_12 + _local_7.width);
                            _local_8 = _local_7;
                        };
                        _local_9++;
                    };
                    if (_local_12 > _local_11)
                    {
                        _local_10 = ((_local_3.width - _local_12) + _local_11);
                        if (_local_10 < _local_3.minWidth)
                        {
                            _local_10 = _local_3.minWidth;
                        };
                        _local_3.setWidth(_local_10);
                    }
                    else
                    {
                        if (_local_8)
                        {
                            _local_8.setWidth(((_local_8.width - _local_12) + _local_11));
                        };
                    };
                }
                else
                {
                    _local_3.setWidth(_arg_2);
                    _local_3.explicitWidth = _arg_2;
                };
            };
            this.columnsInvalid = true;
            invalidate(InvalidationType.SIZE);
        }

        protected function sortByColumn(_arg_1:int):void
        {
            var _local_2:DataGridColumn = (this.columns[_arg_1] as DataGridColumn);
            if ((((!(enabled)) || (!(_local_2))) || (!(_local_2.sortable))))
            {
                return;
            };
            var _local_3:Boolean = _local_2.sortDescending;
            var _local_4:uint = _local_2.sortOptions;
            if (_local_3)
            {
                _local_4 = (_local_4 | Array.DESCENDING);
            }
            else
            {
                _local_4 = (_local_4 & (~(Array.DESCENDING)));
            };
            if (_local_2.sortCompareFunction != null)
            {
                sortItems(_local_2.sortCompareFunction, _local_4);
            }
            else
            {
                sortItemsOn(_local_2.dataField, _local_4);
            };
            this._sortDescending = (_local_2.sortDescending = (!(_local_3)));
            if (((this.lastSortIndex >= 0) && (!(this.lastSortIndex == this.sortIndex))))
            {
                _local_2 = (this.columns[this.lastSortIndex] as DataGridColumn);
                if (_local_2 != null)
                {
                    _local_2.sortDescending = false;
                };
            };
        }

        protected function createColumnsFromDataProvider():void
        {
            var _local_1:Object;
            var _local_2:String;
            this._columns = [];
            if (length > 0)
            {
                _local_1 = _dataProvider.getItemAt(0);
                for (_local_2 in _local_1)
                {
                    this.addColumn(_local_2);
                };
            };
        }

        protected function getVisibleColumnIndex(_arg_1:DataGridColumn):int
        {
            var _local_2:uint;
            while (_local_2 < this.visibleColumns.length)
            {
                if (_arg_1 == this.visibleColumns[_local_2])
                {
                    return (_local_2);
                };
                _local_2++;
            };
            return (-1);
        }

        protected function handleHeaderResizeOver(_arg_1:MouseEvent):void
        {
            if (this.columnStretchIndex == -1)
            {
                this.showColumnStretchCursor();
            };
        }

        protected function handleHeaderResizeOut(_arg_1:MouseEvent):void
        {
            if (this.columnStretchIndex == -1)
            {
                this.showColumnStretchCursor(false);
            };
        }

        protected function handleHeaderResizeDown(_arg_1:MouseEvent):void
        {
            var _local_2:Sprite = (_arg_1.currentTarget as Sprite);
            var _local_3:Number = this.dragHandlesMap[_local_2];
            var _local_4:DataGridColumn = this.getColumnAt(_local_3);
            this.columnStretchIndex = _local_3;
            this.columnStretchStartX = _arg_1.stageX;
            this.columnStretchStartWidth = _local_4.width;
            var _local_5:DisplayObjectContainer = focusManager.form;
            _local_5.addEventListener(MouseEvent.MOUSE_MOVE, this.handleHeaderResizeMove, false, 0, true);
            _local_5.addEventListener(MouseEvent.MOUSE_UP, this.handleHeaderResizeUp, false, 0, true);
        }

        protected function handleHeaderResizeMove(_arg_1:MouseEvent):void
        {
            var _local_2:Number = (_arg_1.stageX - this.columnStretchStartX);
            var _local_3:Number = (this.columnStretchStartWidth + _local_2);
            this.resizeColumn(this.columnStretchIndex, _local_3);
        }

        protected function handleHeaderResizeUp(_arg_1:MouseEvent):void
        {
            var _local_4:HeaderRenderer;
            var _local_2:Sprite = (_arg_1.currentTarget as Sprite);
            var _local_3:DataGridColumn = (this._columns[this.columnStretchIndex] as DataGridColumn);
            var _local_5:uint;
            while (_local_5 < this.header.numChildren)
            {
                _local_4 = (this.header.getChildAt(_local_5) as HeaderRenderer);
                if (((_local_4) && (_local_4.column == this.columnStretchIndex))) break;
                _local_5++;
            };
            var _local_6:DataGridEvent = new DataGridEvent(DataGridEvent.COLUMN_STRETCH, false, true, this.columnStretchIndex, -1, _local_4, ((_local_3) ? _local_3.dataField : null));
            dispatchEvent(_local_6);
            this.columnStretchIndex = -1;
            this.showColumnStretchCursor(false);
            var _local_7:DisplayObjectContainer = focusManager.form;
            _local_7.removeEventListener(MouseEvent.MOUSE_MOVE, this.handleHeaderResizeMove, false);
            _local_7.removeEventListener(MouseEvent.MOUSE_UP, this.handleHeaderResizeUp, false);
        }

        protected function showColumnStretchCursor(_arg_1:Boolean=true):void
        {
            var _local_3:Point;
            if (this.columnStretchCursor == null)
            {
                this.columnStretchCursor = (getDisplayObjectInstance(getStyleValue("columnStretchCursorSkin")) as Sprite);
                this.columnStretchCursor.mouseEnabled = false;
            };
            var _local_2:DisplayObjectContainer = focusManager.form;
            if (_arg_1)
            {
                Mouse.hide();
                _local_2.addChild(this.columnStretchCursor);
                _local_2.addEventListener(MouseEvent.MOUSE_MOVE, this.positionColumnStretchCursor, false, 0, true);
                _local_3 = _local_2.globalToLocal(new Point(stage.mouseX, stage.mouseY));
                this.columnStretchCursor.x = _local_3.x;
                this.columnStretchCursor.y = _local_3.y;
            }
            else
            {
                _local_2.removeEventListener(MouseEvent.MOUSE_MOVE, this.positionColumnStretchCursor, false);
                if (_local_2.contains(this.columnStretchCursor))
                {
                    _local_2.removeChild(this.columnStretchCursor);
                };
                Mouse.show();
            };
        }

        protected function positionColumnStretchCursor(_arg_1:MouseEvent):void
        {
            var _local_2:DisplayObjectContainer = focusManager.form;
            var _local_3:Point = _local_2.globalToLocal(new Point(_arg_1.stageX, _arg_1.stageY));
            this.columnStretchCursor.x = _local_3.x;
            this.columnStretchCursor.y = _local_3.y;
        }

        protected function setEditedItemPosition(_arg_1:Object):void
        {
            this.editedItemPositionChanged = true;
            this.proposedEditedItemPosition = _arg_1;
            if (((_arg_1) && (!(_arg_1.rowIndex == selectedIndex))))
            {
                selectedIndex = _arg_1.rowIndex;
            };
            invalidate(InvalidationType.DATA);
        }

        protected function commitEditedItemPosition(_arg_1:Object):void
        {
            var _local_4:String;
            var _local_5:int;
            if (((!(enabled)) || (!(this.editable))))
            {
                return;
            };
            if ((((((this.itemEditorInstance) && (_arg_1)) && (this.itemEditorInstance is IFocusManagerComponent)) && (this._editedItemPosition.rowIndex == _arg_1.rowIndex)) && (this._editedItemPosition.columnIndex == _arg_1.columnIndex)))
            {
                IFocusManagerComponent(this.itemEditorInstance).setFocus();
                return;
            };
            if (this.itemEditorInstance)
            {
                if ((!(_arg_1)))
                {
                    _local_4 = DataGridEventReason.OTHER;
                }
                else
                {
                    if (((!(this.editedItemPosition)) || (_arg_1.rowIndex == this.editedItemPosition.rowIndex)))
                    {
                        _local_4 = DataGridEventReason.NEW_COLUMN;
                    }
                    else
                    {
                        _local_4 = DataGridEventReason.NEW_ROW;
                    };
                };
                if (((!(this.endEdit(_local_4))) && (!(_local_4 == DataGridEventReason.OTHER))))
                {
                    return;
                };
            };
            this._editedItemPosition = _arg_1;
            if ((!(_arg_1)))
            {
                return;
            };
            this.actualRowIndex = _arg_1.rowIndex;
            this.actualColIndex = _arg_1.columnIndex;
            if (this.displayableColumns.length != this._columns.length)
            {
                _local_5 = 0;
                while (_local_5 < this.displayableColumns.length)
                {
                    if (this.displayableColumns[_local_5].colNum >= this.actualColIndex)
                    {
                        this.actualColIndex = this.displayableColumns[_local_5].colNum;
                        break;
                    };
                    _local_5++;
                };
                if (_local_5 == this.displayableColumns.length)
                {
                    this.actualColIndex = 0;
                };
            };
            this.scrollToPosition(this.actualRowIndex, this.actualColIndex);
            var _local_2:ICellRenderer = this.getCellRendererAt(this.actualRowIndex, this.actualColIndex);
            var _local_3:DataGridEvent = new DataGridEvent(DataGridEvent.ITEM_EDIT_BEGIN, false, true, this.actualColIndex, this.actualRowIndex, _local_2);
            dispatchEvent(_local_3);
            if (this.editedItemPositionChanged)
            {
                this.editedItemPositionChanged = false;
                this.commitEditedItemPosition(this.proposedEditedItemPosition);
                this.proposedEditedItemPosition = undefined;
            };
            if ((!(this.itemEditorInstance)))
            {
                this.commitEditedItemPosition(null);
            };
        }

        protected function itemEditorItemEditBeginningHandler(_arg_1:DataGridEvent):void
        {
            if ((!(_arg_1.isDefaultPrevented())))
            {
                this.setEditedItemPosition({
                    "columnIndex":_arg_1.columnIndex,
                    "rowIndex":uint(_arg_1.rowIndex)
                });
            }
            else
            {
                if ((!(this.itemEditorInstance)))
                {
                    this._editedItemPosition = null;
                    this.editable = false;
                    setFocus();
                    this.editable = true;
                };
            };
        }

        protected function itemEditorItemEditBeginHandler(_arg_1:DataGridEvent):void
        {
            var _local_2:IFocusManager;
            addEventListener(Event.DEACTIVATE, this.deactivateHandler, false, 0, true);
            if ((!(_arg_1.isDefaultPrevented())))
            {
                this.createItemEditor(_arg_1.columnIndex, uint(_arg_1.rowIndex));
                ICellRenderer(this.itemEditorInstance).listData = ICellRenderer(this.editedItemRenderer).listData;
                ICellRenderer(this.itemEditorInstance).data = this.editedItemRenderer.data;
                this.itemEditorInstance.imeMode = ((this.columns[_arg_1.columnIndex].imeMode == null) ? _imeMode : this.columns[_arg_1.columnIndex].imeMode);
                _local_2 = focusManager;
                if ((this.itemEditorInstance is IFocusManagerComponent))
                {
                    _local_2.setFocus(InteractiveObject(this.itemEditorInstance));
                };
                _local_2.defaultButtonEnabled = false;
                _arg_1 = new DataGridEvent(DataGridEvent.ITEM_FOCUS_IN, false, false, this._editedItemPosition.columnIndex, this._editedItemPosition.rowIndex, this.itemEditorInstance);
                dispatchEvent(_arg_1);
            };
        }

        protected function itemEditorItemEditEndHandler(_arg_1:DataGridEvent):void
        {
            var _local_2:Boolean;
            var _local_3:Object;
            var _local_4:String;
            var _local_5:Object;
            var _local_6:String;
            var _local_7:XML;
            var _local_8:IFocusManager;
            if ((!(_arg_1.isDefaultPrevented())))
            {
                _local_2 = false;
                if (((this.itemEditorInstance) && (!(_arg_1.reason == DataGridEventReason.CANCELLED))))
                {
                    _local_3 = this.itemEditorInstance[this._columns[_arg_1.columnIndex].editorDataField];
                    _local_4 = this._columns[_arg_1.columnIndex].dataField;
                    _local_5 = _arg_1.itemRenderer.data;
                    _local_6 = "";
                    for each (_local_7 in describeType(_local_5).variable)
                    {
                        if (_local_4 == _local_7.@name.toString())
                        {
                            _local_6 = _local_7.@type.toString();
                            break;
                        };
                    };
                    switch (_local_6)
                    {
                        case "String":
                            if ((!(_local_3 is String)))
                            {
                                _local_3 = _local_3.toString();
                            };
                            break;
                        case "uint":
                            if ((!(_local_3 is uint)))
                            {
                                _local_3 = uint(_local_3);
                            };
                            break;
                        case "int":
                            if ((!(_local_3 is int)))
                            {
                                _local_3 = int(_local_3);
                            };
                            break;
                        case "Number":
                            if ((!(_local_3 is Number)))
                            {
                                _local_3 = Number(_local_3);
                            };
                            break;
                    };
                    if (_local_5[_local_4] != _local_3)
                    {
                        _local_2 = true;
                        _local_5[_local_4] = _local_3;
                    };
                    _arg_1.itemRenderer.data = _local_5;
                };
            }
            else
            {
                if (_arg_1.reason != DataGridEventReason.OTHER)
                {
                    if (((this.itemEditorInstance) && (this._editedItemPosition)))
                    {
                        if (selectedIndex != this._editedItemPosition.rowIndex)
                        {
                            selectedIndex = this._editedItemPosition.rowIndex;
                        };
                        _local_8 = focusManager;
                        if ((this.itemEditorInstance is IFocusManagerComponent))
                        {
                            _local_8.setFocus(InteractiveObject(this.itemEditorInstance));
                        };
                    };
                };
            };
            if (((_arg_1.reason == DataGridEventReason.OTHER) || (!(_arg_1.isDefaultPrevented()))))
            {
                this.destroyItemEditor();
            };
        }

        override protected function focusInHandler(_arg_1:FocusEvent):void
        {
            var _local_2:Boolean;
            var _local_3:DataGridColumn;
            if (_arg_1.target != this)
            {
                return;
            };
            if (this.losingFocus)
            {
                this.losingFocus = false;
                return;
            };
            setIMEMode(true);
            super.focusInHandler(_arg_1);
            if (((this.editable) && (!(this.isPressed))))
            {
                _local_2 = (!(this.editedItemPosition == null));
                if ((!(this._editedItemPosition)))
                {
                    this._editedItemPosition = {
                        "rowIndex":0,
                        "columnIndex":0
                    };
                    while (this._editedItemPosition.columnIndex < this._columns.length)
                    {
                        _local_3 = (this._columns[this._editedItemPosition.columnIndex] as DataGridColumn);
                        if (((_local_3.editable) && (_local_3.visible)))
                        {
                            _local_2 = true;
                            break;
                        };
                        this._editedItemPosition.columnIndex++;
                    };
                };
                if (_local_2)
                {
                    this.setEditedItemPosition(this._editedItemPosition);
                };
            };
            if (this.editable)
            {
                addEventListener(FocusEvent.KEY_FOCUS_CHANGE, this.keyFocusChangeHandler);
                addEventListener(MouseEvent.MOUSE_DOWN, this.mouseFocusChangeHandler);
            };
        }

        override protected function focusOutHandler(_arg_1:FocusEvent):void
        {
            setIMEMode(false);
            if (_arg_1.target == this)
            {
                super.focusOutHandler(_arg_1);
            };
            if (((_arg_1.relatedObject == this) && (this.itemRendererContains(this.itemEditorInstance, DisplayObject(_arg_1.target)))))
            {
                return;
            };
            if (((_arg_1.relatedObject == null) && (this.itemRendererContains(this.editedItemRenderer, DisplayObject(_arg_1.target)))))
            {
                return;
            };
            if (((_arg_1.relatedObject == null) && (this.itemRendererContains(this.itemEditorInstance, DisplayObject(_arg_1.target)))))
            {
                return;
            };
            if (((this.itemEditorInstance) && ((!(_arg_1.relatedObject)) || (!(this.itemRendererContains(this.itemEditorInstance, _arg_1.relatedObject))))))
            {
                this.endEdit(DataGridEventReason.OTHER);
                removeEventListener(FocusEvent.KEY_FOCUS_CHANGE, this.keyFocusChangeHandler);
                removeEventListener(MouseEvent.MOUSE_DOWN, this.mouseFocusChangeHandler);
            };
        }

        protected function editorMouseDownHandler(_arg_1:MouseEvent):void
        {
            var _local_2:ICellRenderer;
            var _local_3:uint;
            if ((!(this.itemRendererContains(this.itemEditorInstance, DisplayObject(_arg_1.target)))))
            {
                if (((_arg_1.target is ICellRenderer) && (contains(DisplayObject(_arg_1.target)))))
                {
                    _local_2 = (_arg_1.target as ICellRenderer);
                    _local_3 = _local_2.listData.row;
                    if (this._editedItemPosition.rowIndex == _local_3)
                    {
                        this.endEdit(DataGridEventReason.NEW_COLUMN);
                    }
                    else
                    {
                        this.endEdit(DataGridEventReason.NEW_ROW);
                    };
                }
                else
                {
                    this.endEdit(DataGridEventReason.OTHER);
                };
            };
        }

        protected function editorKeyDownHandler(_arg_1:KeyboardEvent):void
        {
            if (_arg_1.keyCode == Keyboard.ESCAPE)
            {
                this.endEdit(DataGridEventReason.CANCELLED);
            }
            else
            {
                if (((_arg_1.ctrlKey) && (_arg_1.charCode == 46)))
                {
                    this.endEdit(DataGridEventReason.CANCELLED);
                }
                else
                {
                    if (((_arg_1.charCode == Keyboard.ENTER) && (!(_arg_1.keyCode == 229))))
                    {
                        if (this.endEdit(DataGridEventReason.NEW_ROW))
                        {
                            this.findNextEnterItemRenderer(_arg_1);
                        };
                    };
                };
            };
        }

        protected function findNextItemRenderer(_arg_1:Boolean):Boolean
        {
            var _local_7:String;
            var _local_8:DataGridEvent;
            if ((!(this._editedItemPosition)))
            {
                return (false);
            };
            if (this.proposedEditedItemPosition !== undefined)
            {
                return (false);
            };
            var _local_2:int = this._editedItemPosition.rowIndex;
            var _local_3:int = this._editedItemPosition.columnIndex;
            var _local_4:Boolean;
            var _local_5:int = ((_arg_1) ? -1 : 1);
            var _local_6:int = (length - 1);
            while ((!(_local_4)))
            {
                _local_3 = (_local_3 + _local_5);
                if (((_local_3 < 0) || (_local_3 >= this._columns.length)))
                {
                    _local_3 = ((_local_3 < 0) ? (this._columns.length - 1) : 0);
                    _local_2 = (_local_2 + _local_5);
                    if (((_local_2 < 0) || (_local_2 > _local_6)))
                    {
                        this.setEditedItemPosition(null);
                        this.losingFocus = true;
                        setFocus();
                        return (false);
                    };
                };
                if (((this._columns[_local_3].editable) && (this._columns[_local_3].visible)))
                {
                    _local_4 = true;
                    if (_local_2 == this._editedItemPosition.rowIndex)
                    {
                        _local_7 = DataGridEventReason.NEW_COLUMN;
                    }
                    else
                    {
                        _local_7 = DataGridEventReason.NEW_ROW;
                    };
                    if (((!(this.itemEditorInstance)) || (this.endEdit(_local_7))))
                    {
                        _local_8 = new DataGridEvent(DataGridEvent.ITEM_EDIT_BEGINNING, false, true, _local_3, _local_2);
                        _local_8.dataField = this._columns[_local_3].dataField;
                        dispatchEvent(_local_8);
                    };
                };
            };
            return (_local_4);
        }

        protected function findNextEnterItemRenderer(_arg_1:KeyboardEvent):void
        {
            if (this.proposedEditedItemPosition !== undefined)
            {
                return;
            };
            var _local_2:int = this._editedItemPosition.rowIndex;
            var _local_3:int = this._editedItemPosition.columnIndex;
            var _local_4:int = (this._editedItemPosition.rowIndex + ((_arg_1.shiftKey) ? -1 : 1));
            if (((_local_4 >= 0) && (_local_4 < length)))
            {
                _local_2 = _local_4;
            };
            var _local_5:DataGridEvent = new DataGridEvent(DataGridEvent.ITEM_EDIT_BEGINNING, false, true, _local_3, _local_2);
            _local_5.dataField = this._columns[_local_3].dataField;
            dispatchEvent(_local_5);
        }

        protected function mouseFocusChangeHandler(_arg_1:MouseEvent):void
        {
            if ((((this.itemEditorInstance) && (!(_arg_1.isDefaultPrevented()))) && (this.itemRendererContains(this.itemEditorInstance, DisplayObject(_arg_1.target)))))
            {
                _arg_1.preventDefault();
            };
        }

        protected function keyFocusChangeHandler(_arg_1:FocusEvent):void
        {
            if ((((_arg_1.keyCode == Keyboard.TAB) && (!(_arg_1.isDefaultPrevented()))) && (this.findNextItemRenderer(_arg_1.shiftKey))))
            {
                _arg_1.preventDefault();
            };
        }

        private function itemEditorFocusOutHandler(_arg_1:FocusEvent):void
        {
            if (((_arg_1.relatedObject) && (contains(_arg_1.relatedObject))))
            {
                return;
            };
            if ((!(_arg_1.relatedObject)))
            {
                return;
            };
            if (this.itemEditorInstance)
            {
                this.endEdit(DataGridEventReason.OTHER);
            };
        }

        protected function deactivateHandler(_arg_1:Event):void
        {
            if (this.itemEditorInstance)
            {
                this.endEdit(DataGridEventReason.OTHER);
                this.losingFocus = true;
                setFocus();
            };
        }

        protected function mouseDownHandler(_arg_1:MouseEvent):void
        {
            if (((!(enabled)) || (!(selectable))))
            {
                return;
            };
            this.isPressed = true;
        }

        protected function mouseUpHandler(_arg_1:MouseEvent):void
        {
            if (((!(enabled)) || (!(selectable))))
            {
                return;
            };
            this.isPressed = false;
        }

        override protected function handleCellRendererClick(_arg_1:MouseEvent):void
        {
            var _local_3:DataGridColumn;
            var _local_4:DataGridEvent;
            super.handleCellRendererClick(_arg_1);
            var _local_2:ICellRenderer = (_arg_1.currentTarget as ICellRenderer);
            if ((((_local_2) && (_local_2.data)) && (!(_local_2 == this.itemEditorInstance))))
            {
                _local_3 = (this._columns[_local_2.listData.column] as DataGridColumn);
                if ((((this.editable) && (_local_3)) && (_local_3.editable)))
                {
                    _local_4 = new DataGridEvent(DataGridEvent.ITEM_EDIT_BEGINNING, false, true, _local_2.listData.column, _local_2.listData.row, _local_2, _local_3.dataField);
                    dispatchEvent(_local_4);
                };
            };
        }

        public function createItemEditor(_arg_1:uint, _arg_2:uint):void
        {
            var _local_6:int;
            if (this.displayableColumns.length != this._columns.length)
            {
                _local_6 = 0;
                while (_local_6 < this.displayableColumns.length)
                {
                    if (this.displayableColumns[_local_6].colNum >= _arg_1)
                    {
                        _arg_1 = this.displayableColumns[_local_6].colNum;
                        break;
                    };
                    _local_6++;
                };
                if (_local_6 == this.displayableColumns.length)
                {
                    _arg_1 = 0;
                };
            };
            var _local_3:DataGridColumn = (this._columns[_arg_1] as DataGridColumn);
            var _local_4:ICellRenderer = this.getCellRendererAt(_arg_2, _arg_1);
            if ((!(this.itemEditorInstance)))
            {
                this.itemEditorInstance = getDisplayObjectInstance(_local_3.itemEditor);
                this.itemEditorInstance.tabEnabled = false;
                list.addChild(DisplayObject(this.itemEditorInstance));
            };
            list.setChildIndex(DisplayObject(this.itemEditorInstance), (list.numChildren - 1));
            var _local_5:Sprite = (_local_4 as Sprite);
            this.itemEditorInstance.visible = true;
            this.itemEditorInstance.move(_local_5.x, _local_5.y);
            this.itemEditorInstance.setSize(_local_3.width, this.rowHeight);
            this.itemEditorInstance.drawNow();
            DisplayObject(this.itemEditorInstance).addEventListener(FocusEvent.FOCUS_OUT, this.itemEditorFocusOutHandler);
            _local_5.visible = false;
            DisplayObject(this.itemEditorInstance).addEventListener(KeyboardEvent.KEY_DOWN, this.editorKeyDownHandler);
            focusManager.form.addEventListener(MouseEvent.MOUSE_DOWN, this.editorMouseDownHandler, true, 0, true);
        }

        public function destroyItemEditor():void
        {
            var _local_1:DataGridEvent;
            if (this.itemEditorInstance)
            {
                DisplayObject(this.itemEditorInstance).removeEventListener(KeyboardEvent.KEY_DOWN, this.editorKeyDownHandler);
                focusManager.form.removeEventListener(MouseEvent.MOUSE_DOWN, this.editorMouseDownHandler, true);
                _local_1 = new DataGridEvent(DataGridEvent.ITEM_FOCUS_OUT, false, false, this._editedItemPosition.columnIndex, this._editedItemPosition.rowIndex, this.itemEditorInstance);
                dispatchEvent(_local_1);
                if (((this.itemEditorInstance) && (this.itemEditorInstance is UIComponent)))
                {
                    UIComponent(this.itemEditorInstance).drawFocus(false);
                };
                list.removeChild(DisplayObject(this.itemEditorInstance));
                DisplayObject(this.editedItemRenderer).visible = true;
                this.itemEditorInstance = null;
            };
        }

        protected function endEdit(_arg_1:String):Boolean
        {
            if ((!(this.editedItemRenderer)))
            {
                return (true);
            };
            var _local_2:DataGridEvent = new DataGridEvent(DataGridEvent.ITEM_EDIT_END, false, true, this.editedItemPosition.columnIndex, this.editedItemPosition.rowIndex, this.editedItemRenderer, this._columns[this.editedItemPosition.columnIndex].dataField, _arg_1);
            dispatchEvent(_local_2);
            return (!(_local_2.isDefaultPrevented()));
        }

        public function getCellRendererAt(_arg_1:uint, _arg_2:uint):ICellRenderer
        {
            var _local_4:Array;
            var _local_5:uint;
            var _local_6:ICellRenderer;
            var _local_3:DataGridColumn = (this._columns[_arg_2] as DataGridColumn);
            if (_local_3 != null)
            {
                _local_4 = (this.activeCellRenderersMap[_local_3] as Array);
                if (_local_4 != null)
                {
                    _local_5 = 0;
                    while (_local_5 < _local_4.length)
                    {
                        _local_6 = (_local_4[_local_5] as ICellRenderer);
                        if (_local_6.listData.row == _arg_1)
                        {
                            return (_local_6);
                        };
                        _local_5++;
                    };
                };
            };
            return (null);
        }

        protected function itemRendererContains(_arg_1:Object, _arg_2:DisplayObject):Boolean
        {
            if ((((!(_arg_2)) || (!(_arg_1))) || (!(_arg_1 is DisplayObjectContainer))))
            {
                return (false);
            };
            return (DisplayObjectContainer(_arg_1).contains(_arg_2));
        }

        override protected function handleDataChange(_arg_1:DataChangeEvent):void
        {
            super.handleDataChange(_arg_1);
            if (this._columns == null)
            {
                this._columns = [];
            };
            if (this._columns.length == 0)
            {
                this.createColumnsFromDataProvider();
            };
        }

        override protected function keyDownHandler(_arg_1:KeyboardEvent):void
        {
            if (((!(selectable)) || (this.itemEditorInstance)))
            {
                return;
            };
            switch (_arg_1.keyCode)
            {
                case Keyboard.UP:
                case Keyboard.DOWN:
                case Keyboard.END:
                case Keyboard.HOME:
                case Keyboard.PAGE_UP:
                case Keyboard.PAGE_DOWN:
                    this.moveSelectionVertically(_arg_1.keyCode, ((_arg_1.shiftKey) && (_allowMultipleSelection)), ((_arg_1.ctrlKey) && (_allowMultipleSelection)));
                    break;
                case Keyboard.LEFT:
                case Keyboard.RIGHT:
                    this.moveSelectionHorizontally(_arg_1.keyCode, ((_arg_1.shiftKey) && (_allowMultipleSelection)), ((_arg_1.ctrlKey) && (_allowMultipleSelection)));
                    break;
                case Keyboard.SPACE:
                    if (caretIndex == -1)
                    {
                        caretIndex = 0;
                    };
                    this.scrollToIndex(caretIndex);
                    this.doKeySelection(caretIndex, _arg_1.shiftKey, _arg_1.ctrlKey);
                    break;
            };
            _arg_1.stopPropagation();
        }

        override protected function moveSelectionHorizontally(_arg_1:uint, _arg_2:Boolean, _arg_3:Boolean):void
        {
        }

        override protected function moveSelectionVertically(_arg_1:uint, _arg_2:Boolean, _arg_3:Boolean):void
        {
            var _local_4:int = int(Math.max(Math.floor((this.calculateAvailableHeight() / this.rowHeight)), 1));
            var _local_5:int = -1;
            var _local_6:int;
            switch (_arg_1)
            {
                case Keyboard.UP:
                    if (caretIndex > 0)
                    {
                        _local_5 = (caretIndex - 1);
                    };
                    break;
                case Keyboard.DOWN:
                    if (caretIndex < (length - 1))
                    {
                        _local_5 = (caretIndex + 1);
                    };
                    break;
                case Keyboard.PAGE_UP:
                    if (caretIndex > 0)
                    {
                        _local_5 = Math.max((caretIndex - _local_4), 0);
                    };
                    break;
                case Keyboard.PAGE_DOWN:
                    if (caretIndex < (length - 1))
                    {
                        _local_5 = Math.min((caretIndex + _local_4), (length - 1));
                    };
                    break;
                case Keyboard.HOME:
                    if (caretIndex > 0)
                    {
                        _local_5 = 0;
                    };
                    break;
                case Keyboard.END:
                    if (caretIndex < (length - 1))
                    {
                        _local_5 = (length - 1);
                    };
                    break;
            };
            if (_local_5 >= 0)
            {
                this.doKeySelection(_local_5, _arg_2, _arg_3);
                scrollToSelected();
            };
        }

        override public function scrollToIndex(_arg_1:int):void
        {
            var _local_4:Number;
            drawNow();
            var _local_2:int = int((Math.floor(((_verticalScrollPosition + availableHeight) / this.rowHeight)) - 1));
            var _local_3:int = int(Math.ceil((_verticalScrollPosition / this.rowHeight)));
            if (_arg_1 < _local_3)
            {
                verticalScrollPosition = (_arg_1 * this.rowHeight);
            }
            else
            {
                if (_arg_1 >= _local_2)
                {
                    _local_4 = (((_horizontalScrollPolicy == ScrollPolicy.ON) || ((_horizontalScrollPolicy == ScrollPolicy.AUTO) && (hScrollBar))) ? 15 : 0);
                    verticalScrollPosition = (((((_arg_1 + 1) * this.rowHeight) - availableHeight) + _local_4) + ((this.showHeaders) ? this.headerHeight : 0));
                };
            };
        }

        protected function scrollToPosition(_arg_1:int, _arg_2:int):void
        {
            var _local_5:uint;
            var _local_8:DataGridColumn;
            var _local_3:Number = verticalScrollPosition;
            var _local_4:Number = horizontalScrollPosition;
            this.scrollToIndex(_arg_1);
            var _local_6:Number = 0;
            var _local_7:DataGridColumn = (this._columns[_arg_2] as DataGridColumn);
            _local_5 = 0;
            while (_local_5 < this.displayableColumns.length)
            {
                _local_8 = (this.displayableColumns[_local_5] as DataGridColumn);
                if (_local_8 != _local_7)
                {
                    _local_6 = (_local_6 + _local_8.width);
                }
                else
                {
                    break;
                };
                _local_5++;
            };
            if (horizontalScrollPosition > _local_6)
            {
                horizontalScrollPosition = _local_6;
            }
            else
            {
                if ((horizontalScrollPosition + availableWidth) < (_local_6 + _local_7.width))
                {
                    horizontalScrollPosition = -(availableWidth - (_local_6 + _local_7.width));
                };
            };
            if (((!(_local_3 == verticalScrollPosition)) || (!(_local_4 == horizontalScrollPosition))))
            {
                drawNow();
            };
        }

        protected function doKeySelection(_arg_1:int, _arg_2:Boolean, _arg_3:Boolean):void
        {
            var _local_5:int;
            var _local_6:Array;
            var _local_7:int;
            var _local_8:int;
            var _local_4:Boolean;
            if (_arg_2)
            {
                _local_6 = [];
                _local_7 = lastCaretIndex;
                _local_8 = _arg_1;
                if (_local_7 == -1)
                {
                    _local_7 = ((!(caretIndex == -1)) ? caretIndex : _arg_1);
                };
                if (_local_7 > _local_8)
                {
                    _local_8 = _local_7;
                    _local_7 = _arg_1;
                };
                _local_5 = _local_7;
                while (_local_5 <= _local_8)
                {
                    _local_6.push(_local_5);
                    _local_5++;
                };
                selectedIndices = _local_6;
                caretIndex = _arg_1;
                _local_4 = true;
            }
            else
            {
                if (_arg_3)
                {
                    caretIndex = _arg_1;
                }
                else
                {
                    selectedIndex = _arg_1;
                    caretIndex = (lastCaretIndex = _arg_1);
                    _local_4 = true;
                };
            };
            if (_local_4)
            {
                dispatchEvent(new Event(Event.CHANGE));
            };
            invalidate(InvalidationType.DATA);
        }

        override protected function initializeAccessibility():void
        {
            if (DataGrid.createAccessibilityImplementation != null)
            {
                DataGrid.createAccessibilityImplementation(this);
            };
        }


    }
}//package fl.controls


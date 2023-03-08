// Decompiled by AS3 Sorcerer 6.30
// www.as3sorcerer.com

//com.mcleodgaming.ssf2.util.DisplayObjectTable

package com.mcleodgaming.ssf2.util
{
    import __AS3__.vec.Vector;
    import flash.display.DisplayObject;
    import flash.geom.Rectangle;
    import flash.display.MovieClip;
    import __AS3__.vec.*;

    public class DisplayObjectTable 
    {

        private var m_displayObjects:Vector.<Vector.<DisplayObject>>;
        private var m_spaceRect:Rectangle;

        public function DisplayObjectTable(spaceRect:Rectangle)
        {
            if (spaceRect == null)
            {
                trace("Error creating DisplayObjectTable, cannot have null spacing rectangle");
                return;
            };
            this.m_displayObjects = new Vector.<Vector.<DisplayObject>>();
            this.m_spaceRect = spaceRect;
        }

        public function get RowCount():int
        {
            return (this.m_displayObjects.length);
        }

        public function maxPerRow():int
        {
            var max:int;
            var i:int;
            while (i < this.m_displayObjects.length)
            {
                max = Math.max(max, this.m_displayObjects[i].length);
                i++;
            };
            return (max);
        }

        public function insertObject(rowIndex:int, object:DisplayObject):void
        {
            while (rowIndex >= this.m_displayObjects.length)
            {
                this.m_displayObjects.push(new Vector.<DisplayObject>());
            };
            this.m_displayObjects[rowIndex].push(object);
        }

        public function hideAll():void
        {
            var j:int;
            var i:int;
            while (i < this.m_displayObjects.length)
            {
                j = 0;
                while (j < this.m_displayObjects[i].length)
                {
                    this.m_displayObjects[i][j].visible = false;
                    j++;
                };
                i++;
            };
        }

        public function showAll():void
        {
            var j:int;
            var i:int;
            while (i < this.m_displayObjects.length)
            {
                j = 0;
                while (j < this.m_displayObjects[i].length)
                {
                    this.m_displayObjects[i][j].visible = true;
                    j++;
                };
                i++;
            };
        }

        public function scaleAll(scaleX:Number, scaleY:Number):void
        {
            var j:int;
            var i:int;
            while (i < this.m_displayObjects.length)
            {
                j = 0;
                while (j < this.m_displayObjects[i].length)
                {
                    this.m_displayObjects[i][j].scaleX = scaleX;
                    this.m_displayObjects[i][j].scaleY = scaleY;
                    j++;
                };
                i++;
            };
        }

        public function fixDepths():void
        {
            var j:int;
            var i:int = (this.m_displayObjects.length - 1);
            while (i >= 0)
            {
                j = (this.m_displayObjects[i].length - 1);
                while (j >= 0)
                {
                    if (((this.m_displayObjects[i][j].parent) && (this.m_displayObjects[i][j].parent as MovieClip)))
                    {
                        MovieClip(this.m_displayObjects[i][j].parent).setChildIndex(this.m_displayObjects[i][j], 0);
                    };
                    j--;
                };
                i--;
            };
        }

        public function spaceObjects():void
        {
            var shift:Number;
            var x_multiplier:Number;
            var diff:int;
            var i:int;
            var j:int;
            var y_multiplier:Number = 0;
            i = 0;
            while (i < this.m_displayObjects.length)
            {
                shift = 0;
                x_multiplier = 0;
                j = 0;
                while (j < this.m_displayObjects[i].length)
                {
                    if ((!(this.m_displayObjects[i][j].visible)))
                    {
                        shift = (shift + (this.m_spaceRect.width / 2));
                    };
                    j++;
                };
                diff = (this.maxPerRow() - this.m_displayObjects[i].length);
                shift = (shift + ((diff * this.m_spaceRect.width) / 2));
                j = 0;
                while (j < this.m_displayObjects[i].length)
                {
                    if (this.m_displayObjects[i][j].visible)
                    {
                        this.m_displayObjects[i][j].x = ((this.m_spaceRect.x + (this.m_spaceRect.width * x_multiplier)) + shift);
                        this.m_displayObjects[i][j].y = (this.m_spaceRect.y + (this.m_spaceRect.height * y_multiplier));
                        x_multiplier++;
                    };
                    j++;
                };
                y_multiplier++;
                i++;
            };
        }

        public function empty():void
        {
            this.m_displayObjects = new Vector.<Vector.<DisplayObject>>();
        }


    }
}//package com.mcleodgaming.ssf2.util


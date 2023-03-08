// Decompiled by AS3 Sorcerer 6.30
// www.as3sorcerer.com

//com.mcleodgaming.ssf2.util.VcamSettings

package com.mcleodgaming.ssf2.util
{
    import flash.display.MovieClip;
    import __AS3__.vec.Vector;
    import com.mcleodgaming.ssf2.Main;
    import __AS3__.vec.*;

    public class VcamSettings 
    {

        public var linkage_id:String;
        public var x_start:Number;
        public var y_start:Number;
        public var width:Number;
        public var height:Number;
        public var x_zoom:Number;
        public var y_zoom:Number;
        public var panSpeedCap:Number;
        public var camEaseFactor:Number;
        public var camZoomFactor:Number;
        public var minZoomHeight:Number;
        public var mainTerrain:MovieClip;
        public var zoomSpeedCap:Number;
        public var backgrounds:Vector.<VcamBGSettings>;

        public function VcamSettings(settings:Object=null):void
        {
            this.linkage_id = null;
            this.x_start = 0;
            this.y_start = 0;
            this.width = Main.Width;
            this.height = Main.Height;
            this.x_zoom = 0;
            this.y_zoom = 0;
            this.panSpeedCap = 50;
            this.camEaseFactor = 5.6;
            this.camZoomFactor = 8;
            this.mainTerrain = null;
            this.minZoomHeight = 200;
            this.zoomSpeedCap = 0;
            this.backgrounds = new Vector.<VcamBGSettings>();
            this.importSettings(settings);
            this.mainTerrain = ((this.mainTerrain) || (null));
        }

        public function importSettings(settings:Object):VcamSettings
        {
            var i:*;
            var bgArr:Array;
            var j:int;
            if (settings)
            {
                for (i in settings)
                {
                    if ((i in this))
                    {
                        if (i === "backgrounds")
                        {
                            bgArr = settings[i];
                            this.backgrounds = new Vector.<VcamBGSettings>();
                            j = 0;
                            while (j < bgArr.length)
                            {
                                this.backgrounds.push(new VcamBGSettings(bgArr[j].linkage_id, bgArr[j]));
                                j++;
                            };
                        }
                        else
                        {
                            this[i] = settings[i];
                        };
                    };
                };
            };
            return (this);
        }

        public function exportSettings():Object
        {
            var settings:Object = {
                "linkage_id":this.linkage_id,
                "x_start":this.x_start,
                "y_start":this.y_start,
                "width":this.width,
                "height":this.height,
                "x_zoom":this.x_zoom,
                "y_zoom":this.y_zoom,
                "panSpeedCap":this.panSpeedCap,
                "camEaseFactor":this.camEaseFactor,
                "camZoomFactor":this.camZoomFactor,
                "mainTerrain":this.mainTerrain,
                "minZoomHeight":this.minZoomHeight,
                "backgrounds":[]
            };
            var i:int;
            while (i < this.backgrounds.length)
            {
                settings.backgrounds.push(this.backgrounds[i].exportSettings());
                i++;
            };
            return (settings);
        }


    }
}//package com.mcleodgaming.ssf2.util


// Decompiled by AS3 Sorcerer 6.30
// www.as3sorcerer.com

//menu_preloader

package 
{
    import flash.display.MovieClip;
    import flash.display.SimpleButton;
    import flash.text.TextField;
    import flash.accessibility.*;
    import flash.display.*;
    import flash.errors.*;
    import flash.events.*;
    import flash.filters.*;
    import flash.geom.*;
    import flash.media.*;
    import flash.net.*;
    import flash.net.drm.*;
    import flash.system.*;
    import flash.text.*;
    import flash.text.ime.*;
    import flash.ui.*;
    import flash.utils.*;

    public dynamic class menu_preloader extends MovieClip 
    {

        public var masker:SimpleButton;
        public var pCent:TextField;
        public var progressBar:MovieClip;
        public var percentage:Number;

        public function menu_preloader()
        {
            addFrameScript(0, this.frame1);
        }

        internal function frame1():*
        {
            this.masker.useHandCursor = false;
            this.percentage = 0;
        }


    }
}//package 


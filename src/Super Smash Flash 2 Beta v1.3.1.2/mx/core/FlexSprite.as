// Decompiled by AS3 Sorcerer 6.30
// www.as3sorcerer.com

//mx.core.FlexSprite

package mx.core
{
    import flash.display.Sprite;
    import mx.utils.NameUtil;
    import mx.core.mx_internal; 

    use namespace mx_internal;

    public class FlexSprite extends Sprite 
    {

        mx_internal static const VERSION:String = "4.6.0.23201";

        public function FlexSprite()
        {
            try
            {
                name = NameUtil.createUniqueName(this);
            }
            catch(e:Error)
            {
            };
        }

        override public function toString():String
        {
            return (NameUtil.displayObjectToString(this));
        }


    }
}//package mx.core


// Decompiled by AS3 Sorcerer 6.30
// www.as3sorcerer.com

//com.mcleodgaming.ssf2.controllers.ItemSwitchHand

package com.mcleodgaming.ssf2.controllers
{
    import __AS3__.vec.Vector;
    import com.mcleodgaming.ssf2.util.ResourceManager;
    import flash.display.MovieClip;
    import flash.display.DisplayObject;
    import com.mcleodgaming.ssf2.util.*;
    import __AS3__.vec.*;

    public class ItemSwitchHand extends SelectHand 
    {

        public function ItemSwitchHand(targetMC:MovieClip, buttons:Vector.<ItemButton>, backFunc:Function)
        {
            var convertedButtons:Vector.<HandButton> = new Vector.<HandButton>();
            var i:int;
            while (i < buttons.length)
            {
                convertedButtons.push(buttons[i]);
                i++;
            };
            super(targetMC, convertedButtons, backFunc);
            var mappings:Object = ResourceManager.getResourceByID("mappings").getProp("metadata");
            var screen:Object = mappings.item_switch_screen;
            START_POSITION.x = screen.hand_start.x;
            START_POSITION.y = screen.hand_start.y;
            BOUNDS_RECT.x = screen.hand_bounds.x;
            BOUNDS_RECT.y = screen.hand_bounds.y;
            BOUNDS_RECT.width = screen.hand_bounds.width;
            BOUNDS_RECT.height = screen.hand_bounds.height;
            BOUNDS_RECT.x = -287;
            BOUNDS_RECT.y = -145;
            BOUNDS_RECT.width = 585;
            BOUNDS_RECT.height = 320;
            resetPosition();
        }

        override protected function checkBounds(mc:DisplayObject, coordinateSpaceOverride:DisplayObject=null):Boolean
        {
            return ((super.checkBounds(mc, coordinateSpaceOverride)) && (!(MovieClip(mc).disabled)));
        }


    }
}//package com.mcleodgaming.ssf2.controllers


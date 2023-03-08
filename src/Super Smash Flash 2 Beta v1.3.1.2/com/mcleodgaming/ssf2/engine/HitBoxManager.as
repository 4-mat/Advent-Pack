// Decompiled by AS3 Sorcerer 6.30
// www.as3sorcerer.com

//com.mcleodgaming.ssf2.engine.HitBoxManager

package com.mcleodgaming.ssf2.engine
{
    import __AS3__.vec.Vector;
    import flash.display.MovieClip;
    import com.mcleodgaming.ssf2.util.ResourceManager;
    import com.mcleodgaming.ssf2.util.Utils;
    import flash.desktop.Clipboard;
    import flash.desktop.ClipboardFormats;
    import __AS3__.vec.*;

    public class HitBoxManager 
    {

        private static var m_hitBoxManagerList:Object = {};

        private var m_name:String;
        private var m_hitBoxAnimationList:Vector.<HitBoxAnimation>;
        private var m_hitBoxAnimationIndexes:Array;
        private var m_hasHitBoxes:Boolean;

        public function HitBoxManager(name:String)
        {
            this.m_name = name;
            m_hitBoxManagerList[name] = this;
            this.m_hasHitBoxes = false;
            this.m_hitBoxAnimationList = new Vector.<HitBoxAnimation>();
            this.m_hitBoxAnimationIndexes = new Array();
        }

        public static function getOrCreate(linkageID:String):HitBoxManager
        {
            var hitBoxManager:HitBoxManager;
            var i:int;
            var j:int;
            var tmpMC:MovieClip;
            if (HitBoxManager.HitBoxManageList[linkageID] != null)
            {
                return (HitBoxManager.HitBoxManageList[linkageID]);
            };
            hitBoxManager = new HitBoxManager(linkageID);
            i = 0;
            j = 0;
            tmpMC = ResourceManager.getLibraryMC(linkageID);
            i = 0;
            while (((tmpMC) && (i < tmpMC.totalFrames)))
            {
                tmpMC.gotoAndStop((i + 1));
                if (tmpMC)
                {
                    if (tmpMC.stance)
                    {
                        Utils.removeActionScript(tmpMC.stance);
                        hitBoxManager.addHitBoxAnimation(HitBoxAnimation.createHitBoxAnimation(((linkageID + "_") + tmpMC.currentLabel), tmpMC.stance, tmpMC));
                    };
                };
                i++;
            };
            return (hitBoxManager);
        }

        public static function clearCache():void
        {
            m_hitBoxManagerList = {};
            HitBoxAnimation.AnimationsList.splice(0, HitBoxAnimation.AnimationsList.length);
        }

        public static function get HitBoxManageList():Object
        {
            return (m_hitBoxManagerList);
        }

        public static function dump():String
        {
            var i:*;
            var manager:HitBoxManager;
            var j:int;
            var k:int;
            var hitBoxes:Vector.<HitBoxSprite>;
            var l:int;
            var result:String = "";
            var hitBoxTypes:Vector.<Object> = HitBoxAnimation.HitBoxTypes;
            for (i in m_hitBoxManagerList)
            {
                result = (result + (("Manager " + i) + ":\r\n"));
                result = (result + "--------------------------------");
                manager = m_hitBoxManagerList[i];
                j = 0;
                while (j < manager.HitBoxAnimationList.length)
                {
                    result = (result + (("Animation " + manager.HitBoxAnimationList[j].Name) + ":\r\n"));
                    k = 0;
                    while (k < hitBoxTypes.length)
                    {
                        hitBoxes = manager.HitBoxAnimationList[j].getAllHitBoxesOfType(hitBoxTypes[k].type);
                        l = 0;
                        while (l < hitBoxes.length)
                        {
                            result = (result + (((("Hitbox { name:" + hitBoxTypes[k].name) + " rect: ") + hitBoxes[l].BoundingBox) + " }\r\n"));
                            l++;
                        };
                        k++;
                    };
                    j++;
                };
            };
            Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, result);
            return (result);
        }


        public function get HasHitBoxes():Boolean
        {
            return (this.m_hasHitBoxes);
        }

        public function get HitBoxAnimationList():Vector.<HitBoxAnimation>
        {
            return (this.m_hitBoxAnimationList);
        }

        public function addHitBoxAnimation(hitBoxAnimation:HitBoxAnimation):void
        {
            this.m_hitBoxAnimationList.push(hitBoxAnimation);
            this.m_hitBoxAnimationIndexes[hitBoxAnimation.Name] = (this.m_hitBoxAnimationList.length - 1);
            if (hitBoxAnimation.TotalHitboxes)
            {
                this.m_hasHitBoxes = true;
            };
        }

        public function getHitBoxAnimation(name:String):HitBoxAnimation
        {
            return ((this.m_hitBoxAnimationIndexes[name] !== undefined) ? this.m_hitBoxAnimationList[this.m_hitBoxAnimationIndexes[name]] : null);
        }


    }
}//package com.mcleodgaming.ssf2.engine


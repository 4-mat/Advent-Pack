// Decompiled by AS3 Sorcerer 6.30
// www.as3sorcerer.com

//com.mcleodgaming.ssf2.engine.HitBoxProcessor

package com.mcleodgaming.ssf2.engine
{
    import __AS3__.vec.Vector;
    import __AS3__.vec.*;

    public class HitBoxProcessor 
    {

        protected var m_reactions:Vector.<Vector.<HitBoxProcessorNode>> = new Vector.<Vector.<HitBoxProcessorNode>>();

        public function HitBoxProcessor()
        {
            this.m_reactions = new Vector.<Vector.<HitBoxProcessorNode>>();
        }

        public function process():void
        {
            var j:int;
            var i:int;
            while (i < this.m_reactions.length)
            {
                j = 0;
                while (j < this.m_reactions[i].length)
                {
                    this.m_reactions[i][j].run();
                    j++;
                };
                this.m_reactions[i].splice(0, this.m_reactions[i].length);
                i++;
            };
        }

        public function queue(node:HitBoxProcessorNode, priority:int):void
        {
            if (priority >= this.m_reactions.length)
            {
                while (priority >= this.m_reactions.length)
                {
                    this.m_reactions.push(new Vector.<HitBoxProcessorNode>());
                };
            };
            this.m_reactions[priority].push(node);
        }


    }
}//package com.mcleodgaming.ssf2.engine


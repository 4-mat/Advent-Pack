// Decompiled by AS3 Sorcerer 6.30
// www.as3sorcerer.com

//com.mcleodgaming.ssf2.util.Rndm

package com.mcleodgaming.ssf2.util
{
    public class Rndm 
    {

        public var seed:uint;

        public function Rndm()
        {
            this.seed = 1;
        }

        public function nextInt():uint
        {
            return (this.gen());
        }

        public function nextDouble():Number
        {
            return (this.gen() / 2147483647);
        }

        public function nextIntRange(min:Number, max:Number):uint
        {
            min = (min - 0.4999);
            max = (max + 0.4999);
            return (Math.round((min + ((max - min) * this.nextDouble()))));
        }

        public function nextDoubleRange(min:Number, max:Number):Number
        {
            return (min + ((max - min) * this.nextDouble()));
        }

        private function gen():uint
        {
            return (this.seed = ((this.seed * 16807) % 2147483647));
        }


    }
}//package com.mcleodgaming.ssf2.util


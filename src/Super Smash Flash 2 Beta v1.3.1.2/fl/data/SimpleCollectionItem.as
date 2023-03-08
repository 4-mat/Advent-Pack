// Decompiled by AS3 Sorcerer 6.30
// www.as3sorcerer.com

//fl.data.SimpleCollectionItem

package fl.data
{
    public dynamic class SimpleCollectionItem 
    {

        [Inspectable]
        public var label:String;
        [Inspectable]
        public var data:String;


        public function toString():String
        {
            return (((("[SimpleCollectionItem: " + this.label) + ",") + this.data) + "]");
        }


    }
}//package fl.data


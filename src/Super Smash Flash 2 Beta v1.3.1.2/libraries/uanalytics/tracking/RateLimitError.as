// Decompiled by AS3 Sorcerer 6.30
// www.as3sorcerer.com

//libraries.uanalytics.tracking.RateLimitError

package libraries.uanalytics.tracking
{
    public class RateLimitError extends Error 
    {

        {
            prototype.name = "RateLimitError";
        }

        public function RateLimitError(message:String="", id:int=0)
        {
            super(message, id);
            this.name = prototype.name;
        }

    }
}//package libraries.uanalytics.tracking


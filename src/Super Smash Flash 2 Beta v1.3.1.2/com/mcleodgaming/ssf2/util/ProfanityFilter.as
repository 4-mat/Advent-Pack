// Decompiled by AS3 Sorcerer 6.20
// www.as3sorcerer.com

//com.mcleodgaming.ssf2.util.ProfanityFilter

package com.mcleodgaming.ssf2.util
{
    public class ProfanityFilter 
    {

        private static const wordfilter:Class = ProfanityFilter_wordfilter;
        public static const wordfilterData:Object = {
  "words":["a\\$\\$","ash0le", "ash0les", "asholes", "Assface", "assh0le", "assh0lez", "asshole", "assholes", "assholz", "asswipe", "azzhole", "bassterds", "bastard", "bastards", "bastardz", "basterds", "basterdz", "Biatch", "bitch", "bitches", "boffing", "buttwipe", "bullshit", "c0ck", "c0cks", "c0k", "Carpet Muncher", "cawk", "cawks", "cock", "cockhead", "cock-head", "cocks", "CockSucker", "cock-sucker", "cum", "cunt", "cunts", "cuntz", "dick", "dyke", "f u c k", "f u c k e r", "fag", "faget", "faggit", "faggot", "fagit", "fags", "fagz", "faig", "faigs", "fuck", "fucker", "fuckin", "fucking", "fucks", "Fudge Packer", "fuk", "Fukah", "Fuken", "fuker", "Fukin", "Fukk", "Fukkah", "Fukken", "Fukker", "Fukkin", "gook", "g00k", "h00r", "h0ar", "h0re", "hoar", "hoor", "hoore", "jackoff", "japs", "jisim", "jiss", "jizm", "jizz", "kunt", "kunts", "kuntz", "Lesbian", "Lezzian", "massterbait", "masstrbait", "masstrbate", "masterbaiter", "masterbate", "masterbates", "nigger", "nigga", "nigur", "niger", "nigr", "Phuc", "Phuck", "Phuk", "Phuker", "Phukker", "pusse", "pussee", "pussy", "queer", "queers", "queerz", "qweers", "qweerz", "qweir", "scank", "semen", "shiter", "shitz", "shit", "shits", "shitter", "Shitty", "Shity", "Shyt", "Shyte", "Shytty", "Shyty", "skanck", "skank", "w0p", "wh00r", "wh0re", "whore", "bitch", "fuck", "shit", "asshole", "bi7ch", "bastard", "bi\\+ch", "boiolas", "buceta", "c0ck", "cawk", "chink", "cipa", "clits", "cock", "cum", "cunt", "dirsa", "ejakulate", "fatass", "fcuk", "fuk", "fux0r", "hoer", "hore", "jism", "kawk", "l3itch", "l3i\\+ch", "lesbian", "motherfucker", "nazi", "nigga", "nigger", "nutsack", "phuck", "pimpis", "pusse", "pussy", "shemale", "shi\\+", "slut", "smut", "teets", "boobs", "b00bs", "teez", "titty", "titties", "w00se", "whoar", "whore", "dyke", "fuck", "shit", "@\\$\\$", "amcik", "andskota", "assrammer", "charmuta", "sharmuta", "penis", "vagina"]
};
        private static var _instance:ProfanityFilter;

        private var list:Array;
        private var placeHolder:String;

        public function ProfanityFilter(options:*=null):void
        {
            options = ((options) || ({}));
            this.placeHolder = ((options.placeHolder) || ("***"));
            this.list = wordfilterData.words as Array;
            var i:int;
            while (i < this.list.length)
            {
                this.list[i] = this.list[i].replace(/i/gi, "(i|l|1|!|¡|\\|)+");
                i++;
            };
        }

        public static function get instance():ProfanityFilter
        {
            if (!_instance)
            {
                _instance = new (ProfanityFilter)();
            };
            return (_instance);
        }


        public function isProfane(text:String):Boolean
        {
            return ((this.clean(text)) ? true : false);
        }

        public function clean(text:String):String
        {
            var i:int;
            while (i < this.list.length)
            {
                text = text.replace(new RegExp(this.list[i], "ig"), this.placeHolder);
                i++;
            };
            return (text);
        }


    }
}//package com.mcleodgaming.ssf2.util


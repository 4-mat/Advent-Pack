// Decompiled by AS3 Sorcerer 6.30
// www.as3sorcerer.com

//com.mcleodgaming.ssf2.enemies.EnemyStats

package com.mcleodgaming.ssf2.enemies
{
    import com.mcleodgaming.ssf2.engine.InteractiveSpriteStats;

    public class EnemyStats extends InteractiveSpriteStats 
    {


        public function Clone():EnemyStats
        {
            var obj:Object = exportData();
            var enemy:EnemyStats = new EnemyStats();
            enemy.importData(obj);
            return (enemy);
        }

        override public function getVar(varName:String):*
        {
            if (this[("m_" + varName)] !== undefined)
            {
                return (this[("m_" + varName)]);
            };
            return (null);
        }


    }
}//package com.mcleodgaming.ssf2.enemies


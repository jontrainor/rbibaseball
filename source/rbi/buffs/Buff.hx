package rbi.buffs;

class Buff
{
    private var stats:Map<String, Int>;
    private var duration:Int;
    private var decay:Int;

    public function new(duration:Int, decay:Int, startingStats:Map<String, Int>)
    {
        this.duration = duration;
        this.decay = decay;
        
        stats = 
        [
            "moveSpeed" => 0,
            "throwSpeed" => 0,
            "strength" => 0,
            "dexterity" => 0,
            "perception" => 0,
            "stamina" => 0,
            "handed" => 0,
            "fastBall" => 0,
            "curveBall" => 0,
            "slider" => 0,
            "knuckleBall" => 0,
            "charisma" => 0,
            "wisdom" => 0,
            "intelligence" => 0,
            "happiness" => 0,
        ];

        for (stat in startingStats.keys()) {
            stats[stat] = startingStats[stat];
        }
    }

    public function getStat(stat:String)
    {
        return stats[stat];
    }

    public function tick(days:Int):Void
    {
        for (stat in stats.keys())
        {
            if (stats[stat] == 0) { break ; }
            var before = stats[stat];
            var after = stats[stat] + decay;
            if ((before < 0 && after > 0) || (before > 0 && after < 0))
            {
                stats[stat] = 0;
            }
            else
            {
                stats[stat] = after;
            }
        }
    }

    public function isActive():Bool
    {
        for (stat in stats.keys())
        {
            if (stats[stat] != 0)
            {
                return true;
            }
        }

        if (duration > 0)
        {
            return true;
        }

        return false;
    }
}

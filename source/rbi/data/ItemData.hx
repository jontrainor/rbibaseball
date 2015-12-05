package rbi.data;

import haxe.xml.Fast;

class ItemData
{
    public var discovered:Bool;
    public var name:String;
    public var type:String;
    public var frequency:Int;

    public var equipData:EquipData;
    public var uses:Array<UseData>;

    public function new(itemData:Fast)
    {
        this.name = itemData.att.name;
        this.type = itemData.att.type;
        this.frequency = Std.parseInt(itemData.att.frequency);

        this.discovered = false;
        this.equipData = null;
        this.uses = new Array<UseData>();

        if (itemData.name == 'equipment')
        {
            var curseable:Bool = (itemData.has.curseable)? true : false;
            var singular:Bool = (itemData.has.singular)? true : false;
            var extraFlavor:String = (itemData.has.extraFlavor)? itemData.att.extraFlavor : "";

            var stats:Map<String, EquipStatData> = new Map<String, EquipStatData>();
            for (stat in itemData.elements)
            {
                var statData:EquipStatData = 
                {
                    curseable: curseable,
                    extraFlavor: extraFlavor,
                    singular: singular,
                    min: Std.parseInt(stat.att.min),
                    max: Std.parseInt(stat.att.max)
                };
                stats[stat.att.type] = statData;
            }

            equipData = new EquipData(stats);
            this.uses.push(new UseData('equip', 'Equip'));
        }
        else
        {
            for (use in itemData.elements)
            {
                var stats:Map<String, Int> = new Map<String, Int>();
                for (stat in use.elements)
                {
                    stats[stat.att.type] = Std.parseInt(stat.att.value);
                }
                this.uses.push(new UseData(use.att.type, use.att.text, use.att.flavor, stats));
            }
        }
    }
}

class EquipData
{
    public var stats:Map<String, EquipStatData>;

    public function new(stats) {
        this.stats = stats;
    }
}

typedef EquipStatData = { curseable:Bool, min:Int, max:Int, extraFlavor:String, singular:Bool };

class UseData
{
    public var type:String;
    public var text:String;
    public var flavor:String;
    public var stats:Map<String, Int>;

    public function new(type:String, text:String, ?flavor:String, ?useStats:Map<String, Int>)
    {
        this.type = type;
        this.text = text;
        if (flavor == null)
        {
            this.flavor = '';
        }
        else
        {
            this.flavor = flavor;
        }
        this.stats =
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

        if (useStats != null)
        {
            for (stat in useStats.keys())
            {
                this.stats[stat] = useStats[stat];
            }
        }
    }
}

package rbi.data;

import flash.geom.ColorTransform;
import flixel.util.FlxRandom;

import rbi.items.Item;

class TeamData
{
    public var city:String;
    public var name:String;

    public var players:Array<PlayerData>;
    public var items:Array<Item>;

    public var pitchers:Array<PlayerData>;
    public var bench:Array<PlayerData>;
    public var currentPositions:Map<String, PlayerData>;

    public var battingOrder:Array<PlayerData>;

    public var color:ColorTransform;

    private var usedNumbers:Array<Int>;

    public function new (city:String, name:String)
    {
        this.city = city;
        this.name = name;

        this.players = new Array<PlayerData>();
        this.items = new Array<Item>();
        this.usedNumbers = new Array<Int>();

        this.battingOrder = new Array<PlayerData>();
        this.pitchers = new Array<PlayerData>();
        this.bench = new Array<PlayerData>();
        this.currentPositions = new Map<String, PlayerData>();

        generatePlayers();

        fillPositions();
    }

    private function generatePlayers():Void
    {
        generateStartingPitchers();
        generateRelievingPitchers();
        generateClosingPitchers();
        generateCatchers();
        generateFirstBases();
        generateSecondBases();
        generateThirdBases();
        generateShortStops();
        generateOutFields();
    }

    private function getPlayerName():String
    {
       return Std.string(Std.random(900000)+100000) + ' ' + Std.string(Std.random(900000)+100000);
    }

    private function getPlayerNumber():Int
    {
        var number:Int = FlxRandom.intRanged(1,99, this.usedNumbers);
        this.usedNumbers.push(number);
        return number;
    }

    private function randStatVal(lowRange:Int, highRange:Int):Int
    {
        return lowRange + Std.random(highRange - lowRange + 1); 
    }

    private function avgStat():Int
    {
        return randStatVal(5,12);
    }

    private function randBool():Int
    {
        return randStatVal(0,1);
    }

    private function getPitcherSkillMap():Map<String,Int>
    {
        var pitcherSkills:Array<String> = ['fastball', 'curveball', 'slider', 'knuckleball'];
        var skillMap:Map<String,Int> = ['fastball' => 10, 'curveball' => 10, 'slider' => 10, 'knuckleball' => 10];

        var highSkill:String = pitcherSkills[Std.random(pitcherSkills.length)];
        skillMap[highSkill] = randStatVal(12,18);
        pitcherSkills.remove(highSkill);

        var midSkill1:String = pitcherSkills[Std.random(pitcherSkills.length)];
        skillMap[midSkill1] = randStatVal(8,12);
        pitcherSkills.remove(midSkill1);

        var midSkill2:String = pitcherSkills[Std.random(pitcherSkills.length)];
        skillMap[midSkill2] = randStatVal(8,12);
        pitcherSkills.remove(midSkill2);

        var lowSkill:String = pitcherSkills[Std.random(pitcherSkills.length)];
        skillMap[lowSkill] = randStatVal(4,8);

        return skillMap;
    }

    private function generateStartingPitchers():Void
    {
        for (i in 0...6)
        {
            var skillMap:Map<String,Int> = getPitcherSkillMap();
            this.players.push(new PlayerData(
                getPlayerName(), 
                getPlayerNumber(),
                'SP',
                [
                    "moveSpeed" => randStatVal(1,10),
                    "throwSpeed" => randStatVal(20,35),
                    "strength" => randStatVal(1,10),
                    "dexterity" => randStatVal(1,10),
                    "perception" => randStatVal(1,10),
                    "stamina" => randStatVal(10,16),
                    "handed" => randBool(),
                    "fastBall" => skillMap['fastball'],
                    "curveBall" => skillMap['curveball'],
                    "slider" => skillMap['slider'],
                    "knuckleBall" => skillMap['knuckleball'],
                    "charisma" => avgStat(),
                    "wisdom" => avgStat(),
                    "intelligence" => avgStat(),
                    "happiness" => avgStat(),
                ])
            );
        }
    }

    private function generateRelievingPitchers():Void
    {
        for (i in 0...2)
        {
            var skillMap:Map<String,Int> = getPitcherSkillMap();
            this.players.push(new PlayerData(
                getPlayerName(),
                getPlayerNumber(),
                'RP',
                [
                    "moveSpeed" => randStatVal(1,10),
                    "throwSpeed" => randStatVal(16,25),
                    "strength" => randStatVal(1,10),
                    "dexterity" => randStatVal(1,10),
                    "perception" => randStatVal(1,10),
                    "stamina" => randStatVal(4,14),
                    "handed" => randBool(),
                    "fastBall" => skillMap['fastball'],
                    "curveBall" => skillMap['curveball'],
                    "slider" => skillMap['slider'],
                    "knuckleBall" => skillMap['knuckleball'],
                    "charisma" => avgStat(),
                    "wisdom" => avgStat(),
                    "intelligence" => avgStat(),
                    "happiness" => avgStat(),
                ])
            );
        }
    }

    private function generateClosingPitchers():Void
    {
        for (i in 0...2)
        {
            this.players.push(new PlayerData(
                getPlayerName(),
                getPlayerNumber(),
                'RP',
                [
                    "moveSpeed" => avgStat(),
                    "throwSpeed" => randStatVal(30,40),
                    "strength" => avgStat(),
                    "dexterity" => avgStat(),
                    "perception" => avgStat(),
                    "stamina" => randStatVal(1,4),
                    "handed" => randBool(),
                    "fastBall" => randStatVal(15,20),
                    "curveBall" => randStatVal(4,12),
                    "slider" => randStatVal(4,12),
                    "knuckleBall" => randStatVal(4,12),
                    "charisma" => avgStat(),
                    "wisdom" => avgStat(),
                    "intelligence" => avgStat(),
                    "happiness" => avgStat(),
                ])
            );
        }
    }

    private function generateCatchers():Void
    {
        for (i in 0...2)
        {
            this.players.push(new PlayerData(
                getPlayerName(),
                getPlayerNumber(),
                'C',
                [
                    "moveSpeed" => avgStat(),
                    "throwSpeed" => randStatVal(8,12),
                    "strength" => avgStat(),
                    "dexterity" => avgStat(),
                    "perception" => randStatVal(10,20),
                    "stamina" => avgStat(),
                    "handed" => randBool(),
                    "fastBall" => randStatVal(0,2),
                    "curveBall" => randStatVal(0,2),
                    "slider" => randStatVal(0,2),
                    "knuckleBall" => randStatVal(0,2),
                    "charisma" => avgStat(),
                    "wisdom" => avgStat(),
                    "intelligence" => avgStat(),
                    "happiness" => avgStat(),
                ])
            );
        }
    }

    private function generateFirstBases():Void
    {
        for (i in 0...2)
        {
            this.players.push(new PlayerData(
                getPlayerName(),
                getPlayerNumber(),
                '1B',
                [
                    "moveSpeed" => randStatVal(2,8),
                    "throwSpeed" => avgStat(),
                    "strength" => randStatVal(12,16),
                    "dexterity" => avgStat(),
                    "perception" => avgStat(),
                    "stamina" => avgStat(),
                    "handed" => randBool(),
                    "fastBall" => randStatVal(0,2),
                    "curveBall" => randStatVal(0,2),
                    "slider" => randStatVal(0,2),
                    "knuckleBall" => randStatVal(0,2),
                    "charisma" => avgStat(),
                    "wisdom" => avgStat(),
                    "intelligence" => avgStat(),
                    "happiness" => avgStat(),
                ])
            );
        }
    }

    private function generateSecondBases():Void
    {
        for (i in 0...2)
        {
            this.players.push(new PlayerData(
                getPlayerName(),
                getPlayerNumber(),
                '2B',
                [
                    "moveSpeed" => randStatVal(12,18),
                    "throwSpeed" => avgStat(),
                    "strength" => randStatVal(8,12),
                    "dexterity" => randStatVal(12,18),
                    "perception" => avgStat(),
                    "stamina" => avgStat(),
                    "handed" => randBool(),
                    "fastBall" => randStatVal(0,2),
                    "curveBall" => randStatVal(0,2),
                    "slider" => randStatVal(0,2),
                    "knuckleBall" => randStatVal(0,2),
                    "charisma" => avgStat(),
                    "wisdom" => avgStat(),
                    "intelligence" => avgStat(),
                    "happiness" => avgStat(),
                ])
            );
        }
    }

    private function generateThirdBases():Void
    {
        for (i in 0...2)
        {
            this.players.push(new PlayerData(
                getPlayerName(),
                getPlayerNumber(),
                '3B',
                [
                    "moveSpeed" => avgStat(),
                    "throwSpeed" => avgStat(),
                    "strength" => randStatVal(8,14),
                    "dexterity" => avgStat(),
                    "perception" => avgStat(),
                    "stamina" => avgStat(),
                    "handed" => randBool(),
                    "fastBall" => randStatVal(0,2),
                    "curveBall" => randStatVal(0,2),
                    "slider" => randStatVal(0,2),
                    "knuckleBall" => randStatVal(0,2),
                    "charisma" => avgStat(),
                    "wisdom" => avgStat(),
                    "intelligence" => avgStat(),
                    "happiness" => avgStat(),
                ])
            );
        }
    }

    private function generateShortStops():Void
    {
        for (i in 0...2)
        {
            this.players.push(new PlayerData(
                getPlayerName(),
                getPlayerNumber(),
                'SS',
                [
                    "moveSpeed" => randStatVal(16,24),
                    "throwSpeed" => avgStat(),
                    "strength" => avgStat(),
                    "dexterity" => randStatVal(16,24),
                    "perception" => avgStat(),
                    "stamina" => avgStat(),
                    "handed" => randBool(),
                    "fastBall" => randStatVal(0,2),
                    "curveBall" => randStatVal(0,2),
                    "slider" => randStatVal(0,2),
                    "knuckleBall" => randStatVal(0,2),
                    "charisma" => avgStat(),
                    "wisdom" => avgStat(),
                    "intelligence" => avgStat(),
                    "happiness" => avgStat(),
                ])
            );
        }
    }

    private function generateOutFields():Void
    {
        var position:Array<String> = ['LF', 'LF', 'CF', 'CF', 'RF', 'RF'];
        for (i in 0...6)
        {
            this.players.push(new PlayerData(
                getPlayerName(),
                getPlayerNumber(),
                position[i],
                [
                    "moveSpeed" => randStatVal(12,20),
                    "throwSpeed" => avgStat(),
                    "strength" => avgStat(),
                    "dexterity" => avgStat(),
                    "perception" => randStatVal(12,20),
                    "stamina" => avgStat(),
                    "handed" => randBool(),
                    "fastBall" => randStatVal(0,2),
                    "curveBall" => randStatVal(0,2),
                    "slider" => randStatVal(0,2),
                    "knuckleBall" => randStatVal(0,2),
                    "charisma" => avgStat(),
                    "wisdom" => avgStat(),
                    "intelligence" => avgStat(),
                    "happiness" => avgStat(),
                ])
            );
        }
    }

    private function fillPositions():Void
    {
        for (player in this.players)
        {
            var position:String = player.position;
            if (position == 'SP' || position == 'RP')
            {
                this.pitchers.push(player);
                position = 'P';
            }
            
            if (!this.currentPositions.exists(position))
            {
                this.currentPositions[position] = player;
                this.battingOrder.push(player);
            }
            else if(position != 'P')
            {
                this.bench.push(player);
            }
        }
    }
}

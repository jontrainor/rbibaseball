package rbi.data;

import flash.geom.Point;
import flash.geom.Matrix;
import flash.geom.ColorTransform;
import flash.geom.Rectangle;
import flash.display.BitmapData;

import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.group.FlxSpriteGroup;
import flixel.util.FlxRandom;
import flixel.addons.ui.FlxClickArea;
import flixel.addons.display.FlxExtendedSprite;

import openfl.Assets;

import rbi.buffs.Buff;
import rbi.items.Item;

class PlayerIcon extends FlxSpriteGroup
{
    public var data:PlayerData;
    public var icon:FlxExtendedSprite;
    public var fieldIcon:FlxExtendedSprite;
    public var number:FlxText;
    public var clickCallback:PlayerIcon->Void;

    public function new(player:PlayerData, onClick:PlayerIcon->Void)
    {
        super();

        this.clickCallback = onClick;

        this.data = player;
        this.icon = new FlxExtendedSprite();
        this.icon.loadGraphic(AssetPaths.icon_player_bench__png);
        this.icon.clickable = true;
        this.icon.mouseReleasedCallback = this.clicked;
        this.fieldIcon = new FlxExtendedSprite();
        this.fieldIcon.loadGraphic(AssetPaths.icon_player_field__png);
        this.fieldIcon.alpha = 0;
        this.fieldIcon.x = 30;
        this.fieldIcon.clickable = true;
        this.fieldIcon.mouseReleasedCallback = this.clicked;
        this.number = new FlxText(6,6,0,'#' + Std.string(this.data.number),10);
        add(this.icon);
        add(this.fieldIcon);
        add(this.number);
    }

    public function setFieldMode():Void
    {
        this.icon.alpha = 0;
        this.fieldIcon.alpha = 1;
    }

    public function setIconMode():Void
    {
        this.icon.alpha = 1;
        this.fieldIcon.alpha = 0;
    }

    public function toggleIconMode():Void
    {
        if (this.icon.alpha < 0.1)
        {
            this.setIconMode();
        }
        else
        {
            this.setFieldMode();
        }
    }

    private function clicked(s:FlxExtendedSprite, x:Int, y:Int):Void
    {
        this.clickCallback(this);
    }
}

class BattingIcon extends PlayerIcon
{
    public function new(player:PlayerData, onClick:PlayerIcon->Void)
    {
        super(player, onClick);
    }
}

class PlayerData
{
    public var name:String;
    public var number:Int;
    public var stats:Map<String, Int>;
    public var statsVisible:Map<String, Bool>;

    public var position:String;
    public var lastPosition:String;

    // Sweet spots
    public var battingSweetSpot:Point;
    public var pitchingSweetSpot:Point;

    // Modifiers
    //public var buffs:Array<Buff>;
    //public var equipment:Array<Equpment>;

    public function new(name:String, number:Int, position:String, startingStats:Map<String, Int>)
    {
        this.name = name;
        this.position = this.lastPosition = position;
        this.number = number;

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
            "hallucinating" => 0,
        ];

        // For now about 1% of stats will be visible
        this.statsVisible = new Map<String, Bool>();
        for (key in this.stats.keys())
        {
            if (key == 'handed')
            {
                this.statsVisible[key] = true;
            }
            else
            {
                this.statsVisible[key] = FlxRandom.chanceRoll(4.0);
            }
        }

        for (stat in startingStats.keys())
        {
            stats[stat] = startingStats[stat];
        }
    }

    public function getStat(stat:String):Int
    {
        var val:Int = stats[stat];
        return val;
    }

    public function getBaseStat(stat:String):Int
    {
        return stats[stat];
    }
}

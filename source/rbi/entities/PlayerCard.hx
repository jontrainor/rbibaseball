package rbi.entities;

import flixel.FlxSprite;
import flixel.addons.display.FlxExtendedSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;

import rbi.data.PlayerData;

class PlayerCard extends FlxSpriteGroup
{
    private var bg:FlxExtendedSprite = new FlxExtendedSprite();
    private var icon:FlxSprite = new FlxSprite();

    private var name:FlxText = new FlxText();
    private var equipSlots:Array<FlxSprite> = new Array<FlxSprite>();
    private var handed:FlxText = new FlxText();
    private var stats:Map<String, FlxText> = new Map<String, FlxText>();

    public function new(onClick:FlxExtendedSprite->Int->Int->Void):Void
    {
        super();

        this.bg.loadGraphic(AssetPaths.background_player_card__png);
        this.bg.mouseReleasedCallback = onClick;
        add(this.bg);

        this.icon.loadGraphic(AssetPaths.temp_player_portrait__png);
        this.icon.x = 65;
        this.icon.y = 80;
        add(this.icon);

        this.name.x = 252;
        this.name.y = 54;
        this.name.width = 230;
        this.name.size = 12;
        this.name.alignment = 'center';
        add(this.name);

        var equipText = new FlxText(252, 115, 230, 'Equipment', 20);
        equipText.alignment = 'center';
        add(equipText);

        for (i in 0...5)
        {
            var equipSlot = new FlxSprite();
            equipSlot.loadGraphic(AssetPaths.item_back__png);
            equipSlot.x = 275;
            equipSlot.y = 150 + (i * 40);
            this.equipSlots.push(equipSlot);
            add(equipSlot);
        }

        this.stats = 
        [
            "moveSpeed" => new FlxText(50, 100),
            "throwSpeed" => new FlxText(50, 110),
            "strength" => new FlxText(50, 120),
            "dexterity" => new FlxText(50, 130),
            "perception" => new FlxText(50, 140),
            "stamina" => new FlxText(50, 150),
            "handed" => new FlxText(50, 160),
            "fastBall" => new FlxText(50, 170),
            "curveBall" => new FlxText(50, 180),
            "slider" => new FlxText(50, 190),
            "knuckleBall" => new FlxText(50, 200),
        ];
        for (text in this.stats.iterator())
        {
            add(text);
        }
    }

    public function setPlayer(player:PlayerData)
    {
        this.name.text = '#23 somename somename';

        for (stat in this.stats.keys())
        {
            this.stats[stat].text = Std.string(player.getStat(stat));
        }
    }
}
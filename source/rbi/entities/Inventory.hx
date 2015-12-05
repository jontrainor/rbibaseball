package rbi.entities;

import flixel.addons.display.FlxExtendedSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;

class Inventory extends FlxSpriteGroup
{
    private var bg:FlxExtendedSprite = new FlxExtendedSprite();

    public function new(onClick:FlxExtendedSprite->Int->Int->Void):Void
    {
        super();

        this.bg.loadGraphic(AssetPaths.background_inventory__png);
        this.bg.mouseReleasedCallback = onClick;
        add(this.bg);

        var title:FlxText = new FlxText(0, 20, this.bg.width, 'Inventory', 20);
        title.alignment = 'center';
        add(title);
    }
}
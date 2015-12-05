package rbi.managers;

import haxe.Resource;
import openfl.Assets;
import haxe.xml.Fast;
import flixel.util.FlxRandom;

import rbi.data.ItemData;
import rbi.items.Item;

class ItemManager
{
    public var items:Array<ItemData>;

    public function new()
    {
        this.items = new Array<ItemData>();

        var xml:Xml = Xml.parse(Assets.getText(AssetPaths.ItemData__xml));
        var itemData:Fast = new Fast(xml.firstElement());
        for (item in itemData.elements)
        {
            this.items.push(new ItemData(item));
        }
    }

    public function getRandomItem():Item
    {
        var index:Int = FlxRandom.intRanged(0, this.items.length);

        return new Item(this.items[index]);
    }
}
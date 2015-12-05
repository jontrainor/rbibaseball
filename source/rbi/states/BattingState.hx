package rbi.states;

import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxSprite;
import flixel.addons.display.shapes.FlxShapeCircle;
import flixel.group.FlxSpriteGroup;
import flixel.tweens.FlxTween;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxPoint;
import flixel.util.FlxTimer;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxColor;
import flixel.util.FlxMath;
import flixel.util.FlxVector;
import flixel.util.FlxRandom;

import rbi.data.PlayerData;
import rbi.managers.DataManager;
import rbi.entities.Ball;
import rbi.states.BattingPitchingState;

class BattingState extends BattingPitchingState
{

    private var _batterSweetSpot:FlxShapeCircle;
    private var _previousBatterSweetSpot:FlxShapeCircle;

    override public function create():Void
    {
        super.create();
        _batterSweetSpot = super.generateBatterSweetSpot();
        add(_batterSweetSpot);
    }

    override public function destroy():Void
    {
        super.destroy();
    }

    override public function update():Void
    {
        super.update();

        var distance:Int = FlxMath.distanceToMouse(_batterSweetSpot);

        _batterSweetSpot.x = FlxG.mouse.x;
        _batterSweetSpot.y = FlxG.mouse.y;

        if (FlxG.mouse.pressed)
        {
        }
    }
}

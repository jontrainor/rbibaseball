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

class PitchingState extends BattingPitchingState
{
    override public function create():Void
    {
        super.create();

        /* min and max ratios for size of sweet spot */
        super.createPitchSweetSpot(2, 6);
    }

    override public function destroy():Void
    {
        super.destroy();
    }

    override public function update():Void
    {
        super.update();
        super.updatePitchSweetSpot();

        if (FlxG.mouse.pressed)
        {
            super.throwBall();
        }

    }
}

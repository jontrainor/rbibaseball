package rbi.entities;

import flixel.group.FlxSpriteGroup;
import flixel.FlxSprite;
import flixel.tweens.FlxTween;
import flixel.tweens.motion.QuadPath;
import flixel.addons.display.shapes.FlxShapeCircle;
import flixel.util.FlxColor;
import flixel.util.FlxPoint;

class Ball extends FlxSpriteGroup
{
    private var _ball:FlxSprite;
    private var _moveTween:QuadPath;
    private var _scaleTween:FlxTween;
    private var _endSpot:FlxShapeCircle;

    public function new(img:FlxSprite):Void
    {
        super();
        _ball = img;
        var ls = {
            thickness: 3.0,
            color: FlxColor.WHITE
        }
        var fs = {
            color: FlxColor.TRANSPARENT
        };
        _endSpot = new FlxShapeCircle(0,0,23,ls,fs);
        _endSpot.offset.x = _endSpot.width/2;
        _endSpot.offset.y = _endSpot.height/2;
        
        add(_ball);
    }

    public function setPath(points:Array<FlxPoint>):Void
    {
        _ball.scale.x = 0.2;
        _ball.scale.y = 0.2;
        _moveTween = FlxTween.quadPath(_ball, points, 0.7, true);
        _moveTween.complete = this.tweenCallback;
        _scaleTween = FlxTween.tween(_ball.scale, {x:1.0, y:1.0 }, 1);

        _endSpot.x = points[points.length - 1].x;
        _endSpot.y = points[points.length - 1].y;
        _endSpot.alpha = 0;
        add(_endSpot);
    }

    private function tweenCallback(tween:FlxTween):Void
    {
        _ball.alpha = 0;
        _endSpot.alpha = 1;
    }

    public function show():Void
    {
        _ball.alpha = 1.0;
    }

    public function hide():Void
    {
        _ball.alpha = 0.0;
    }

    public function play():Void
    {
        _moveTween.active = true;
        _scaleTween.active = true;
    }

    public function pause():Void
    {
        _moveTween.active = false;
        _scaleTween.active = false;
    }
}

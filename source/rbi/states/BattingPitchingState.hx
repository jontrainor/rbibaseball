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

class BattingPitchingState extends FlxState
{
    public var _bg:FlxSprite = new FlxSprite();
    public var _strikeZone:FlxSprite = new FlxSprite();
    public var _ball:Ball;
    public var _pitcher:FlxSprite = new FlxSprite();
    public var _pitchTimer:FlxTimer = new FlxTimer();
    public var _swingTimer:FlxTimer = new FlxTimer();
    public var _pitchSweetSpot:FlxShapeCircle;
    public var _pitchAccuracy:FlxShapeCircle;
    public var _pitchSweetSpotScale:Float = 1.0;

    public var _batter:FlxSprite = new FlxSprite();
    public var _ballImage:FlxSprite = new FlxSprite();

    public var _minSweetSpotRatio:Float;
    public var _maxSweetSpotRatio:Float;

    public function createPitcher():Void
    {
        _pitcher.loadGraphic(AssetPaths.pitcher_greyscale__png, true, 64, 64);
        _pitcher.animation.add('idle', [0], 1, true);
        _pitcher.animation.add('throw', [0,1,2,3,4,5,6,7,8], 10, false);
        _pitcher.animation.play('idle');
        _pitcher.x = FlxG.width/2;
        _pitcher.y = 140;
        _pitcher.scale.x = 2.0;
        _pitcher.scale.y = 2.0;
        add(_pitcher);
    }

    public function createBatter():Void
    {
        _batter.loadGraphic(AssetPaths.batter_greyscale__png, true, 210, 145);
        _batter.animation.add('idle', [0,1,2,3], 4, true);
        _batter.animation.add('swing_mid', [4,5,6,7,8,9,10], 10, false);
        _batter.animation.add('swing_high', [11,12,13,14,15,16,17], 10, false);
        _batter.animation.add('swing_low', [18,19,20,21,22,23,24], 10, false);
        _batter.animation.play('idle');
        _batter.x = FlxG.width/4;
        _batter.y = FlxG.height/2;
        _batter.scale.x = 3.0;
        _batter.scale.y = 3.0;
        add(_batter);
    }

    public function createPitchSweetSpot(minRatio, maxRatio):Void
    {
        _minSweetSpotRatio = minRatio;
        _maxSweetSpotRatio = maxRatio;

        var ls = {
            thickness: 3.0,
            color: FlxColor.WHITE
        };
        var fs = {
            color: FlxColor.TRANSPARENT
        };
        _pitchSweetSpot = new FlxShapeCircle(FlxG.width/2, FlxG.height/2, 20, ls, fs);
        add(_pitchSweetSpot);

        _pitchAccuracy = new FlxShapeCircle(FlxG.width/2, FlxG.height/2, 100, ls, fs);
        _pitchAccuracy.offset.x = _pitchAccuracy.width/2;
        _pitchAccuracy.offset.y = _pitchAccuracy.height/2;
        add(_pitchAccuracy);
    }

    public function generateBatterSweetSpot():FlxShapeCircle
    {
        var ls = {
            thickness: 3.0,
            color: FlxColor.WHITE
        };
        var fs = {
            color: FlxColor.TRANSPARENT
        };
        var _batterSweetSpot:FlxShapeCircle = new FlxShapeCircle(FlxG.width/2, FlxG.height/2, 20, ls, fs);
        _batterSweetSpot.offset.x = _batterSweetSpot.width/2;
        _batterSweetSpot.offset.y = _batterSweetSpot.height/2;
        return _batterSweetSpot;
    }

    override public function create():Void
    {
        super.create();

        _bg.loadGraphic(AssetPaths.background_batting__png);
        add(_bg);

        createPitcher();
        createBatter();

        _ballImage.loadGraphic(AssetPaths.ball__png, true, 46, 46);
        _ballImage.offset.set(_ballImage.width/2, _ballImage.height/2);
        _ball = new Ball(_ballImage);
        _ball.hide();
        add(_ball);

        _strikeZone.loadGraphic(AssetPaths.strike_zone__png);
        _strikeZone.setPosition((FlxG.width/2)-(_strikeZone.width/2), (FlxG.height/2)-(_strikeZone.height/2));
        add(_strikeZone);

    }

    override public function destroy():Void
    {
        super.destroy();

        _bg = FlxDestroyUtil.destroy(_bg);
        _strikeZone = FlxDestroyUtil.destroy(_strikeZone);
        _ball = FlxDestroyUtil.destroy(_ball);
        _pitcher = FlxDestroyUtil.destroy(_pitcher);
    }

    public function updatePitchSweetSpot():Void
    {
        var distance:Int = FlxMath.distanceToMouse(_pitchSweetSpot);
        var min:Float = _minSweetSpotRatio * _pitchSweetSpot.radius;
        var max:Float = _maxSweetSpotRatio * _pitchSweetSpot.radius;
        if (distance < min)
        {
            _pitchSweetSpotScale = 0.2;
        }
        else if (distance < max)
        {
            
            _pitchSweetSpotScale = (((distance - min)/(max - min))*0.8)+0.2;
        }
        _pitchAccuracy.scale.x = _pitchSweetSpotScale;
        _pitchAccuracy.scale.y = _pitchSweetSpotScale;
        _pitchAccuracy.x = FlxG.mouse.x;
        _pitchAccuracy.y = FlxG.mouse.y;
    }

    public function throwBall():Void
    {
        var vec:FlxVector;
        var point:FlxPoint = FlxG.mouse.getScreenPosition();
        _pitcher.animation.play('throw');
        _pitchTimer.start(0.5, function(timer:FlxTimer):Void {
            var points = new Array<FlxPoint>();
            points.push(FlxPoint.get(FlxG.width/2, 140));
            points.push(FlxPoint.get(FlxG.width/2 + 300, 200));

            vec = new FlxVector(FlxRandom.floatRanged(0, _pitchAccuracy.radius * _pitchSweetSpotScale), 0);
            vec.rotateByDegrees(FlxRandom.floatRanged(0, 360));
            vec.addNew(new FlxVector(point.x, point.y));
            point.addPoint(vec);

            points.push(FlxPoint.get(point.x, point.y));
            _ball.show();
            _ball.setPath(points);

        });
        _swingTimer.start(0.85, function(timer:FlxTimer):Void {
            var midStrikeZone:Float = FlxG.height/2;
            trace(midStrikeZone,'point', point.x, point.y);
            var swingHeight:String = 'mid';
            if(point.y <= midStrikeZone)
            {
                swingHeight = 'high';
                trace('high swing');
            }
            else if(point.y > midStrikeZone)
            {
                swingHeight = 'low';
                trace('low swing');
            }
            _batter.animation.play('swing_' + swingHeight);
        });
    }

    override public function update():Void
    {
        super.update();

        if (_pitcher.animation.finished == true)
        {
            _pitcher.animation.play('idle');
        }

        if (_batter.animation.finished == true)
        {
            _batter.animation.play('idle');
        }

        if (FlxG.keys.justPressed.LEFT)
        {
            _ball.pause();
        }
        if (FlxG.keys.justPressed.RIGHT)
        {
            _ball.play();
        }
    }
}


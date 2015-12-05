package rbi.simulations;

import flash.geom.Vector3D;
import flash.geom.Point;

import flixel.util.FlxRandom;

import rbi.data.TeamData;
import rbi.data.PlayerData;
import rbi.data.RunnerData;
import rbi.data.FieldingStateData;

using Lambda;

// values are in feet and seconds unless otherwise noted
class FieldingSimulation
{
    public var fieldingState:FieldingStateData;

    public var teamData:TeamData;
    public var ballVector:Vector3D;
    public var ballMPH:Float;
    public var ballDistance:Float;
    public var ballAngleZY:Float;
    public var ballAngleXY:Float;

    // stadium info
    public var stadiumLength:Float = 350;
    public var distanceBetweenBases:Float = 90;

    public var batter:PlayerData;
    public var runners:Array<RunnerData>;

    // starting points are on base or exactly between bases
    public var playerPos:Map<String,Point> = [
        'P' => new Point(0, 60.5),
        'C' => new Point(0, -6.5),
        '1B' => new Point(63.64, 63.64),
        '2B' => new Point(0, 126.25),
        '3B' => new Point(-63.64, 63.64),
        'SS' => new Point(-31.82, 94.42),
        'LF' => new Point(-135.94, 198.54),
        'CF' => new Point(0, 252.75),
        'RF' => new Point(135.94, 198.54),
    ];

    public var basePos:Map<String,Point> = [
        'HOME' => new Point(0,0),
        '1B' => new Point(63.64, 63.64),
        '2B' => new Point(0, 126.25),
        '3B' => new Point(-63.64, 63.64)
    ];

    // keeps track of current time elapsed in sec
    public var time:Float = 0;

    public var hitBallSpeedScalar:Float;

    public var strengthFactor:Float = 1;
    public var moveSpeedFactor:Float = 0;
    public var throwSpeedFactor:Float = 0;

    public var avgStrength:Int = 10;
    public var avgMoveSpeed:Int = 10;
    public var avgThrowSpeed:Int = 10;
    public var avgPerception:Int = 10;

    // in percentages - to be used by flixel.util.FlxRandom.chanceRoll()
    public var diveCatchChance = 70;
    public var fielderErrorChance = 95;
    public var slideChance = 50;

    public var runnerToBaseVariance:Float;

    // subtracted by distance player needs to travel to get to ball (arm length)
    public var playerReach:Float = 3.0;

    // margin of error allowed for player to get to the ball
    public var catchTimeThreshold:Float = 0.2;

    // if tPlayerBallDelta is within threshold, it's a dive
    public var diveCatchTimeThreshold:Float = 0.2;

    // min distance a ball
    public var minBallDistance:Float = 0; 

    public var story:Array<String> = [];

    private function getMoveSpeedScalar(player:PlayerData):Float
    {
        // 180 ft in 7 seconds is avg MLB base runner
        var moveSpeedScalar = (180 / 7) + ((player.getStat('moveSpeed') - this.avgMoveSpeed) * this.moveSpeedFactor);
        return moveSpeedScalar;
    }

    private function getThrowSpeedScalar(player:PlayerData):Float
    {
        // a good catcher can throw to 2b in under 2.0 seconds (45 ft/sec)
        // assume avg throw speed is 40 ft/sec
        var throwSpeedScalar = 45 + ((player.getStat('throwSpeed') - this.avgThrowSpeed) * this.throwSpeedFactor); 
        return throwSpeedScalar;
    }

    private function findClosestPlayerToBall(ballPoint:Point):PlayerData
    {
        var closestFielder:PlayerData = null;
        for(position in this.playerPos.keys())
        {
            var distanceFromBall:Float = Point.distance(ballPoint, this.playerPos[position]);
            if(closestFielder == null || distanceFromBall < Point.distance(ballPoint, this.playerPos[closestFielder.position]))
            {
                closestFielder = this.teamData.currentPositions[position];
            }
        }

        trace(closestFielder.position, this.playerPos[closestFielder.position].x, this.playerPos[closestFielder.position].y, Point.distance(ballPoint, this.playerPos[closestFielder.position]));

        return closestFielder;
    }

    private function vectorToPoint(vector:Vector3D, length:Float):Point
    {
        var vectorCopy:Vector3D = new Vector3D(vector.x, vector.y, 0, 0);
        vectorCopy.normalize();
        vectorCopy.scaleBy(length);

        var point:Point = new Point(vectorCopy.x, vectorCopy.y);
        // trace('ball point', point.x, point.y);

        return point;
    }

    private function getRollDistance():Float
    {
        if(this.ballAngleZY >= 60)
        {
            return 40;
        }
        else if(20 <= this.ballAngleZY && this.ballAngleZY < 60)
        {
            return 80;
        }
        else if(-20 <= this.ballAngleZY && this.ballAngleZY < 20)
        {
            return 120;
        }
        else if(this.ballAngleZY < -20)
        {
            return 80;
        }
        return 0;
    }

    private function convertRadsToAngle(rads:Float):Float
    {
        // return (rads < Math.PI) ? rads * 180 / Math.PI : (rads - (2 * Math.PI)) * 180 / Math.PI;
        return rads * 180 / Math.PI;
    }

    private function getAngleZY(a:Float, b:Float):Float
    {
        var positiveAngle:Bool = (a >= 0) ? true : false;
        a = Math.abs(a);
        b = Math.abs(b);
        var c:Float = Math.sqrt((a * a) + (b * b));
        var angle:Float = Math.acos(((b * b) + (c * c) - (a * a)) / (2 * a * c));
        return (positiveAngle) ? angle : -1 * angle;
    }

    private function getAngleXY(a:Float, b:Float):Float
    {
        var positiveAngle:Bool = (a >= 0) ? true : false;
        a = Math.abs(a);
        b = Math.abs(b);
        var c:Float = Math.sqrt((a * a) + (b * b));
        var angle:Float = Math.acos(((b * b) + (c * c) - (a * a)) / (2 * b * c));
        return (positiveAngle) ? angle : -1 * angle;
    }

    private function updateRunners():Void
    {
        // calculate how far runners have gone
        for(runner in this.runners)
        {
            var _runnerDist:Float = runner.calcDistance(this.time, true);
            trace(runner + ' ran this far: ' + _runnerDist);
        }
    }

    private function resolveThrowToBase(fielder:PlayerData, runner:RunnerData, base:String):Void
    {
        var _story:String = fielder.position + ((base == 'home') ? 'throws ' : ' throws to ') + base + ' ';
        var runnerToBaseDistance:Float = this.distanceBetweenBases - runner.distance;
        if(runnerToBaseDistance >= this.runnerToBaseVariance)
        {
            _story += 'for an easy out.';
            runner.state = RunnerState.Out;
            // inc stats
        }
        else if(this.runnerToBaseVariance < runnerToBaseDistance && runnerToBaseDistance >= 0)
        {
            //TODO: add player stat to contribute to slide success
            if(FlxRandom.chanceRoll(this.slideChance))
            {
                _story += ('as ' + runner.data.position + ' makes a daring slide and the umpire calls him SAFE!');
                runner.state = RunnerState.Safe;
                if(base == 'home')
                {
                    _story += ' What an amazing in the park HOME RUN!';
                    runner.state = RunnerState.Safe;
                }
                // inc stats
            }
            else
            {
                _story += ('as ' + runner.data.position + ' slides into ' + fielder.position + 'and the umpire calls him OUT!');
                runner.state = RunnerState.Out;
                // inc stats
            }
        }
        else
        {
            var tmpStory = 
            _story += ('but ' + runner.data.position + ' is safe by a mile');
            runner.state = RunnerState.Safe;
        }
        this.story.push(_story);
    }

    private function resolveFielding():Void
    {
        var _runnerDist:Float;
        var fielderWithBall:PlayerData = this.fieldingState.playerWithBall;

        var distanceFielderTo1B:Float = Point.distance(this.playerPos[fielderWithBall.position], this.basePos['1B']);
        trace('distance to 1B', distanceFielderTo1B);
        var distanceFielderTo2B:Float = Point.distance(this.playerPos[fielderWithBall.position], this.basePos['2B']);
        var distanceFielderTo3B:Float = Point.distance(this.playerPos[fielderWithBall.position], this.basePos['3B']);
        var distanceFielderToHome:Float = Point.distance(this.playerPos[fielderWithBall.position], this.basePos['HOME']);

        var throwTime1B:Float = distanceFielderTo1B / getThrowSpeedScalar(fielderWithBall);
        trace('throw time to 1B', throwTime1B);
        var throwTime2B:Float = distanceFielderTo2B / getThrowSpeedScalar(fielderWithBall);
        var throwTime3B:Float = distanceFielderTo3B / getThrowSpeedScalar(fielderWithBall);
        var throwTimeHome:Float = distanceFielderToHome / getThrowSpeedScalar(fielderWithBall);

        //has the play been resolved?
        var runnersResolved:Array<Bool> = this.runners.map(function(runner:RunnerData) {
            return [RunnerState.Safe, RunnerState.Out].exists(function(runnerState:RunnerState) {
                return runnerState == runner.state;
            });
        });
        var playContinues:Bool = runnersResolved.has(false);
        if(playContinues)
        {
            // determine which runner we care about
            // test hardcode to batter
            var _runner = this.runners[0];

            // throw to base for out - where should he throw?
            if(_runner.distance < this.distanceBetweenBases)
            {
                this.time += throwTime1B;
                _runnerDist = _runner.calcDistance(this.time);
                trace('distance runner goes during throw', _runnerDist);

                resolveThrowToBase(fielderWithBall, _runner, 'first base');

            }
            else if(_runner.distance < 2*this.distanceBetweenBases) {
                this.time += throwTime2B;
                _runnerDist = _runner.calcDistance(this.time);
                trace('distance runner can go during throw', _runnerDist);

                // if runner is more than halfway to 2b keep going
                // runner can judge distance less so if he can get within 2*acceptable distance he goes for it
                if(2*this.runnerToBaseVariance < _runner.distance)
                {
                    resolveThrowToBase(fielderWithBall, _runner, 'second base');
                }
                else {
                    this.story.push(_runner.data.position + ' runs to first base with plenty of time while ' +
                        fielderWithBall.position + ' plays it safe and throws to second.');
                    _runner.state = RunnerState.Safe;
                }
            }
            else if(_runner.distance < 3*this.distanceBetweenBases) {
                this.time += throwTime3B;
                _runnerDist = _runner.calcDistance(this.time);
                trace('distance runner can go during throw', _runnerDist);

                // if runner is more than halfway to 3b keep going
                // runner can judge distance less so if he can get within 3*acceptable distance he goes for it
                if(3*this.runnerToBaseVariance < _runner.distance)
                {
                    resolveThrowToBase(fielderWithBall, _runner, 'third base');
                }
                else {
                    this.story.push(_runner.data.position + ' runs to second base with plenty of time while ' +
                        fielderWithBall.position + ' plays it safe and throws to second.');
                    _runner.state = RunnerState.Safe;
                }
            }
            else if(_runner.distance < 4*this.distanceBetweenBases) {
                this.time += throwTimeHome;
                _runnerDist = _runner.calcDistance(this.time);
                trace('distance runner can go during throw', _runnerDist);

                // if runner is more than halfway to home keep going
                // runner can judge distance less so if he can get within 4*acceptable distance he goes for it
                if(4*this.runnerToBaseVariance < _runner.distance)
                {
                    resolveThrowToBase(fielderWithBall, _runner, 'home');
                }
                else {
                    this.story.push(_runner.data.position + ' runs to third base with plenty of time while ' +
                        fielderWithBall.position + ' plays it safe and throws to second.');
                    _runner.state = RunnerState.Safe;
                }
            }
            else
            {
                this.story.push(_runner.data.position + ' amazingly runs for a rare in the park HOME RUN!');
                _runner.state = RunnerState.Safe;
            }

            resolveFielding();
        }
    }

    public function new(teamData:TeamData, ballVector:Vector3D)
    {
        this.ballVector = ballVector;
        this.teamData = teamData;

        // test data
        this.batter = this.teamData.players[11];
        this.runners = [new RunnerData(this.batter, getMoveSpeedScalar(this.batter), RunnerState.Running_Forward, 0)];
        // ---------

        // if the player is +/- within this distance of the base, then he will try to run there
        this.runnerToBaseVariance = this.distanceBetweenBases * 0.05;

        var ballAngleZYRads:Float = getAngleZY(this.ballVector.z, this.ballVector.y);
        this.ballAngleZY = convertRadsToAngle(ballAngleZYRads);

        var ballAngleXYRads:Float = getAngleXY(this.ballVector.x, this.ballVector.y);
        this.ballAngleXY = convertRadsToAngle(ballAngleXYRads);

        this.ballMPH = ballVector.length + ((this.batter.getStat('strength') - this.avgStrength) * strengthFactor);

        // ft per second 
        this.hitBallSpeedScalar = this.ballMPH * (5280 / 3600) * Math.cos(ballAngleZYRads);

        // 90 mph = 300 ft
        // assumes all hits are pefect angles
        this.ballDistance = (this.ballMPH > 30) ? (this.ballMPH - 30) * 5 : this.minBallDistance;

        // TODO: adjust this.ballDistance based off of this.ballAngleZY
    }

    public function run():Array<String>
    {
        var initBallPoint:Point = vectorToPoint(this.ballVector, this.ballDistance);
        // trace('ball point', ballVectorCopy.x, ballVectorCopy.y);

        if(this.ballAngleXY < -45 || this.ballAngleXY > 45) {
            // END POINT
            this.story.push(this.batter.position + ' hit a foul ball.');
            
            // inc foulBall stat

            return this.story;
        }

        if(this.ballDistance > this.stadiumLength)
        {
            // END POINT
            this.story.push(this.batter.position + ' hit a HOME RUN!!.');
            
            // inc homerun stat
            // inc rbi stat

            return this.story;
        }

    // closest fielder attempts to catch or run down a ball
        var closestFielder:PlayerData = findClosestPlayerToBall(initBallPoint);

        // is player close enough to catch?
        var timePlayerToInitSpot = (Point.distance(initBallPoint, this.playerPos[closestFielder.position]) - this.playerReach) / getMoveSpeedScalar(closestFielder);
        var timeBallToInitSpot = this.ballDistance / this.hitBallSpeedScalar;
        // trace('t(playerToSpot)', Point.distance(initBallPoint, this.playerPos[closestFielder.position]), getMoveSpeedScalar(closestFielder), timePlayerToInitSpot);
        // trace('t(ballToSpot)', this.ballDistance, this.hitBallSpeedScalar, timeBallToInitSpot);

        var tPlayerBallDelta:Float = timePlayerToInitSpot - timeBallToInitSpot - this.catchTimeThreshold;
        if(tPlayerBallDelta < 0)
        {
            if(tPlayerBallDelta <= this.diveCatchTimeThreshold)
            {
                // check if player successfully makes diving catch
                if(FlxRandom.chanceRoll(this.diveCatchChance + closestFielder.getStat('perception') - this.avgPerception))
                {
                    // END POINT
                    this.story.push(closestFielder.position + ' made a spectacular diving catch for the out!');

                    // inc caughtOut stat
                    // inc diveCatch stat

                    return this.story;
                }
                else
                {
                    this.story.push(closestFielder.position + ' dove for the ball and just barely missed it.');

                    // inc missedCatch stat
                }
            }
            else
            {
                if(FlxRandom.chanceRoll(this.fielderErrorChance + closestFielder.getStat('perception') - this.avgPerception))
                {
                    // END POINT
                    this.story.push(closestFielder.position + ' made an easy catch for the out.');
                    
                    // inc caughtOut stat

                    return this.story;
                }
                else
                {
                    this.story.push(closestFielder.position + " blew the catch. That's definitely an error.");

                    // inc missedCatch stat
                    // inc error stat
                }
            }
            this.time += timePlayerToInitSpot;
            trace(this.time);
            this.playerPos[closestFielder.position] = initBallPoint;
        }

        // BALL HITS GROUND

        // player chases ball down
        var rollBallPoint:Point = vectorToPoint(this.ballVector, this.ballDistance + getRollDistance());
        closestFielder = findClosestPlayerToBall(rollBallPoint);

        var timePlayerToRollSpot:Float = (Point.distance(rollBallPoint, this.playerPos[closestFielder.position])) / getMoveSpeedScalar(closestFielder);

        this.story.push(closestFielder.position + ' chased down the ball.');
        this.time += timePlayerToInitSpot;
        this.playerPos[closestFielder.position] = rollBallPoint;

        this.fieldingState = new FieldingStateData(closestFielder, false);
        updateRunners();
        resolveFielding();
        return this.story;
        }
}

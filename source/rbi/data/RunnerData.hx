package rbi.data;

import rbi.data.PlayerData;

class RunnerData
{
    public var data:PlayerData;
    public var moveSpeedScalar:Float;
    public var state:RunnerState;
    public var distance:Float;

    public function new(data:PlayerData, moveSpeedScalar:Float, state:RunnerState, distance:Float)
    {
        this.data = data;
        this.moveSpeedScalar = moveSpeedScalar;
        this.state = state;
        this.distance = distance;
    }

    public function calcDistance(time:Float, setDistance:Bool = false):Float
    {
        var distance:Float = this.moveSpeedScalar * time;
        if(setDistance)
        {
            this.distance = distance;
        }
        return distance;
    }
}

enum RunnerState
{
    Running_Forward;
    Running_Backward;
    Safe;
    Out;
}


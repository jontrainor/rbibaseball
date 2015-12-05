package rbi.data;

import rbi.data.PlayerData;

// things to worry about:
// more than one runner - tag up after catch? how many outs? is double play possible?
// fielder needs to cover another spot?
class FieldingStateData
{
    public var playerWithBall:PlayerData;
    public var batterCaughtOut:Bool;

    public function new(playerWithBall:PlayerData, batterCaughtOut:Bool)
    {
        this.playerWithBall = playerWithBall;
        this.batterCaughtOut = batterCaughtOut;
    }

}


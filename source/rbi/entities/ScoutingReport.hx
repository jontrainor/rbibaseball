package rbi.entities;

import flixel.FlxSprite;
import flixel.addons.display.FlxExtendedSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;

import rbi.data.TeamData;
import rbi.data.PlayerData;

class ScoutingReport extends FlxSpriteGroup
{
    private var bg:FlxExtendedSprite = new FlxExtendedSprite();
    private var teamName:FlxText;

    public function new(team:TeamData, onClick:FlxExtendedSprite->Int->Int->Void):Void
    {
        super();

        this.x = 75;
        this.y = 1280;

        this.bg.loadGraphic(AssetPaths.background_scouting_report__png);
        this.bg.mouseReleasedCallback = onClick;
        add(this.bg);

        var grid:FlxSprite = new FlxSprite();
        grid.loadGraphic(AssetPaths.grid_scouting_report__png);
        grid.x = 60;
        grid.y = 60;
        add(grid);

        this.teamName = new FlxText(0, 10, this.bg.width, team.city + ' ' + team.name, 20);
        this.teamName.alignment = 'center';
        add(this.teamName);

        this.drawRowHeader();

        var count:Int = 0;
        for (pitcher in team.pitchers)
        {
            this.drawColumn(count++, pitcher, true);
        }

        for (player in team.players)
        {
            if (team.pitchers.indexOf(player) == -1)
            {
                this.drawColumn(count++, player);
            }
        }
    }

    public function drawRowHeader():Void
    {
        var yOffset:Int = 130;
        var width:Int = 110;
        var height:Int = 26;
        var headers =
        ['Handed',
        'Move Spd',
        'Throw Spd',
        'React Tm',
        'Perception',
        'Stamina',
        '',
        'PITCHING',
        'Fst Ball',
        'Crv Ball',
        'K Ball',
        'Slider',
        'Swt Spot',
        '',
        'BATTING',
        'Strength',
        'Swt Spot',
        'Bat Order'];
        for (i in 0...headers.length)
        {
            var size:Int = 12;
            var text:FlxText = new FlxText(60, 126 + (i*height), width, headers[i], size);
            text.alignment = 'right';
            add(text);
        }
    }

    public function drawColumn(index:Int, data:PlayerData, ?isPitcher:Bool=false):Void
    {
        var stats = 
        ['handed',
        'moveSpeed',
        'throwSpeed',
        'reactionTime',
        'perception',
        'stamina',
        '',
        '',
        'fastBall',
        'curveBall',
        'knuckleBall',
        'slider',
        'pSwtSpot',
        '',
        '',
        'strength',
        'bSwtSpot',
        'battingOrder'];
        for (i in 0...stats.length)
        {
            var text:String = '';
            switch stats[i]
            {
                case 'handed':
                    text = data.stats['handed'] == 0 ? 'R' : 'L';
                case 'pSwtSpot':
                    text = '';
                case 'bSwtSpot':
                    text = '';
                default:
                    if (data.statsVisible[stats[i]]) text = Std.string(data.getStat(stats[i])); else text = '';
            }
            var txt:FlxText = new FlxText(170 + (index*37), 126 + (i*26), 37, text, 12);
            txt.alignment = 'center';
            add(txt);
        }
    }
}
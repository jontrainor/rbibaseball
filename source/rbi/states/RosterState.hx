package rbi.states;

import flash.geom.Point;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxExtendedSprite;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxDestroyUtil;

import rbi.data.PlayerData;
import rbi.data.TeamData;
import rbi.managers.DataManager;
import rbi.data.ItemData;
import rbi.entities.Inventory;
import rbi.entities.PlayerCard;
import rbi.entities.ScoutingReport;
import rbi.items.Item;

class RosterState extends FlxState
{
    private var bg:FlxSprite;

    private var pitchers:Array<PlayerIcon> = new Array<PlayerIcon>();
    private var pitchIcon:FlxSprite = new FlxSprite();
    private var battingOrder:Array<PlayerIcon> = new Array<PlayerIcon>();
    private var battingIcon:FlxSprite = new FlxSprite();
    private var bench:Array<PlayerIcon> = new Array<PlayerIcon>();
    private var field:Map<String, PlayerIcon> = new Map<String, PlayerIcon>();
    private var points:Map<String, Point>;
    private var tweens:Array<FlxTween> = new Array<FlxTween>();
    private var inventoryButton:FlxExtendedSprite = new FlxExtendedSprite();
    private var scoutingButton:FlxExtendedSprite = new FlxExtendedSprite();
    private var scouting:ScoutingReport;

    private var lastClicked:PlayerIcon;

    override public function create():Void
    {
        super.create();

        // Keep track of the fielding points
        this.points = [
            'P' => new Point(600, 375),
            'C' => new Point(600, 490),
            '1B' => new Point(715, 375),
            '2B' => new Point(600, 260),
            '3B' => new Point(485, 375),
            'SS' => new Point(540, 310),
            'LF' => new Point(450, 200),
            'CF' => new Point(600, 150),
            'RF' => new Point(750, 200),
            'BO' => new Point(250, 640),
            'BI' => new Point(150, 625),
            'PL' => new Point(50, 75),
            'PI' => new Point(50, 10),
            'BN' => new Point(1200, 85),
            'IN' => new Point(825, 635),
            'SR' => new Point(995, 635),
        ];
        
        // Create an add the background right away
        this.bg = new FlxSprite();
        bg.loadGraphic(AssetPaths.background_manage__png);
        add(bg);

        // Handle drawing players on the field
        this.field = new Map<String, PlayerIcon>();
        for (position in DataManager.playerTeam.currentPositions.keys())
        {
            var icon:PlayerIcon = new PlayerIcon(DataManager.playerTeam.currentPositions[position], this.playerClicked);
            icon.setFieldMode();
            icon.x = this.points[position].x;
            icon.y = this.points[position].y;
            this.field[position] = icon;
            add(icon);
        }

        // Handle all pitching stuff
        this.pitchIcon.loadGraphic(AssetPaths.icon_baseball__png);
        this.pitchIcon.x = this.points['PI'].x;
        this.pitchIcon.y = this.points['PI'].y;
        add(this.pitchIcon);
        var count:Int = 0;
        for (pitcher in DataManager.playerTeam.pitchers)
        {
            if (pitcher != this.field['P'].data)
            {
                var icon:PlayerIcon = new PlayerIcon(pitcher, this.playerClicked);
                icon.x = this.points['PL'].x;
                icon.y = this.points['PL'].y + (count++ * 60);
                this.pitchers.push(icon);
                add(icon);
            }
        }

        // Handle all of the batting stuff
        this.battingIcon.loadGraphic(AssetPaths.icon_bat__png);
        this.battingIcon.x = this.points['BI'].x;
        this.battingIcon.y = this.points['BI'].y;
        add(this.battingIcon);
        count = 0;
        for (player in DataManager.playerTeam.battingOrder)
        {
            var icon:PlayerIcon = new BattingIcon(player, this.playerClicked);
            icon.y = this.points['BO'].y;
            icon.x = this.points['BO'].x + (count++ * 60);
            this.battingOrder.push(icon);
            add(icon);

        }

        // Handle all of the bench players
        count = 0;
        for (player in DataManager.playerTeam.bench)
        {
            var icon:PlayerIcon = new PlayerIcon(player, this.playerClicked);
            icon.x = this.points['BN'].x;
            icon.y = this.points['BN'].y + (count++ * 60);
            this.bench.push(icon);
            add(icon);
        }

        // Create the buttons we are interested in
        this.inventoryButton.loadGraphic(AssetPaths.button_edge__png);
        this.inventoryButton.x = this.points['IN'].x;
        this.inventoryButton.y = this.points['IN'].y;
        this.inventoryButton.mouseReleasedCallback = this.onInventoryButtonClick;
        add(this.inventoryButton);
        this.scoutingButton.loadGraphic(AssetPaths.button_edge__png);
        this.scoutingButton.x = this.points['SR'].x;
        this.scoutingButton.y = this.points['SR'].y;
        this.scoutingButton.mouseReleasedCallback = this.onScoutingClick;
        add(this.scoutingButton);

        this.scouting = new ScoutingReport(DataManager.currentOpponent, this.hideScoutingClick);
        add(this.scouting);

        var card = new PlayerCard(this.onCardClick);
        card.setPlayer(DataManager.playerTeam.players[0]);
        add(card);

        var inv = new Inventory(this.onInventoryClick);
        inv.x = 600;
        add(inv);
    }



    override public function destroy():Void
    {
        super.destroy();

        this.bg = FlxDestroyUtil.destroy(this.bg);
        this.pitchIcon = FlxDestroyUtil.destroy(this.pitchIcon);
        this.battingIcon = FlxDestroyUtil.destroy(this.battingIcon);
        this.inventoryButton = FlxDestroyUtil.destroy(this.inventoryButton);
        this.scoutingButton = FlxDestroyUtil.destroy(this.scoutingButton);
        this.scouting = FlxDestroyUtil.destroy(this.scouting);
        this.lastClicked = FlxDestroyUtil.destroy(this.lastClicked);

        this.pitchers = FlxDestroyUtil.destroyArray(this.pitchers);
        this.battingOrder = FlxDestroyUtil.destroyArray(this.battingOrder);
        this.bench = FlxDestroyUtil.destroyArray(this.bench);
        this.tweens = FlxDestroyUtil.destroyArray(this.tweens);

        for (key in this.field.keys())
        {
            FlxDestroyUtil.destroy(this.field[key]);
            this.field.remove(key);
        }
    }

    override public function update():Void
    {
        super.update();
    }

    private function playerClicked(thisIcon:PlayerIcon):Void
    {
        // Close the scouting report if they click on something else
        if (this.scouting.y < 1280)
        {
            this.tweens.push(FlxTween.tween(this.scouting, {y:1280}, 0.66, {ease:FlxEase.backInOut}));
        }

        // Check if there are active tweens, if there are don't allow interactions
        for (tween in this.tweens)
        {
            if (tween.active)
            {
                return;
            }
        }
        this.tweens = new Array<FlxTween>();

        if (this.lastClicked == null)
        {
            this.lastClicked = thisIcon;
            //thisIcon.setColorTransform(1, 0.5, 0.5, 1);
            thisIcon.color = 0xFF0000;
        }
        else
        {
            var lastIcon:PlayerIcon = this.lastClicked;
            //this.lastClicked.setColorTransform(1,1,1,1);
            this.lastClicked.color = 0xFFFFFF;
            this.lastClicked = null;
            if (lastIcon == thisIcon)
            {
                trace('Open player card');
            }
            else
            {
                // Get all the data we will need to swap people around
                var lastType = Type.getClass(lastIcon);
                var thisType = Type.getClass(thisIcon);
                var lastPitcherIndex:Int = this.pitchers.indexOf(lastIcon);
                var thisPitcherIndex:Int = this.pitchers.indexOf(thisIcon);
                var lastBenchIndex:Int = this.bench.indexOf(lastIcon);
                var thisBenchIndex:Int = this.bench.indexOf(thisIcon);
                var lastFieldPosition:String = '';
                var thisFieldPosition:String = '';
                for (key in ['P', 'C', '1B', '2B', '3B', 'SS', 'LF', 'CF', 'RF'])
                {
                    if (this.field[key] == lastIcon)
                    {
                        lastFieldPosition = key;
                    }
                    if (this.field[key] == thisIcon)
                    {
                        thisFieldPosition = key;
                    }
                }

                if (lastFieldPosition == 'P' || thisFieldPosition == 'P')
                {
                    if (lastPitcherIndex >= 0 || thisPitcherIndex >= 0)
                    {
                        trace('Swap pitchers');
                        this.tweens.push(FlxTween.tween(lastIcon, {x:thisIcon.x, y:thisIcon.y}, 0.5, {ease:FlxEase.backInOut}));
                        lastIcon.toggleIconMode();
                        this.tweens.push(FlxTween.tween(thisIcon, {x:lastIcon.x, y:lastIcon.y}, 0.5, {ease:FlxEase.backInOut}));
                        thisIcon.toggleIconMode();
                        var battingIcon:PlayerIcon = null;
                        for (batter in this.battingOrder)
                        {
                            if (lastIcon.data.number == batter.data.number || thisIcon.data.number == batter.data.number)
                            {
                                battingIcon = batter;
                                break;
                            }
                        }
                        var battingIndex:Int = this.battingOrder.indexOf(battingIcon);
                        var pitchIndex:Int = (lastPitcherIndex >= 0) ? lastPitcherIndex : thisPitcherIndex;
                        
                        var toField:PlayerIcon = this.pitchers[pitchIndex];
                        this.pitchers.splice(pitchIndex, 1);
                        var fromField:PlayerIcon = this.field['P'];
                        this.field['P'] = toField;
                        this.pitchers.insert(pitchIndex, fromField);

                        remove(this.battingOrder[battingIndex]);
                        var newBattingIcon:BattingIcon = new BattingIcon(toField.data, this.playerClicked);
                        this.tweens.push(FlxTween.color(newBattingIcon, 0.66, 0xFF0000, 0xFFFFFF));
                        newBattingIcon.x = this.battingOrder[battingIndex].x;
                        newBattingIcon.y = this.battingOrder[battingIndex].y;
                        this.battingOrder.splice(battingIndex, 1);
                        this.battingOrder.insert(battingIndex, newBattingIcon);
                        add(this.battingOrder[battingIndex]);
                    }
                    else
                    {
                        trace('Can only put in a pitcher from the pitching bench');
                    }
                    return;
                }

                if (lastType == rbi.data.BattingIcon || thisType == rbi.data.BattingIcon)
                {
                    if (lastType == thisType)
                    {
                        trace('Swap batting order');
                        this.tweens.push(FlxTween.tween(lastIcon, {x:thisIcon.x, y:thisIcon.y}, 0.5, {ease:FlxEase.backInOut}));
                        this.tweens.push(FlxTween.tween(thisIcon, {x:lastIcon.x, y:lastIcon.y}, 0.5, {ease:FlxEase.backInOut}));
                        var lastIndex:Int = this.battingOrder.indexOf(lastIcon);
                        var thisIndex:Int = this.battingOrder.indexOf(thisIcon);
                        if (thisIndex > lastIndex)
                        {
                            this.battingOrder.splice(thisIndex, 1);
                            this.battingOrder.splice(lastIndex, 1);
                            this.battingOrder.insert(lastIndex, thisIcon);
                            this.battingOrder.insert(thisIndex, lastIcon);
                        }
                        else
                        {
                            this.battingOrder.splice(lastIndex, 1);
                            this.battingOrder.splice(thisIndex, 1);
                            this.battingOrder.insert(thisIndex, lastIcon);
                            this.battingOrder.insert(lastIndex, thisIcon);
                        }
                    }
                    else
                    {
                        trace('Can only swap batting order from the batting order list');
                    }
                    return;
                }

                if (lastFieldPosition != '' || thisFieldPosition != '')
                {
                    if (lastBenchIndex >= 0 || thisBenchIndex >= 0)
                    {
                        trace('Swap fielding position from bench');
                        this.tweens.push(FlxTween.tween(lastIcon, {x:thisIcon.x, y:thisIcon.y}, 0.5, {ease:FlxEase.backInOut}));
                        lastIcon.toggleIconMode();
                        this.tweens.push(FlxTween.tween(thisIcon, {x:lastIcon.x, y:lastIcon.y}, 0.5, {ease:FlxEase.backInOut}));
                        thisIcon.toggleIconMode();

                        var battingIcon:PlayerIcon = null;
                        for (batter in this.battingOrder)
                        {
                            if (lastIcon.data.number == batter.data.number || thisIcon.data.number == batter.data.number)
                            {
                                battingIcon = batter;
                                break;
                            }
                        }
                        var battingIndex:Int = this.battingOrder.indexOf(battingIcon);
                        var benchIndex:Int = (lastBenchIndex >= 0) ? lastBenchIndex : thisBenchIndex;
                        var position:String = (lastFieldPosition != '') ? lastFieldPosition : thisFieldPosition;

                        var toField:PlayerIcon = this.bench[benchIndex];
                        this.bench.splice(benchIndex, 1);
                        var fromField:PlayerIcon = this.field[position];
                        this.field[position] = toField;
                        this.bench.insert(benchIndex, fromField);

                        remove(this.battingOrder[battingIndex]);
                        var newBattingIcon:BattingIcon = new BattingIcon(toField.data, this.playerClicked);
                        this.tweens.push(FlxTween.color(newBattingIcon, 0.66, 0xFF0000, 0xFFFFFF));
                        newBattingIcon.x = this.battingOrder[battingIndex].x;
                        newBattingIcon.y = this.battingOrder[battingIndex].y;
                        this.battingOrder.splice(battingIndex, 1);
                        this.battingOrder.insert(battingIndex, newBattingIcon);
                        add(this.battingOrder[battingIndex]);
                    }
                    else
                    {
                        trace('You can only swap a fielding position from the bench');
                    }
                    return;
                }

                if (lastPitcherIndex >= 0 && thisPitcherIndex >= 0)
                {
                    trace('Swap pitcher bench');
                    this.tweens.push(FlxTween.tween(lastIcon, {x:thisIcon.x, y:thisIcon.y}, 0.5, {ease:FlxEase.backInOut}));
                    this.tweens.push(FlxTween.tween(thisIcon, {x:lastIcon.x, y:lastIcon.y}, 0.5, {ease:FlxEase.backInOut}));
                    var lastIndex:Int = lastPitcherIndex;
                    var thisIndex:Int = thisPitcherIndex;
                    if (thisIndex > lastIndex)
                    {
                        this.pitchers.splice(thisIndex, 1);
                        this.pitchers.splice(lastIndex, 1);
                        this.pitchers.insert(lastIndex, thisIcon);
                        this.pitchers.insert(thisIndex, lastIcon);
                    }
                    else
                    {
                        this.pitchers.splice(lastIndex, 1);
                        this.pitchers.splice(thisIndex, 1);
                        this.pitchers.insert(thisIndex, lastIcon);
                        this.pitchers.insert(lastIndex, thisIcon);
                    }
                    return;
                }

                if (lastBenchIndex >= 0 && thisBenchIndex >= 0)
                {
                    trace('Swap bench');
                    this.tweens.push(FlxTween.tween(lastIcon, {x:thisIcon.x, y:thisIcon.y}, 0.5, {ease:FlxEase.backInOut}));
                    this.tweens.push(FlxTween.tween(thisIcon, {x:lastIcon.x, y:lastIcon.y}, 0.5, {ease:FlxEase.backInOut}));
                    var lastIndex:Int = lastBenchIndex;
                    var thisIndex:Int = thisBenchIndex;
                    if (thisIndex > lastIndex)
                    {
                        this.bench.splice(thisIndex, 1);
                        this.bench.splice(lastIndex, 1);
                        this.bench.insert(lastIndex, thisIcon);
                        this.bench.insert(thisIndex, lastIcon);
                    }
                    else
                    {
                        this.bench.splice(lastIndex, 1);
                        this.bench.splice(thisIndex, 1);
                        this.bench.insert(thisIndex, lastIcon);
                        this.bench.insert(lastIndex, thisIcon);
                    }
                    return;
                }

                if (lastPitcherIndex >= 0 && thisBenchIndex >= 0 || lastBenchIndex >= 0 && thisPitcherIndex >= 0)
                {
                    trace('Swap bench to pitching bench');
                    this.tweens.push(FlxTween.tween(lastIcon, {x:thisIcon.x, y:thisIcon.y}, 0.5));
                    this.tweens.push(FlxTween.tween(thisIcon, {x:lastIcon.x, y:lastIcon.y}, 0.5));
                    return;
                }
                
            }
        }
    }

    private function onInventoryButtonClick(s:FlxExtendedSprite, x:Int, y:Int):Void
    {
        trace('Inventory clicked');
    }

    private function onScoutingClick(s:FlxExtendedSprite, x:Int, y:Int):Void
    {
        trace('Scouting clicked');
        this.tweens.push(FlxTween.tween(this.scouting, {y:25}, 0.5, {ease:FlxEase.backInOut}));
    }

    private function hideScoutingClick(s:FlxExtendedSprite, x:Int, y:Int):Void
    {
        trace('Hide scouting');
        this.tweens.push(FlxTween.tween(this.scouting, {y:1280}, 0.5, {ease:FlxEase.backInOut}));
    }

    private function onCardClick(s:FlxExtendedSprite, x:Int, y:Int):Void
    {
        trace('Card clicked');
    }

    private function onInventoryClick(s:FlxExtendedSprite, x:Int, y:Int):Void
    {
        trace('Inventory clicked');
    }
}

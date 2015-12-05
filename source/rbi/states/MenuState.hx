package rbi.states;

import flash.system.System;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxMath;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;

import rbi.managers.DataManager;
import rbi.managers.ItemManager;
import rbi.data.TeamData;
import rbi.states.RosterState;

// for testing
import flash.geom.Vector3D;
import rbi.simulations.FieldingSimulation;

class MenuState extends FlxState
{
    private var backgroundSprite:FlxSprite;

    private var newGameButton:FlxButton;
    private var optionsButton:FlxButton;
    #if desktop
    private var exitButton:FlxButton;
    #end

    override public function create():Void
    {
        if (FlxG.sound.music == null)
        {
            #if flash
            FlxG.sound.playMusic(AssetPaths.TestMusic__mp3, DataManager.musicVolume, true);
            #else
            FlxG.sound.playMusic(AssetPaths.TestMusic__ogg, DataManager.musicVolume, true);
            #end
        }

        backgroundSprite = new FlxSprite();
        backgroundSprite.loadGraphic(AssetPaths.TestImage__png);
        add(backgroundSprite);

        newGameButton = new FlxButton(0, 0, "New Game", newGameClickHandler);
        newGameButton.x = 0;
        newGameButton.y = 0;
        add(newGameButton);

        optionsButton = new FlxButton(0, 0, "Options", optionsClickHandler);
        optionsButton.x = 0;
        optionsButton.y = 50;
        add(optionsButton);

        #if desktop
        exitButton = new FlxButton(0, 0, "Exit", exitClickHandler);
        exitButton.x = 0;
        exitButton.y = 100;
        add(exitButton);
        #end

        FlxG.camera.fade(FlxColor.BLACK, .33, true);

        super.create();
    }

    override public function destroy():Void
    {
        backgroundSprite = FlxDestroyUtil.destroy(backgroundSprite);
        newGameButton = FlxDestroyUtil.destroy(newGameButton);
        optionsButton = FlxDestroyUtil.destroy(optionsButton);
        #if desktop
        exitButton = FlxDestroyUtil.destroy(exitButton);
        #end
        super.destroy();
    }

    override public function update():Void
    {
        super.update();
    }

    private function newGameClickHandler():Void
    {
        generateData();
        FlxG.camera.fade(FlxColor.BLACK, .33, false, function()
        {
            FlxG.switchState(new RosterState());
        });
    }

    private function optionsClickHandler():Void
    {
        FlxG.camera.fade(FlxColor.BLACK, .33, false, function()
        {
            FlxG.switchState(new OptionsState());
        });
    }

    #if desktop
    private function exitClickHandler():Void
    {
        System.exit(0);
    }
    #end

    private function generateData():Void
    {
        DataManager.itemManager = new ItemManager();
        DataManager.teams = new Array<TeamData>();
        for (i in 0...6)
        {
            DataManager.teams.push(new TeamData(Std.string(Std.random(900000)+100000), Std.string(Std.random(900000)+100000)));
        }
        DataManager.playerTeam = DataManager.teams[0];
        DataManager.currentOpponent = DataManager.teams[1];

        var team:TeamData = DataManager.playerTeam;

        // test fielding sim
        var testBallVector:Vector3D = new Vector3D(-90,260,260); // deep left field
        testBallVector.normalize();
        testBallVector.scaleBy(90);
        var fieldingSim:FieldingSimulation = new FieldingSimulation(team, testBallVector);
        var fieldingSimResults:Array<String> = fieldingSim.run();
        for (i in fieldingSimResults) trace(i);
    }
}

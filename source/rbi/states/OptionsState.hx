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

class OptionsState extends FlxState
{
    private var backButton:FlxButton;

    override public function create():Void
    {
        backButton = new FlxButton(0, 0, "Back", backClickHandler);
        backButton.x = 0;
        backButton.y = 0;
        add(backButton);

        FlxG.camera.fade(FlxColor.BLACK, .33, true);

        super.create();
    }

    override public function destroy():Void
    {
        backButton = FlxDestroyUtil.destroy(backButton);

        super.destroy();
    }

    override public function update():Void
    {
        super.update();
    }

    private function backClickHandler():Void
    {
        FlxG.camera.fade(FlxColor.BLACK, .33, false, function() {
            FlxG.switchState(new MenuState());
        });
    }
}
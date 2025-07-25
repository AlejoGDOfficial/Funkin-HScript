package core.backend;

import core.backend.Conductor;

import flixel.util.FlxColor;

import hscript.ScriptState;

class MusicBeatState extends ScriptState
{
    public var camGame:FlxCamera = FlxG.camera;

    public var camHUD:FlxCamera = new FlxCamera();

    public var curStep:Int = 0;
    public var curBeat:Int = 0;
    public var curSection:Int = 0;

    override public function create()
    {
        super.create();

        camGame = FlxG.camera;

        camHUD.bgColor = FlxColor.TRANSPARENT;
        FlxG.cameras.add(camHUD, false);
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        updateMusic();
    }

    private function updateMusic()
    {
        if (curStep != Conductor.curStep)
        {
            curStep = Conductor.curStep;

            stepHit(curStep);
        }
        
        if (curBeat != Conductor.curBeat)
        {
            curBeat = Conductor.curBeat;

            beatHit(curBeat);
        }
        
        if (curSection != Conductor.curSection)
        {
            curSection = Conductor.curSection;

            sectionHit(curSection);
        }
    }

    public function stepHit(curStep:Int) {}

    public function beatHit(curBeat:Int) {}

    public function sectionHit(curSection:Int) {}
}
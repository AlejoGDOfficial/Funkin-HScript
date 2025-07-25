package funkin.visuals.game;

import core.enums.NoteType;
import core.enums.NoteState;
import core.backend.Conductor;

import flixel.math.FlxAngle;
import flixel.math.FlxRect;

import hscript.ScriptSprite;

class Note extends ScriptSprite
{
    public var time:Float;
    public var data:Int;
    public var length:Float;
    public var variant:String;
    
    public var noteType:NoteType;
    public var state:NoteState = NoteState.NEUTRAL;

    public var children:Array = [];

    public var strum:Strum;
    public var splash:Splash;

    public var spawned:Bool = false;

    public var speed:Float = 1;

    public var texture(default, set):String;

    public var copyDirection:Bool = true;
    public var direction:Float = 0;

    public var copyAlpha:Bool = true;
    public var alphaOffset:Float = 1;

    public var copyAngle:Bool = true;

    override public function new(theTime:Float, theData:Int, theLength:Float, theVariant:String, theNoteType:NoteType, theStrum:Strum, theSplash:Splash)
    {
        super();

        time = theTime;
        data = theData;
        length = theLength;
        variant = theVariant;

        noteType = theNoteType;

        strum = theStrum;
        splash = theSplash;

        texture = 'note';

        x = strum.x + strum.width / 2 - width / 2;
        y = FlxG.height * 4;

        alphaOffset = noteType == NoteType.NORMAL ? 1 : 0.5;
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if (copyDirection)
            direction = strum.direction;

        if (copyAlpha)
            alpha = strum.alpha * alphaOffset;
        
        if (copyAngle)
            angle = strum.angle;

		var radDir = FlxAngle.asRadians(direction);

        var theX = strum.width / 2 - width / 2;
        var theY = (time - Conductor.songPosition) * 0.45 * speed + (noteType == NoteType.NORMAL ? 0 : strum.height / 2);

		x = strum.x + Math.cos(radDir) * theX + Math.sin(radDir) * theY;
        
		y = strum.y + Math.cos(radDir) * theY + Math.sin(radDir) * theX;

        if (noteType != NoteType.NORMAL && state == NoteState.HIT)
            clipRect = FlxRect.get(0, (strum.y + strum.height / 2 - y) / scale.y, frameWidth, frameHeight);
    }

    public function set_texture(value:String):String
    {
        texture = value;

		frames = Paths.getSparrowAtlas('notes/' + texture);

		var color:String = ['purple', 'blue', 'green', 'red'][data];
				
		animation.addByPrefix('idle',
			switch (noteType)
			{
				case NoteType.NORMAL:
					color + '0';
				case NoteType.SUSTAIN:
					color + ' hold piece';
				case NoteType.SUSTAIN_END:
					color + ' hold end';
			},
		24, false);

		animation.play('idle', true);

        scale.set(0.7, noteType == NoteType.SUSTAIN ? 2.05 : 0.7);

        updateHitbox();
		centerOffsets();
		centerOrigin();

        return texture;
    }
}
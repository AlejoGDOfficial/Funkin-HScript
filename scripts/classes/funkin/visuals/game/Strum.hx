package funkin.visuals.game;

import core.enums.CharacterType;

import hscript.ScriptSprite;

class Strum extends ScriptSprite
{
    public var data:Int;

    public var texture(default, set):String;

    public var type:CharacterType;

    public var strumline:StrumLine;

    public var direction:Float = 0;
    
    public function new(theData:Int, theType:CharacterType, theStrumLine:StrumLine)
    {
        super();

        data = theData;

        type = theType;

        strumline = theStrumLine;

        texture = 'note';

		x = 160 * 0.7 * data;

		if (type == CharacterType.OPPONENT)
			x += 50;
		else
			x += FlxG.width - (160 * 0.7 * 5) + 50;

        y = 50;
    }

    public function set_texture(value:String):String
    {
        texture = value;

        frames = Paths.getSparrowAtlas('notes/' + texture);

		var anim:String = ['left', 'down', 'up', 'right'][data];
        
		animation.addByPrefix('idle', 'arrow' + anim.toUpperCase(), 24, false);
		animation.addByPrefix('pressed', anim + ' press', 24, false);
		animation.addByPrefix('hit', anim + ' confirm', 24, false);

		scale.set(0.7, 0.7);

		updateHitbox();

		animation.onFrameChange.add((name:String, frameNumber:Int, frameIndex:Int) -> {
            centerOffsets();
            centerOrigin();
		});

        animation.onFinish.add(
            (name:String) -> {
                if (name == 'hit' && strumline.variables.get('botplay'))
                    animation.play('idle', true);
            }
        );

		animation.play('idle', true);

        return texture;
    }
}
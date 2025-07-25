package funkin.visuals.game;

import hscript.ScriptSprite;

import utils.ALEParserHelper;

import core.enums.CharacterType;

class Character extends ScriptSprite
{
    public var name(default, set):String;

    public var data(default, set):Dynamic;
    
    public var texture(default, set):String;

    public var type:CharacterType;

    public var offsetsMap:StringMap = new StringMap();

    public function new(x:Float, y:Float, name:String, type:String)
    {
        super();
        
        this.type = type;

        this.name = name;
        
        if (animation.exists('idle'))
            animation.play('idle', true);
        else if (animation.exists('danceLeft'))
            animation.play('danceLeft', true);

        this.x = x + data.position[0];
        this.y = y + data.position[1];
    }

    public var idleTimer:Float = 0;
    
    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if (idleTimer > 0)
            idleTimer -= elapsed;
    }

    public function dance(modulo:Int)
    {
        if (idleTimer > 0)
            return;

        if (modulo == 0)
        {
            if (animation.exists('idle'))
                animation.play('idle', true);
            else if (animation.exists('danceLeft'))
                animation.play('danceLeft', true);
        } else {
            if (animation.exists('danceRight'))
                animation.play('danceRight', true);
        }
    }

    public function set_name(value:String):String
    {
        name = value;

        data = ALEParserHelper.getALECharacter(name);

        return name;
    }

    public function set_data(value:ALECharacter):ALECharacter
    {
        data = value;

        texture = data.image;

        return data;
    }

    public function set_texture(value:String):String
    {
        texture = value;

        frames = Paths.getAtlas(value);
        
        for (anim in data.animations)
        {
            if (anim.indices != null && anim.indices.length > 0)
                animation.addByIndices(anim.animation, anim.prefix, anim.indices, "", anim.framerate, anim.looped);
            else
                animation.addByPrefix(anim.animation, anim.prefix, anim.framerate, anim.looped);

            var offsets:Array<Int> = anim.offset;

            offsetsMap.set(anim.animation, offsets != null && offsets.length > 1 ? [offsets[0], offsets[1]] : [0, 0]);
        }

        flipX = data.flipX == (type != CharacterType.PLAYER);

        if (animation.exists('idle'))
            animation.play('idle', true);
        else if (animation.exists('danceLeft'))
            animation.play('danceLeft', true);

        animation.onFrameChange.add(
            function (name:String, _, __)
            {
                offset.x = offsetsMap.get(name)[0];
                offset.y = offsetsMap.get(name)[1];
            }
        );

        animation.onFinish.add(
            function (name:String)
            {
                if (animation.exists(name + '-loop'))
                    animation.play(name + '-loop', true);
            }
        );

        return texture;
    }
}
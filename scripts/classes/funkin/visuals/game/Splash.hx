package funkin.visuals.game;

import hscript.ScriptSprite;

class Splash extends ScriptSprite
{
    public var data:Int;

    public var strum:Strum;

    public var texture(default, set):String;

    public function new(theData:Int, theStrum:Strum)
    {
        super();

        data = theData;
        
        strum = theStrum;

        texture = 'splash';

        visible = false;
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        x = strum.x + strum.width / 2 - width / 2;
        y = strum.y + strum.height / 2 - width / 2;

        angle = strum.angle;

        alpha = strum.alpha * 0.6;
        
        if (cameras != strum.cameras)
            cameras = strum.cameras;
    }

    function set_texture(value:String):String
    {
        texture = value;

        frames = Paths.getSparrowAtlas('splashes/' + texture);

        var anim:String = ['purple', 'blue', 'green', 'red'][data];
        
        animation.addByPrefix('splash', 'note splash ' + anim + ' 1', 24, false);

        animation.onFrameChange.add((name:String, frameNumber:Int, frameIndex:Int) -> {
            centerOffsets();
            centerOrigin();
            
            visible = true;

            x = strum.x + strum.width / 2 - width / 2;
            y = strum.y + strum.width / 2 - width / 2;
        });

        animation.onFinish.add((name:String) -> {
            visible = false;
        });

        scale.set(0.85, 0.85);

        updateHitbox();

        return texture;
    }
}
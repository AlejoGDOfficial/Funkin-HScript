package funkin.visuals.game;

import hscript.ScriptSprite;

class Icon extends ScriptSprite
{
    public var texture(default, set):String;
    public function set_texture(value:String):String
    {
        texture = value;

        var graphic = Paths.image('icons/' + texture) ?? Paths.image('icons/face');

        loadGraphic(graphic, true, Math.floor(graphic.width / 2), Math.floor(graphic.height));

        animation.add(texture, [0, 1], 0, false);
        animation.play(texture);

        updateHitbox();

        return texture;
    }

    override public function new(name:String)
    {
        super();

        texture = name;
    }
}
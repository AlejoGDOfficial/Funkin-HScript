package funkin.visuals.objects;

import flixel.math.FlxRect;
import flixel.util.FlxColor;

import hscript.ScriptSpriteGroup;

import core.enums.Orientation;

class Bar extends ScriptSpriteGroup
{
    public var percent(default, set):Float;
    function set_percent(value:Float):Float
    {
        percent = FlxMath.bound(value, 0, 100);

        var leftWidth:Float = leftBar.width * (percent / 100);

        if (orientation == Orientation.LEFT)
        {
            leftBar.clipRect = new FlxRect(0, 0, leftWidth, height);
            rightBar.clipRect = new FlxRect(leftWidth, 0, leftBar.width - leftWidth, height);
        } else if (orientation == Orientation.RIGHT) {
            leftBar.clipRect = new FlxRect(0, 0, leftBar.width - leftWidth, height);
            rightBar.clipRect = new FlxRect(leftBar.width - leftWidth, 0, leftWidth, height);
        }

        return percent;
    }
    
    public var orientation(default, set):Orientation;
    function set_orientation(value:String):Orientation
    {
        orientation = value;

        percent = percent;

        return orientation;
    }

    public var middlePoint(get, never):Float;
    function get_middlePoint():Float
    {
        return x + width * (orientation == Orientation.LEFT ? percent : 100 - percent) / 100;
    }

    public var bg:FlxSprite;
    public var leftBar:FlxSprite;
    public var rightBar:FlxSprite;

    override public function new(?x:Float, ?y:Float, ?width:Int, ?height:Int)
    {
        super();

        bg = new FlxSprite().makeGraphic(width ?? 610, height ?? 20, FlxColor.BLACK);
        add(bg);

        leftBar = new FlxSprite().makeGraphic((width ?? 610) - 10, (height ?? 20) - 10);
        add(leftBar);
        leftBar.x = leftBar.y = 5;

        rightBar = new FlxSprite().makeGraphic((width ?? 610) - 10, (height ?? 20) - 10);
        add(rightBar);
        rightBar.x = rightBar.y = 5;

        this.x = x ?? 0;
        this.y = y ?? 0;

        percent = 50;

        orientation = Orientation.LEFT;
    }
}
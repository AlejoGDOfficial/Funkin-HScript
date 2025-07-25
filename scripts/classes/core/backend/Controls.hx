package core.backend;

import flixel.input.keyboard.FlxKey;

class Controls
{
    public static var controls:Controls = {
        notes: {
            left: [FlxKey.LEFT, FlxKey.D],
            down: [FlxKey.DOWN, FlxKey.F],
            up: [FlxKey.UP, FlxKey.J],
            right: [FlxKey.RIGHT, FlxKey.K]
        }
    }

    public static var LEFT_P(get, never):Bool;
    static function get_LEFT_P():Bool
    {
        return FlxG.keys.anyJustPressed(controls.notes.left);
    }

    public static var DOWN_P(get, never):Bool;
    static function get_DOWN_P():Bool
    {
        return FlxG.keys.anyJustPressed(controls.notes.down);
    }

    public static var UP_P(get, never):Bool;
    static function get_UP_P():Bool
    {
        return FlxG.keys.anyJustPressed(controls.notes.up);
    }

    public static var RIGHT_P(get, never):Bool;
    static function get_RIGHT_P():Bool
    {
        return FlxG.keys.anyJustPressed(controls.notes.right);
    }

    public static var LEFT_R(get, never):Bool;
    static function get_LEFT_R():Bool
    {
        return FlxG.keys.anyJustReleased(controls.notes.left);
    }

    public static var DOWN_R(get, never):Bool;
    static function get_DOWN_R():Bool
    {
        return FlxG.keys.anyJustReleased(controls.notes.down);
    }

    public static var UP_R(get, never):Bool;
    static function get_UP_R():Bool
    {
        return FlxG.keys.anyJustReleased(controls.notes.up);
    }

    public static var RIGHT_R(get, never):Bool;
    static function get_RIGHT_R():Bool
    {
        return FlxG.keys.anyJustReleased(controls.notes.right);
    }
}
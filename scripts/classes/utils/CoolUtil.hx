package utils;

import flixel.util.FlxColor;

class CoolUtil
{
	public static function fpsLerp(v1:Float, v2:Float, ratio:Float):Float
    {
		return FlxMath.lerp(v1, v2, fpsRatio(ratio));
    }

	public static function fpsRatio(ratio:Float)
    {
		return FlxMath.bound(ratio * FlxG.elapsed * 60, 0, 1);
    }

    public static function resetGame()
    {
        FlxG.switchState(new CustomState('Main'));
    }
	
	public static function colorFromArray(arr:Array<Int>):Int
    {
    	return FlxColor.fromRGB(arr[0], arr[1], arr[2]);
    }
}
function onUpdate(elapsed:Float)
{
    if (FlxG.keys.justPressed.R)
    {
        if (FlxG.sound.music != null)
            FlxG.sound.music.pause();

        resetCustomState();
    }
}
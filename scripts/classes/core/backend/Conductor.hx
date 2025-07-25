package core.backend;

class Conductor
{
    static var constants:StringMap = [
        'bpm' => 100,
        'beatsPerSection' => 4,
        'stepsPerBeat' => 4
    ];

    public static var bpm(get, set):Float;
    public static function get_bpm():Float
    {
        return constants.get('bpm');
    }
    public static function set_bpm(value:Float):Float
    {
        constants.set('bpm', value);
        
        return bpm;
    }

    public static var stepsPerBeat(get, set):Float;
    public static function get_stepsPerBeat():Float
    {
        return constants.get('stepsPerBeat');
    }
    public static function set_stepsPerBeat(value:Float):Float
    {
        constants.set('stepsPerBeat', value);
        
        return stepsPerBeat;
    }

    public static var beatsPerSection(get, set):Float;
    public static function get_beatsPerSection():Float
    {
        return constants.get('beatsPerSection');
    }
    public static function set_beatsPerSection(value:Float):Float
    {
        constants.set('beatsPerSection', value);
        
        return beatsPerSection;
    }

    public static var crochet(get, never):Float;
    public static function get_crochet()
    {
        return 60 / bpm * 1000;
    }

    public static var stepCrochet(get, never):Float;
    public static function get_stepCrochet():Float
    {
        return crochet / stepsPerBeat;
    }

    public static var sectionCrochet(get, never):Float;
    public static function get_sectionCrochet():Float
    {
        return crochet * beatsPerSection;
    }

    public static var songLength(get, never):Float;
    public static function get_songLength():Float
    {
        return FlxG.sound.music == null ? 0 : FlxG.sound.music.length;
    }

    public static var songPosition(get, never):Float;
    public static function get_songPosition():Float
    {
        return FlxG.sound.music == null ? 0 : FlxG.sound.music.time;
    }

    public static var curStep(get, never):Int;
    public static function get_curStep():Int
    {
        return Math.floor(songPosition / 1000 * bpm / 15);
    }

    public static var curBeat(get, never):Int;
    public static function get_curBeat():Int
    {
        return Math.floor(curStep / stepsPerBeat);
    }

    public static var curSection(get, never):Int;
    public static function get_curSection():Int
    {
        return Math.floor(curBeat / beatsPerSection);
    }
}
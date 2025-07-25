package core.enums;

class Rank
{
    public static var PERFECT:String = 'perfect';
    public static var SICK:String = 'sick';
    public static var EXCELLENT:String = 'excellent';
    public static var GREAT:String = 'great';
    public static var GOOD:String = 'good';
    public static var LOSS:String = 'loss';

    public static function toString(rank:Null):String
    {
        return switch(rank)
        {
            case null:
                '[N/A]';
            case LOSS:
                'L';
            case GOOD:
                'G';
            case GREAT:
                'G+';
            case EXCELLENT:
                'E';
            case SICK:
                'S';
            case PERFECT:
                'S++';
        }
    }

    public static function toColor(rank:Null):Int
    {
        return switch(rank)
        {
            case null:
                0xFF909090;
            case LOSS:
                0xFFFF0000;
            case GOOD:
                0xFFFFAE00;
            case GREAT:
                0xFFFFFF00;
            case EXCELLENT:
                0xFF66FF66;
            case SICK:
                0xFF00FFFF;
            case PERFECT:
                0xFFFF00FF;
        }
    }
}
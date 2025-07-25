package funkin.groups;

class CharacterTypeGroup
{
    public var players:Array = [];
    public var opponents:Array = [];
    public var extras:Array = [];

    public function new() {}

    public var all(get, never):Array;
    function get_all():Array
    {
        return players.concat(opponents).concat(extras);
    }
}
package funkin.states;

import flixel.input.keyboard.FlxKey;
import flixel.group.FlxTypedGroup;
import flixel.FlxObject;
import flixel.ui.FlxBar;
import flixel.text.FlxTextFormat;
import flixel.text.FlxTextFormatMarkerPair;

import core.enums.CharacterType;
import core.enums.Orientation;
import core.enums.Rank;
import core.enums.Rating;

import core.backend.Conductor;
import core.backend.MusicBeatState;

import funkin.visuals.game.StrumLine;
import funkin.visuals.game.Character;
import funkin.visuals.game.Icon;
import funkin.visuals.objects.Bar;
import funkin.groups.CharacterTypeGroup;

import utils.CoolUtil;
import utils.ALEParserHelper;

class PlayState extends MusicBeatState
{
    public var strumlines:CharacterTypeGroup = new CharacterTypeGroup();

    public var characters:CharacterTypeGroup = new CharacterTypeGroup();

    public var noteCombo:Int = 0;

    public var score(get, never):Int;

    public var misses:Int = 0;
    
    public var sicks:Int = 0;
    public var goods:Int = 0;
    public var bads:Int = 0;
    public var shits:Int = 0;

    public var accuracy(get, never):Float;

    public var rank(get, never):Rank;

    public var health(default, set):Float = 50;

    public var healthBar:Bar;

    public var scoreText:FlxText;

    public var opponentIcon:Icon;

    public var playerIcon:Icon;

    public var camPosition:FlxObject;

    public var cameraZoom:Float = 1;

    private var charactersArray:Array = [];

    public var SONG:Dynamic;

    public var STAGE:Dynamic;

    public function new(songName:String, diff:String)
    {
        super();

        SONG = ALEParserHelper.getALESong(Json.parse(File.getContent(Paths.getPath('songs/' + songName + '/charts/' + diff +  '.json'))));

        FlxG.sound.playMusic(Paths.returnSound('songs/' + songName + '/song/Voices'));

        STAGE = ALEParserHelper.getALEStage(SONG.stage);
    }

    override function create()
    {
        super.create();

        Conductor.bpm = SONG.bpm;

		camPosition = new FlxObject(0, 0, 1, 1);
		
		camGame.target = camPosition;
        camGame.followLerp = 0.04 * STAGE.cameraSpeed;

        cameraZoom = STAGE.cameraZoom;

        for (index => char in SONG.characters)
        {
            var notes = [
                for (section in SONG.sections)
                    for (note in section.notes)
                        if (note[4] == index && note[0] > FlxG.sound.music.time)
                            [note[0], note[1], note[2], note[3]]
            ];

            var charPos = switch (char[1])
            {
                case CharacterType.PLAYER:
                    STAGE.playersPosition[characters.players.length];
                case CharacterType.OPPONENT:
                    STAGE.opponentsPosition[characters.opponents.length];
                case CharacterType.EXTRA:
                    STAGE.extrasPosition[characters.extras.length];
            };

            var charArr:Array = switch (char[1])
            {
                case CharacterType.PLAYER:
                    characters.players;
                case CharacterType.OPPONENT:
                    characters.opponents;
                case CharacterType.EXTRA:
                    characters.extras;
            };

            var character:Character = new Character(charPos[0], charPos[1], char[0], char[1]);
            add(character);

            charArr.push(character);
            charactersArray.push(character);
            
            var strl = new StrumLine(notes, char[1], character, Conductor.bpm);
            add(strl);
            strl.cameras = [camHUD];
            strl.speed = SONG.speed;
                
            if (char[1] == CharacterType.PLAYER)
            {
                strl.hitCallback = function (note:Note, rating:Null)
                {
                    switch (rating)
                    {
                        case Rating.SICK:
                            sicks++;
                        case Rating.GOOD:
                            goods++;
                        case Rating.BAD:
                            bads++;
                        case Rating.SHIT:
                            shits++;
                    }
                    
                    health += 1.5;
                };

                strl.missCallback = (note:Note) -> {
                    misses++;

                    health -= 2.5;
                }
            }

            var strlArr:Array = switch (char[1])
            {
                case CharacterType.PLAYER:
                    strumlines.players;
                case CharacterType.OPPONENT:
                    strumlines.opponents;
                case CharacterType.EXTRA:
                    strumlines.extras;
            };

            strlArr.push(strl);
        }

        var colors:Dynamic = {
            player: characters.players[0] == null ? characters.extras[0].data.barColor : characters.players[0].data.barColor,
            opponent: characters.opponents[0] == null ? characters.extras[0].data.barColor : characters.opponents[0].data.barColor
        };
        
		healthBar = new Bar(null, FlxG.height - 75);
		add(healthBar);
		healthBar.cameras = [camHUD];
		healthBar.x = FlxG.width / 2 - healthBar.width / 2;
        healthBar.leftBar.color = CoolUtil.colorFromArray(colors.opponent);
        healthBar.rightBar.color = CoolUtil.colorFromArray(colors.player);
        healthBar.orientation = Orientation.RIGHT;

		scoreText = new FlxText(0, healthBar.y + healthBar.height + 20, FlxG.width, "", 16);
		scoreText.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, 'center');
		//scoreText.borderStyle = 'outline';
		scoreText.borderSize = 1;
		scoreText.borderColor = FlxColor.BLACK;
		scoreText.borderSize = 1.25;
		add(scoreText);
		scoreText.cameras = [camHUD];
		scoreText.applyMarkup('Score: ' + score + '    Misses: ' + misses + '    Rating: *' + Rank.toString(rank) + '*', [new FlxTextFormatMarkerPair(new FlxTextFormat(Rank.toColor(rank)), '*')]);

        var icons:Dynamic = {
            player: characters.players[0] == null ? characters.extras[0].data.icon : characters.players[0].data.icon,
            opponent: characters.opponents[0] == null ? characters.extras[0].data.icon : characters.opponents[0].data.icon
        };

        opponentIcon = new Icon(icons.opponent);

        playerIcon = new Icon(icons.player);
        playerIcon.flipX = true;

        for (icon in [opponentIcon, playerIcon])
        {
            icon.cameras = [camHUD];
            add(icon);
            icon.y = healthBar.y + healthBar.height / 2 - icon.height / 2;
        }

        moveCamera(SONG.sections[Conductor.curSection]);

        FlxG.sound.music.time = 0;
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        camGame.zoom = CoolUtil.fpsLerp(camGame.zoom, cameraZoom, 0.05);
        camHUD.zoom = CoolUtil.fpsLerp(camHUD.zoom, 1, 0.05);

        if (FlxG.keys.justPressed.R)
        {
            if (FlxG.sound.music != null)
                FlxG.sound.music.pause();

            CoolUtil.resetGame();
        }
        
        if (FlxG.keys.anyJustPressed([FlxKey.ENTER, FlxKey.SPACE]))
            FlxG.sound.music.playing ? FlxG.sound.music.pause() : FlxG.sound.music.resume();

        for (icon in [opponentIcon, playerIcon])
        {
            icon.scale.x = CoolUtil.fpsLerp(icon.scale.x, 1, 0.275);
            icon.scale.y = CoolUtil.fpsLerp(icon.scale.y, 1, 0.275);
            icon.updateHitbox();
            icon.y = healthBar.y + healthBar.height / 2 - icon.height / 2;
        }

        playerIcon.x = healthBar.middlePoint - playerIcon.width / 10;
        opponentIcon.x = healthBar.middlePoint - opponentIcon.width + opponentIcon.width / 10;
    }

    override public function beatHit(curBeat:Int)
    {
        super.beatHit(curBeat);

        if (curBeat % 4 == 0)
        {
            camGame.zoom += 0.015;
            camHUD.zoom += 0.03;
        }

        for (icon in [opponentIcon, playerIcon])
        {
            icon.scale.x = icon.scale.y = 1.25;
            icon.updateHitbox();
        }

        for (character in characters.all)
            character.dance(curBeat % 2);
    }

    override public function sectionHit(curSection:Int)
    {
        super.sectionHit(curSection);

        moveCamera(SONG.sections[curSection]);
    }

    public function moveCamera(section:Null)
    {
        if (section == null)
            return;
        
        var char:Character = charactersArray[section.focus];

        if (char == null)
            return;

        camPosition.x = char.getMidpoint().x;
        camPosition.y = char.getMidpoint().y + char.data.cameraPosition[1];
        
        switch (char.type)
        {
            case CharacterType.OPPONENT:
                camPosition.x += 150;
                camPosition.y -= 100;
                camPosition.x += char.data.cameraPosition[0] + STAGE.opponentsCamera[characters.opponents.indexOf(char)][0];
                camPosition.y += STAGE.opponentsCamera[characters.opponents.indexOf(char)][1];
            case CharacterType.PLAYER:
                camPosition.x -= 100;
                camPosition.y -= 100;
                camPosition.x -= char.data.cameraPosition[0] - STAGE.playersCamera[characters.players.indexOf(char)][0];
                camPosition.y += STAGE.playersCamera[characters.players.indexOf(char)][1];
            case CharacterType.EXTRA:
                camPosition.x += char.data.cameraPosition[0] + STAGE.extrasCamera[characters.extras.indexOf(char)][0];
                camPosition.y += STAGE.extrasCamera[characters.extras.indexOf(char)][1];
        }
    }
    
    public function set_health(value:Float):Float
    {
        health = FlxMath.bound(value, 0, 100);

        if (healthBar != null)
            healthBar.percent = health;

        if (opponentIcon != null)
        {
            opponentIcon.animation.curAnim.curFrame = health > 80 ? 1 : 0;
            opponentIcon.updateHitbox();
        }

        if (playerIcon != null)
        {
            playerIcon.animation.curAnim.curFrame = health < 20 ? 1 : 0;
            playerIcon.updateHitbox();
        }

        if (scoreText != null)
		    scoreText.applyMarkup('Score: ' + score + '    Misses: ' + misses + '    Rating: *' + Rank.toString(rank) + '*' + (rank == null ? '' : ' - ' + FlxMath.roundDecimal(accuracy, 2) + '%'), [new FlxTextFormatMarkerPair(new FlxTextFormat(Rank.toColor(rank)), '*')]);  

        return health;
    }
    
    public function get_score():Int
    {
        return sicks * 350 + goods * 200 + bads * 100 + misses * -100;
    }

    public function get_accuracy():Float
    {
        var total:Int = sicks + goods + bads + shits + misses;
        var maxScore:Int = total * 100;
        var score:Int = sicks * 100 + goods * 75 + bads * 40 + shits * 20;
        
        return total == 0 ? 0 : score / total;
    }

    public function get_rank():Rank
    {
        if (accuracy <= 0)
            return null;

        if (accuracy < 40)
            return Rank.LOSS;
        else if (accuracy < 55)
            return Rank.GOOD;
        else if (accuracy < 70)
            return Rank.GREAT;
        else if (accuracy < 85)
            return Rank.EXCELLENT;
        else if (accuracy < 100)
            return Rank.SICK;
        else
            return Rank.PERFECT;
    }
}
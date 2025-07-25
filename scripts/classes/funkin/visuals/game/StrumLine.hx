package funkin.visuals.game;

import hscript.ScriptGroup;

import core.backend.Conductor;
import core.backend.Controls;

import core.enums.CharacterType;
import core.enums.NoteState;
import core.enums.NoteType;
import core.enums.Rating;

import flixel.util.FlxSort;

import funkin.visuals.game.Strum;
import funkin.visuals.game.Splash;
import funkin.visuals.game.Note;

class StrumLine extends ScriptGroup
{
    public var strums:FlxTypedGroup;
    public var sustains:FlxTypedGroup;
    public var notes:FlxTypedGroup;
    public var splashes:FlxTypedGroup;

    public var hitCallback:Note -> Null -> Void;
    public var missCallback:Note -> Void;

    public var chartNotes:Array = [];
    
    public var allNotes:Array = [];

    public var unspawnedNotes:Array = [];

    public var speed:Float = 1;

    public var type:CharacterType;

    public var botplay:Bool = false;

    public var character:Character;

    public function new(chart:Array, theType:CharacterType, character:Character, bpm:Float)
    {
        super();

        Conductor.bpm = bpm;

        chartNotes = chart;

        type = theType;

        this.character = character;

        add(strums = new FlxTypedGroup());
        add(sustains = new FlxTypedGroup());
        add(notes = new FlxTypedGroup());
        add(splashes = new FlxTypedGroup());

        if (type == CharacterType.EXTRA)
            visible = false;

        botplay = type != CharacterType.PLAYER;

        for (i in 0...4)
        {
            var strum:Strum = new Strum(i, type, this);
            strums.add(strum);

            var splash:Splash = new Splash(i, strum);
            splashes.add(splash);
        }

        for (chartNote in chartNotes)
        {
            var note:Note = new Note(chartNote[0], chartNote[1], chartNote[2], chartNote[3], NoteType.NORMAL, strums.members[chartNote[1]], splashes.members[chartNote[1]]);
            unspawnedNotes.push(note);

			if (note.length > 0)
			{
				var rLoop = note.length / Conductor.stepCrochet;
				var hLoop = rLoop - Math.floor(rLoop) <= 0.8 ? Math.floor(rLoop) : Math.round(rLoop);
				
				if (hLoop <= 0)
					hLoop = 1;

				for (i in 0...hLoop)
				{
                    var susNote:Note = new Note(chartNote[0] + i * Conductor.stepCrochet, chartNote[1], chartNote[2], chartNote[3], i == hLoop - 1 ? NoteType.SUSTAIN_END : NoteType.SUSTAIN, strums.members[chartNote[1]], null);
					unspawnedNotes.push(susNote);

                    note.children.push(susNote);
				}
			}
        }

        unspawnedNotes.sort(
            function(obj1, obj2)
            {
                return FlxSort.byValues(-1, obj1.time, obj2.time);
            }
        );
    }
    
    override public function update(elapsed:Float)
    {
        if (!active)
            return;

        super.update(elapsed);
        
        spawnNotes();

        var justPressed:Array = [
            Controls.LEFT_P,
            Controls.DOWN_P,
            Controls.UP_P,
            Controls.RIGHT_P
        ];

        var justReleased:Array = [
            Controls.LEFT_R,
            Controls.DOWN_R,
            Controls.UP_R,
            Controls.RIGHT_R
        ];

        updateNotes(botplay ? [false, false, false, false] : justPressed, botplay ? [false, false, false, false] : justReleased);
    }

    function spawnNotes()
    {
        if (FlxG.sound.music == null)
            return;

        var spawn:Float = 1500 / Math.min(speed, 1);

        while (unspawnedNotes[0] != null && Conductor.songPosition + spawn > unspawnedNotes[0].time)
            addNote(unspawnedNotes.shift());
    }

    var hitIndex:Int = 0;

    function updateNotes(justPressed:Array, justReleased:Array)
    {
        for (index => strum in strums)
        {
            if (justPressed[index])
                strum.animation.play('pressed');
            
            if (justReleased[index])
                strum.animation.play('idle');
        }

        if (allNotes.length <= 0)
            return;

        var despawn = 350 / Math.min(speed, 1);

        var catchData:Array = [false, false, false, false];

        for (note in allNotes)
        {
            if (!note.spawned)
                continue;

            if (note.speed != speed)
                note.speed = speed;

            var diff:Float = note.time - Conductor.songPosition;
            var absDiff:Float = Math.abs(diff);

            if (botplay)
            {
                if (diff <= 0 && (note.state == NoteState.HELD || note.state == NoteState.NEUTRAL))
                {
                    note.strum.animation.play('hit', true);

                    hitNote(note);

                    continue;
                }
            } else {
                if (note.noteType == NoteType.NORMAL)
                {
                    if (absDiff < 175 && justPressed[note.data] && !catchData[note.data] && note.state == NoteState.NEUTRAL)
                    {
                        catchData[note.data] = true;

                        note.strum.animation.play('hit', true);
                        
                        var rating:Null = null;

                        if (!botplay)
                        {
                            if (absDiff <= 50)
                                rating = Rating.SICK;
                            else if (absDiff <= 95)
                                rating = Rating.GOOD;
                            else if (absDiff <= 140)
                                rating = Rating.BAD;
                            else if (absDiff < 175)
                                rating = Rating.SHIT;
                        }

                        hitNote(note, rating);
                        
                        if (rating == Rating.SICK)
                            note.splash.animation.play('splash', true);

                        continue;
                    }
                
                    if (diff < -175 && note.state != NoteState.MISSED)
                        missNote(note);
                } else {
                    if (justReleased[note.data] && note.state == NoteState.HELD)
                        releaseNote(note);

                    if (note.state == NoteState.HELD && diff <= 0)
                    {
                        note.strum.animation.play('hit', true);

                        hitNote(note, null);

                        continue;
                    }
                }
            }

            if (note.time + despawn < Conductor.songPosition)
            {
                removeNote(note);

                continue;
            }
        }
    }

    function hitNote(note:Note, rating:String)
    {
        note.state = NoteState.HIT;

        for (child in note.children)
            child.state = NoteState.HELD;

        character.animation.play('sing' + ['LEFT', 'DOWN', 'UP', 'RIGHT'][note.data], true);
        character.idleTimer = Conductor.crochet / 1000;

        if (hitCallback != null)
            hitCallback(note, rating);

        if (note.noteType == NoteType.NORMAL)
            removeNote(note);
    }

    function missNote(note:Note)
    {
        note.state = NoteState.MISSED;

        character.animation.play('sing' + ['LEFT', 'DOWN', 'UP', 'RIGHT'][note.data] + 'miss', true);
        character.idleTimer = Conductor.crochet / 1000;

        if (missCallback != null)
            missCallback(note);
    }

    function releaseNote(note:Note)
    {
        note.state = NoteState.RELEASED;
    }

    function addNote(note:Note)
    {
        var group:FlxTypedGroup = note.noteType == NoteType.NORMAL ? notes : sustains;

        group.add(note);

        note.spawned = true;

        allNotes.push(note);
    }

    function removeNote(note:Note)
    {
        var group:FlxTypedGroup = note.noteType == NoteType.NORMAL ? notes : sustains;

        group.remove(note, true);

        note.spawned = false;

        allNotes.remove(note);
    }
}
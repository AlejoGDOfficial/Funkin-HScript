import openfl.Lib;

import lime.graphics.Image;

import funkin.states.PlayState;



FlxG.updateFramerate = FlxG.drawFramerate = 120;

Lib.application.window.title = 'Funkin HScript';

Lib.application.window.setIcon(Image.fromFile(Paths.getPath('appIcon.png')));



FlxG.switchState(new PlayState('Dad Battle', 'hard'));
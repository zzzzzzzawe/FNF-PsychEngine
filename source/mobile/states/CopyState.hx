/* KNNOWN ISSUE:
    - Null Object Refrence while copying .ttf, .otf. (at embedded ones for now)
*/
package mobile.states;

import flixel.addons.transition.FlxTransitionableState;
import openfl.utils.Assets as OpenflAssets;
import lime.utils.Assets as LimeAssets;
import flixel.addons.util.FlxAsyncLoop;
import openfl.utils.ByteArray;
import openfl.system.System;
import states.TitleState;
import haxe.io.Path;
import haxe.Json;
#if (target.threaded)
import sys.thread.Thread;
#end

class CopyState extends MusicBeatState {
    public static var filesToCopy:Array<String> = [];
    public static var filesToCreate:Array<String> = [];
    public static var allFiles:Array<String> = [];
    public static var maxLoopTimes:Int = 0;
    public static var to:String = '';
    public var loadingImage:FlxSprite;
    public var bottomBG:FlxSprite;
    public var loadedText:FlxText;
    public var copyLoop:FlxAsyncLoop;
    var loopTimes:Int = 0;
    var failedFiles:Array<String> = [];
    var shouldCopy:Bool = false;
    var canUpdate:Bool = true;
    static final textFilesExtensions:Array<String> = [
        'txt',
        'xml',
        'lua',
        'hx',
        'json',
        'frag',
        'vert'
    ];
    
    override function create() {
        allFiles = [];
        maxLoopTimes = 0;
        filesToCopy = [];
        filesToCreate = [];
        checkExistingFiles();
        if(maxLoopTimes > 0){
            shouldCopy = true;
            FlxG.stage.window.alert(
            "Seems like you have some missing files that are necessary to run the game\nPress OK to begin the copy process",
            "Notice!");

            loadingImage = new FlxSprite(0, 0, Paths.image('funkin'));
            loadingImage.scale.set(0.8, 0.8);
            loadingImage.screenCenter();
            add(loadingImage);

            bottomBG = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, 0xFF000000);
		    bottomBG.alpha = 0.6;
		    add(bottomBG);

            loadedText = new FlxText(bottomBG.x, bottomBG.y + 4, FlxG.width, '', 16);
            loadedText.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, CENTER);
            add(loadedText);
    
            #if (target.threaded) Thread.create(() -> {#end
            copyLoop = new FlxAsyncLoop(maxLoopTimes, copyAsset, 17);
            add(copyLoop);
            copyLoop.start();
            #if (target.threaded) }); #end
        } else {
            TitleState.ignoreCopy = true;
            FlxTransitionableState.skipNextTransIn = FlxTransitionableState.skipNextTransOut = true;
            MusicBeatState.switchState(new TitleState());
        }

        super.create();
    }

    override function update(elapsed:Float) {
        if(shouldCopy){
            if(copyLoop.finished && canUpdate){
                if(failedFiles.length > 0){
                    FlxG.stage.window.alert(failedFiles.join('\n'), 'Failed To Copy ${failedFiles.length} File.');
                    if(!FileSystem.exists('logs'))
                        FileSystem.createDirectory('logs');
                    File.saveContent('logs/' + Date.now().toString().replace(' ', '-').replace(':', "'") + '-CopyState' + '.txt', failedFiles.join('\n'));
                }
                canUpdate = false;
				FlxG.sound.play(Paths.sound('confirmMenu'));
                var black = new FlxSprite(0,0).makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
                add(black);
                black.alpha = 0;
                FlxTween.tween(black, {alpha: 1}, 0.9, {
                    onComplete: function(twn:FlxTween) {
                        System.gc();
                        TitleState.ignoreCopy = true;
                        FlxTransitionableState.skipNextTransIn = FlxTransitionableState.skipNextTransOut = true;
                        MusicBeatState.switchState(new TitleState());
                    }, ease: FlxEase.linear, startDelay: 0.4});
            }
            loadedText.text = '$loopTimes/$maxLoopTimes';
        }
        super.update(elapsed);
    }

    public function copyAsset() {
        var file = allFiles[loopTimes];
        var toFile = Path.join([to, file]);
	    loopTimes++; 
		if(!FileSystem.exists(toFile)) {
			var directory = Path.directory(toFile);
		    if(!FileSystem.exists(directory))
					SUtil.mkDirs(directory);
            try {
                if(LimeAssets.exists(getFile(file))){
                    if(filesToCopy.contains(file))
                        File.saveBytes(toFile, getFileBytes(getFile(file)));
                    else if(filesToCreate.contains(file))
                        createContentFromInternal(file);
                } else {
                    failedFiles.push(getFile(file) + " (File Dosen't Exist)");
                }
            } catch(err:Dynamic) {
                failedFiles.push('${getFile(file)} ($err)');
            }
		}
	}

    public static function getFileBytes(file:String):ByteArray {
		switch(Path.extension(file)) {
			case 'otf' | 'ttf':
				return cast LimeAssets.getAsset(file, FONT, false);
			default:
				return OpenflAssets.getBytes(file);
		}
	}
	public static function getFile(file:String):String {
		for(index in 1...8)
			if(file.contains('/week$index/'))
				return 'week_assets:$file';
		if(file.contains('/videos/'))
			return 'videos:$file';
		else if(file.contains('/songs/'))
			return 'songs:$file';
		else
			return file;
	}

    public function createContentFromInternal(file:String = 'assets/file.txt') {
        var fileName = Path.withoutDirectory(file);
        var directory = Path.directory(Path.join([to, file]));
        try {
            var fileData:String = LimeAssets.getText(getFile(file));
            if(fileData == null)
                fileData = '';
            if(!FileSystem.exists(directory))
                SUtil.mkDirs(directory);
            File.saveContent(Path.join([directory, fileName]), fileData);
        } catch(error:Dynamic) {
            failedFiles.push('${getFile(file)} ($error)');
        }
    }

    public static function checkExistingFiles():Bool{
        filesToCopy = LimeAssets.list();
        // removes unwanted assets
        var assets = filesToCopy.filter(folder -> folder.startsWith('assets/'));
        var mods = filesToCopy.filter(folder -> folder.startsWith('mods/'));
        filesToCopy = assets.concat(mods);
        filesToCreate = filesToCopy.filter(file -> textFilesExtensions.contains(Path.extension(file)));
        var filesToRemove:Array<Array<String>> = [[], []];
        for(file in filesToCreate){
            if(filesToCopy.contains(file))
                filesToRemove[0].push(file);

            var toFile = Path.join([to, file]);
            if(FileSystem.exists(toFile)){
                filesToRemove[1].push(file);
            }
        }
        for(file in filesToCopy){
            var toFile = Path.join([to, file]);
            if(FileSystem.exists(toFile)){
                filesToRemove[0].push(file);
            }
        }

        for(arr in filesToRemove){
            for(file in arr){
                if(filesToCopy.contains(file))
                    filesToCopy.remove(file);
                if(filesToCreate.contains(file))
                    filesToCreate.remove(file);
            }
        }

        allFiles = filesToCopy.concat(filesToCreate);
        maxLoopTimes = allFiles.length;
        
        if(maxLoopTimes > 0)
            return false;
        else
            return true;
    }
}

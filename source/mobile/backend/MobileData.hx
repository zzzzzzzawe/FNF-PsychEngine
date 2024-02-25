package mobile.backend;

import haxe.ds.Map;
import tjson.TJSON as Json;
import sys.FileSystem;
import sys.io.File;
import haxe.io.Path;

class MobileData
{
	public static var actionModes:Map<String, VirtualPadButtonsData> = new Map();
	public static var dpadModes:Map<String, VirtualPadButtonsData> = new Map();
	public static var extraActions:Map<String, ExtraActions> = new Map();
	public static var virtualPadConfig:VirtualPadData = {image: 'virtualpad', alpha: ClientPrefs.data.controlsAlpha};

	public static function init()
	{
		readDirectory(Paths.getSharedPath('mobile/DPadModes'), dpadModes);
		readDirectory(Paths.getSharedPath('mobile/ActionModes'), actionModes);
		for (folder in Mods.directoriesWithFile(Paths.getSharedPath(), 'mobile/'))
		{
			readDirectory(Path.join([folder, 'DPadModes']), dpadModes);
			readDirectory(Path.join([folder, 'ActionModes']), actionModes);
		}

		if (FileSystem.exists(Paths.getSharedPath('data/mobile/config.json')))
		{
			var json:VirtualPadData = cast Json.parse(File.getContent(Paths.getSharedPath('mobile/config.json')));
			if (json.image != null && json.image.length > 0)
				virtualPadConfig.image = json.image;
			if (json.alpha != null)
				virtualPadConfig.alpha = json.alpha;
		}

		for (data in ExtraActions.createAll())
			extraActions.set(data.getName(), data);
	}

	public static function readDirectory(folder:String, map:Dynamic)
	{
		if (FileSystem.exists(folder))
			for (file in FileSystem.readDirectory(folder))
			{
				if (Path.extension(file) == 'json')
				{
					var file = Path.join([folder, Path.withoutDirectory(file)]);
					var str = File.getContent(file);
					var json:VirtualPadButtonsData = cast Json.parse(str);
					var mapKey:String = Path.withoutDirectory(Path.withoutExtension(file));
					if (!map.exists(mapKey)) // prevents overriding default vpads
						map.set(mapKey, json);
				}
			}
	}
}

typedef VirtualPadButtonsData =
{
	buttons:Array<ButtonsData>
}

typedef ButtonsData =
{
	button:String, // what FlxButton should be used, must be a valid FlxButton var from FlxVirtualPad as a string.
	graphic:String, // the graphic of the button, usually can be located in the VirtualPad xml .
	x:Float, // the button's X position on screen.
	y:Float, // the button's Y position on screen.
	width:Int, // the button's width, default value is 132.
	height:Int, // the button's height, default value is 127.
	color:String // the button color, default color is white.
}

typedef VirtualPadData =
{
	image:String,
	?alpha:Float
}

enum ExtraActions
{
	SINGLE;
	DOUBLE;
	NONE;
}

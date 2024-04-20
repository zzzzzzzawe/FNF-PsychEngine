package mobile.options;

import flixel.input.keyboard.FlxKey;
import options.BaseOptionsMenu;
import options.Option;

class MobileOptionsSubState extends BaseOptionsMenu
{
	#if android
	final storageTypes:Array<String> = ["EXTERNAL_DATA", "EXTERNAL_OBB", "EXTERNAL_MEDIA", "EXTERNAL"];
	final lastStorageType:String = ClientPrefs.data.storageType;
	#end
	final exControlTypes:Array<String> = ["NONE", "SINGLE", "DOUBLE"];
	final hintOptions:Array<String> = ["Gradient", "No Gradient", "Hidden"];
	var option:Option;

	public function new()
	{
		title = 'Mobile Options';
		rpcTitle = 'Mobile Options Menu'; // for Discord Rich Presence, fuck it

		option = new Option('Extra Controls',
		'Select how many extra buttons you prefere to have\nThey can be used for mechanics with LUA or HScript.',
		'extraButtons',
		STRING,
		exControlTypes);
		addOption(option);

		option = new Option('Mobile Controls Opacity',
		'Selects the opacity for the mobile buttons (carefull not to put it at 0 and loose track of your buttons).',
		'controlsAlpha',
		PERCENT);
		option.scrollSpeed = 1;
		option.minValue = 0.001;
		option.maxValue = 1;
		option.changeValue = 0.1;
		option.decimals = 1;
		option.onChange = () ->
		{
			virtualPad.alpha = curOption.getValue();
			if (Controls.instance.mobileC) {
				FlxG.sound.volumeUpKeys = [];
				FlxG.sound.volumeDownKeys = [];
				FlxG.sound.muteKeys = [];
			} else {
				FlxG.sound.volumeUpKeys = [FlxKey.PLUS, FlxKey.NUMPADPLUS];
				FlxG.sound.volumeDownKeys = [FlxKey.MINUS, FlxKey.NUMPADMINUS];
				FlxG.sound.muteKeys = [FlxKey.ZERO, FlxKey.NUMPADZERO];
			}
		};
		addOption(option);

		#if mobile
		option = new Option('Allow Phone Screensaver',
		'If checked, the phone will sleep after going inactive for few seconds.\n(The time depends on your phone\'s options)',
		'screensaver',
		BOOL);
		option.onChange = () -> lime.system.System.allowScreenTimeout = curOption.getValue();
		addOption(option);
		#end

		if (MobileControls.mode == 4)
		{
			option = new Option('Hitbox Design',
			'Choose how your hitbox should look like.',
			'hitboxType',
			STRING,
			hintOptions);
			addOption(option);

			option = new Option('Hitbox Position',
			'If checked, the hitbox will be put at the bottom of the screen, otherwise will stay at the top.',
			'hitbox2',
			BOOL);
			addOption(option);
		}

		option = new Option('Dynamic Controls Color',
		'If checked, the mobile controls color will be set to the notes color in your settings.\n(have effect during gameplay only)',
		'dynamicColors',
		BOOL);
		addOption(option);

		#if android
		option = new Option('Storage Type',
			'Whatever',
			'storageType',
			STRING,
			storageTypes);
			addOption(option);
		#end

		super();
	}

	public function onDestroy() {
		super.destroy();
		/*ClientPrefs.saveSettings();
		ClientPrefs.loadPrefs();*/
		if (ClientPrefs.data.storageType != lastStorageType) {
			SUtil.showPopUp('', 'Notice!');
			lime.system.System.exit(0);
		}
	}
}
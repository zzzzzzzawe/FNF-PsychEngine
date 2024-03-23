package mobile.options;

import options.BaseOptionsMenu;
import options.Option;

class MobileOptionsSubState extends BaseOptionsMenu
{
	var exControlTypes:Array<String> = ["NONE", "SINGLE", "DOUBLE"];
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
			option = new Option('Hide Hitbox Hints',
			'If checked, makes the hitbox invisible.',
			'hideHitboxHints',
			BOOL);
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

		super();
	}
}
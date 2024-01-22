package mobile.objects;

import haxe.ds.Map;
import flixel.math.FlxPoint;
import mobile.flixel.input.FlxMobileInputManager;

class MobileControls extends FlxSpriteGroup
{
	public var virtualPad:FlxVirtualPad = new FlxVirtualPad(NONE, NONE, NONE);
	public var hitbox:FlxHitbox = new FlxHitbox(NONE);
	@:isVar // HAXE FORCED ME TO PUT THIS IDFK
	public var current(get, set):Dynamic;

	public static var mode(get, set):Int;
	public static var forcedControl:Null<Int>;

	public function new(?forceType:Int, ?extra:Bool = true)
	{
		super();
		forcedControl = mode;
		if (forceType != null)
			forcedControl = forceType;
		switch (forcedControl)
		{
			case 0: // RIGHT_FULL
				initControler(0, extra);
			case 1: // LEFT_FULL
				initControler(1, extra);
			case 2: // CUSTOM
				initControler(2, extra);
			case 3: // BOTH
				initControler(3, extra);
			case 4: // HITBOX
				initControler(4, extra);
			case 5: // KEYBOARD
		}

		// Options related stuff
		alpha = ClientPrefs.data.controlsAlpha;

		// Dynamic Controls Color
		var buttonsColors:Array<FlxColor> = [];
		var data:Dynamic;
		if (ClientPrefs.data.dynamicColors)
			data = ClientPrefs.data;
		else
			data = ClientPrefs.defaultData;

		buttonsColors.push(data.arrowRGB[0][0]);
		buttonsColors.push(data.arrowRGB[1][0]);
		buttonsColors.push(data.arrowRGB[2][0]);
		buttonsColors.push(data.arrowRGB[3][0]);

		virtualPad.buttonLeft.color = buttonsColors[0];
		virtualPad.buttonDown.color = buttonsColors[1];
		virtualPad.buttonUp.color = buttonsColors[2];
		vitrualPad.buttonRight.color = buttonsColors[3];
		if (mode == 3)
		{
			virtualPad.buttonLeft2.color = buttonsColors[0];
			virtualPad.buttonDown2.color = buttonsColors[1];
			virtualPad.buttonUp2.color = buttonsColors[2];
			virtualPad.buttonRight2.color = buttonsColors[3];
		}
	}

	private function initControler(virtualPadMode:Int = 0, ?extra:Bool = true):Void
	{
		var extraAction = Data.extraActions.get(ClientPrefs.data.extraButtons);
		if (!extra)
			extraAction = NONE;
		switch (virtualPadMode)
		{
			case 0:
				virtualPad = new FlxVirtualPad(RIGHT_FULL, NONE, extraAction);
				add(virtualPad);
			case 1:
				virtualPad = new FlxVirtualPad(LEFT_FULL, NONE, extraAction);
				add(virtualPad);
			case 2:
				virtualPad = MobileControls.getCustomMode(new FlxVirtualPad(RIGHT_FULL, NONE, extraAction));
				add(virtualPad);
			case 3:
				virtualPad = new FlxVirtualPad(BOTH, NONE, extraAction);
				add(virtualPad);
			case 4:
				hitbox = new FlxHitbox(extraAction);
				add(hitbox);
		}
	}

	public static function setCustomMode(virtualPad:FlxVirtualPad):Void
	{
		if (FlxG.save.data.buttons == null)
		{
			FlxG.save.data.buttons = new Array();
			for (buttons in virtualPad)
				FlxG.save.data.buttons.push(FlxPoint.get(buttons.x, buttons.y));
		}
		else
		{
			var tempCount:Int = 0;
			for (buttons in virtualPad)
			{
				FlxG.save.data.buttons[tempCount] = FlxPoint.get(buttons.x, buttons.y);
				tempCount++;
			}
		}

		FlxG.save.flush();
	}

	public static function getCustomMode(virtualPad:FlxVirtualPad):FlxVirtualPad
	{
		var tempCount:Int = 0;

		if (FlxG.save.data.buttons == null)
			return virtualPad;

		for (buttons in virtualPad)
		{
			buttons.x = FlxG.save.data.buttons[tempCount].x;
			buttons.y = FlxG.save.data.buttons[tempCount].y;
			tempCount++;
		}

		return virtualPad;
	}

	override public function destroy():Void
	{
		super.destroy();

		if (virtualPad != null)
		{
			virtualPad = FlxDestroyUtil.destroy(virtualPad);
			virtualPad = null;
		}

		if (hitbox != null)
		{
			hitbox = FlxDestroyUtil.destroy(hitbox);
			hitbox = null;
		}
	}

	function get_current()
	{
		return switch (mode)
		{
			case 4: hitbox;
			default: virtualPad;
		}
	}

	function set_current(val:Dynamic)
	{
		current = val;
		return val;
	}

	static function set_mode(mode:Int = 0)
	{
		FlxG.save.data.mobileControlsMode = mode;
		FlxG.save.flush();
		return mode;
	}

	static function get_mode():Int
	{
		if (forcedControl != null)
			return forcedControl;

		if (FlxG.save.data.mobileControlsMode == null)
		{
			FlxG.save.data.mobileControlsMode = 0;
			FlxG.save.flush();
		}

		return FlxG.save.data.mobileControlsMode;
	}
}

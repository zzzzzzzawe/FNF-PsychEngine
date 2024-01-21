package mobile.flixel;

import mobile.flixel.input.FlxMobileInputManager;
import openfl.display.BitmapData;
import mobile.flixel.FlxButton;
import openfl.display.Shape;

/**
 * A zone with 4 hint's (A hitbox).
 * It's really easy to customize the layout.
 *
 * @author: Mihai Alexandru
 * @modification's author: Karim Akra & Lily (mcagabe19)
 */
class FlxHitbox extends FlxMobileInputManager
{
	final offsetFir:Int = (ClientPrefs.data.hitbox2 ? Std.int(FlxG.height / 4) * 3 : 0);
	final offsetSec:Int = (ClientPrefs.data.hitbox2 ? 0 : Std.int(FlxG.height / 4));

	public var buttonLeft:FlxButton = new FlxButton(0, 0, [FlxMobileInputID.hitboxLEFT, FlxMobileInputID.noteLEFT]);
	public var buttonDown:FlxButton = new FlxButton(0, 0, [FlxMobileInputID.hitboxDOWN, FlxMobileInputID.noteDOWN]);
	public var buttonUp:FlxButton = new FlxButton(0, 0, [FlxMobileInputID.hitboxUP, FlxMobileInputID.noteUP]);
	public var buttonRight:FlxButton = new FlxButton(0, 0, [FlxMobileInputID.hitboxRIGHT, FlxMobileInputID.noteRIGHT]);
	public var buttonExtra:FlxButton = new FlxButton(0, 0);
	public var buttonExtra2:FlxButton = new FlxButton(0, 0);

	/**
	 * Create the zone.
	 */
	public function new(extraMode:ExtraActions)
	{
		super();

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

		switch (extraMode)
		{
			case NONE:
				add(createHint(buttonLeft, 0, 0, Std.int(FlxG.width / 4), FlxG.height, 0xFFC24B99));
				add(createHint(buttonDown, FlxG.width / 4, 0, Std.int(FlxG.width / 4), FlxG.height, 0xFF00FFFF));
				add(createHint(buttonUp, FlxG.width / 2, 0, Std.int(FlxG.width / 4), FlxG.height, 0xFF12FA05));
				add(createHint(buttonRight, (FlxG.width / 2) + (FlxG.width / 4), 0, Std.int(FlxG.width / 4), FlxG.height, 0xFFF9393F));
			case SINGLE:
				add(createHint(buttonLeft, 0, offsetSec, Std.int(FlxG.width / 4), Std.int(FlxG.height / 4) * 3, 0xFFC24B99));
				add(createHint(buttonDown, FlxG.width / 4, offsetSec, Std.int(FlxG.width / 4), Std.int(FlxG.height / 4) * 3, 0xFF00FFFF));
				add(createHint(buttonUp, FlxG.width / 2, offsetSec, Std.int(FlxG.width / 4), Std.int(FlxG.height / 4) * 3, 0xFF12FA05));
				add(createHint(buttonRight, (FlxG.width / 2) + (FlxG.width / 4), offsetSec, Std.int(FlxG.width / 4), Std.int(FlxG.height / 4) * 3, 0xFFF9393F));
				add(createHint(buttonExtra, 0, offsetFir, FlxG.width, Std.int(FlxG.height / 4), 0xFF0066FF));
			case DOUBLE:
				add(createHint(buttonLeft, 0, offsetSec, Std.int(FlxG.width / 4), Std.int(FlxG.height / 4) * 3, 0xFFC24B99));
				add(createHint(buttonDown, FlxG.width / 4, offsetSec, Std.int(FlxG.width / 4), Std.int(FlxG.height / 4) * 3, 0xFF00FFFF));
				add(createHint(buttonUp, FlxG.width / 2, offsetSec, Std.int(FlxG.width / 4), Std.int(FlxG.height / 4) * 3, 0xFF12FA05));
				add(createHint(buttonRight, (FlxG.width / 2) + (FlxG.width / 4), offsetSec, Std.int(FlxG.width / 4), Std.int(FlxG.height / 4) * 3, 0xFFF9393F));
				add(createHint(buttonExtra, Std.int(FlxG.width / 2), offsetFir, Std.int(FlxG.width / 2), Std.int(FlxG.height / 4), 0xFF0066FF));
				add(createHint(buttonExtra2, 0, offsetFir, Std.int(FlxG.width / 2), Std.int(FlxG.height / 4), 0xA6FF00));
		}
		scrollFactor.set();
		updateTrackedButtons();
	}

	/**
	 * Clean up memory.
	 */
	override function destroy()
	{
		super.destroy();

		buttonLeft = FlxDestroyUtil.destroy(buttonLeft);
		buttonDown = FlxDestroyUtil.destroy(buttonDown);
		buttonUp = FlxDestroyUtil.destroy(buttonUp);
		buttonRight = FlxDestroyUtil.destroy(buttonRight);
		buttonExtra = FlxDestroyUtil.destroy(buttonExtra);
		buttonExtra2 = FlxDestroyUtil.destroy(buttonExtra2);
	}

	private function createHintGraphic(Width:Int, Height:Int, Color:Int = 0xFFFFFF):BitmapData
	{
		var guh = ClientPrefs.data.controlsAlpha;
		if (guh >= 0.9)
			guh = ClientPrefs.data.controlsAlpha - 0.07;
		var shape:Shape = new Shape();
		shape.graphics.beginFill(Color);
		shape.graphics.lineStyle(3, Color, 1);
		shape.graphics.drawRect(0, 0, Width, Height);
		shape.graphics.lineStyle(0, 0, 0);
		shape.graphics.drawRect(3, 3, Width - 6, Height - 6);
		shape.graphics.endFill();
		shape.graphics.beginGradientFill(RADIAL, [Color, FlxColor.TRANSPARENT], [guh, 0], [0, 255], null, null, null, 0.5);
		shape.graphics.drawRect(3, 3, Width - 6, Height - 6);
		shape.graphics.endFill();

		var bitmap:BitmapData = new BitmapData(Width, Height, true, 0);
		bitmap.draw(shape);
		return bitmap;
	}

	private function createHint(hint:FlxButton, X:Float, Y:Float, Width:Int, Height:Int, Color:Int = 0xFFFFFF):FlxButton
	{
		var hintTween:FlxTween = null;
		var IDs = hint.IDs;
		hint = new FlxButton(X, Y, IDs);
		hint.loadGraphic(createHintGraphic(Width, Height, Color));
		hint.solid = false;
		hint.immovable = true;
		hint.multiTouch = true;
		hint.moves = false;
		hint.scrollFactor.set();
		hint.alpha = 0.00001;
		hint.antialiasing = ClientPrefs.data.antialiasing;
		hint.onDown.callback = function()
		{
			if (hintTween != null)
				hintTween.cancel();

			hintTween = FlxTween.tween(hint, {alpha: ClientPrefs.data.controlsAlpha}, ClientPrefs.data.controlsAlpha / 100, {
				ease: FlxEase.circInOut,
				onComplete: function(twn:FlxTween)
				{
					hintTween = null;
				}
			});
		}
		hint.onUp.callback = function()
		{
			if (hintTween != null)
				hintTween.cancel();

			hintTween = FlxTween.tween(hint, {alpha: 0.00001}, ClientPrefs.data.controlsAlpha / 10, {
				ease: FlxEase.circInOut,
				onComplete: function(twn:FlxTween)
				{
					hintTween = null;
				}
			});
		}
		hint.onOut.callback = function()
		{
			if (hintTween != null)
				hintTween.cancel();

			hintTween = FlxTween.tween(hint, {alpha: 0.00001}, ClientPrefs.data.controlsAlpha / 10, {
				ease: FlxEase.circInOut,
				onComplete: function(twn:FlxTween)
				{
					hintTween = null;
				}
			});
		}
		#if FLX_DEBUG
		hint.ignoreDrawDebug = true;
		#end
		return hint;
	}
}

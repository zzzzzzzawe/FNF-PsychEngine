package backend;

#if VIDEOS_ALLOWED
#if (hxCodec >= "3.0.0")
import hxcodec.flixel.FlxVideoSprite as VideoSprite;
#elseif (hxCodec >= "2.6.1")
import hxcodec.VideoSprite;
#elseif (hxCodec == "2.6.0")
import VideoSprite;
#else
import vlc.MP4Sprite as VideoSprite;
#end
#end
import states.PlayState;
import haxe.extern.EitherType;
import flixel.util.FlxSignal;
import haxe.io.Path;

#if VIDEOS_ALLOWED
class VideoSpriteManager extends VideoSprite
{
	public var playbackRate(get, set):EitherType<Single, Float>;
	public var paused(default, set):Bool = false;
	public var onVideoEnd:FlxSignal;
	public var onVideoStart:FlxSignal;

	public function new(x:Float = 0, y:Float = 0 #if (hxCodec < "2.6.0"), width:Float = 1280, height:Float = 720, autoScale:Bool = true #end)
	{
		super(x, y #if (hxCodec < "2.6.0"), width, height, autoScale #end);

		onVideoEnd = new FlxSignal();
		onVideoEnd.add(function()
		{
			destroy();
		});
		onVideoStart = new FlxSignal();
		#if (hxCodec >= "3.0.0")
		onVideoEnd.add(destroy);
		bitmap.onOpening.add(function()
		{
			onVideoStart.dispatch();
		});
		bitmap.onEndReached.add(function()
		{
			onVideoEnd.dispatch();
		});
		#else
		openingCallback = function()
		{
			onVideoStart.dispatch();
		};
		finishCallback = function()
		{
			onVideoEnd.dispatch(); // using  bitmap.finishCallback = onVideoEnd.dispatch was giving a null function pointer
		};
		#end
	}

	public function startVideo(path:String, loop:Bool = false)
	{
		#if (hxCodec >= "3.0.0")
		play(path, loop);
		#else
		playVideo(path, loop, false);
		#end
	}

	@:noCompletion
	private function set_paused(shouldPause:Bool)
	{
		#if (hxCodec >= "3.0.0")
		var parentResume = resume;
		var parentPause = pause;
		#else
		var parentResume = bitmap.resume;
		var parentPause = bitmap.pause;
		#end

		if (shouldPause)
		{
			#if (hxCodec >= "3.0.0")
			pause();
			#else
			bitmap.pause();
			#end

			if (FlxG.autoPause)
			{
				if (FlxG.signals.focusGained.has(parentResume))
					FlxG.signals.focusGained.remove(parentResume);

				if (FlxG.signals.focusLost.has(parentPause))
					FlxG.signals.focusLost.remove(parentPause);
			}
		}
		else
		{
			#if (hxCodec >= "3.0.0")
			resume();
			#else
			bitmap.resume();
			#end

			if (FlxG.autoPause)
			{
				FlxG.signals.focusGained.add(parentResume);
				FlxG.signals.focusLost.add(parentPause);
			}
		}
		return shouldPause;
	}

	@:noCompletion
	private function set_playbackRate(multi:EitherType<Single, Float>)
	{
		bitmap.rate = multi;
		return multi;
	}

	@:noCompletion
	private function get_playbackRate():Float
	{
		return bitmap.rate;
	}

	override function destroy()
	{
		super.destroy();
		#if (hxCodec < "3.0.0")
		try
		{
			bitmap.onEndReached();
		}
		catch (fym:Dynamic)
		{
			trace(fym);
		}
		#end
	}
#end
}

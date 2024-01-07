package psychlua;

#if VIDEOS_ALLOWED
import backend.VideoSpriteManager;
import states.PlayState;
import substates.GameOverSubstate;

class VideoFunctions
{
	// nobody tell me to use game instead of PlayState.instance... IT ALLWAYS RETURN FUCKING NULL
	public static function implement(funk:FunkinLua)
	{
		funk.set("makeVideoSprite", function(tag:String, x:Float, y:Float)
		{
			tag = tag.replace('.', '');
			LuaUtils.resetVideoSpriteTag(tag);
			var video = new VideoSpriteManager(x, y);
			video.playbackRate = PlayState.instance.playbackRate;
			PlayState.instance.modchartVideoSprites.set(tag, video);
		});

		// when you don't give it a tag it plays a normal video cutscene
		funk.set("startVideo", function(videoName:String, ?tag:String = null, ?loop)
		{
			var videoPath = Paths.video(videoName);
			if (!FileSystem.exists(videoPath))
			{
				FunkinLua.luaTrace('startVideo: Video file not found: ' + videoName, false, false, FlxColor.RED);
				if (tag != null)
					return false;
			}
			if (tag == null)
			{
				PlayState.instance.startVideo(videoName);
				return true;
			}
			else
			{
				var video = LuaUtils.getVideoSpriteObject(tag);
				if (video == null)
				{
					FunkinLua.luaTrace("startVideo: Video " + tag + " does not exist!", false, false, FlxColor.RED);
					return false;
				}
				video.startVideo(videoPath, loop);
				return true;
			}
		});

		funk.set("addLuaVideoSprite", function(tag:String, front:Bool = false)
		{
			var video:VideoSpriteManager = null;
			if (PlayState.instance.modchartVideoSprites.exists(tag))
				video = PlayState.instance.modchartVideoSprites.get(tag);
			else if (PlayState.instance.variables.exists(tag))
				video = PlayState.instance.variables.get(tag);

			if (video == null)
				return false;

			if (front)
				LuaUtils.getTargetInstance().add(video);
			else
			{
				if (!PlayState.instance.isDead)
					PlayState.instance.insert(PlayState.instance.members.indexOf(LuaUtils.getLowestCharacterGroup()), video);
				else
					GameOverSubstate.instance.insert(GameOverSubstate.instance.members.indexOf(GameOverSubstate.instance.boyfriend), video);
			}
			return true;
		});

		funk.set("removeLuaVideoSprite", function(tag:String, destroy:Bool = true)
		{
			if (!PlayState.instance.modchartVideoSprites.exists(tag))
			{
				return;
			}

			var video = PlayState.instance.modchartVideoSprites.get(tag);
			LuaUtils.getTargetInstance().remove(video, true);
			if (destroy)
			{
				video.destroy();
				PlayState.instance.modchartVideoSprites.remove(tag);
			}
		});

		funk.set("addVideoFinishCallback", function(myFunction:Dynamic, ?tag:String = null)
		{
			if (myFunction != null)
			{
				if (tag == null)
				{
					if (PlayState.instance.video == null)
						return false;
					PlayState.instance.video.onVideoEnd.add(myFunction);
					return true;
				}
				else
				{
					var video = LuaUtils.getVideoSpriteObject(tag);
					if (video == null)
					{
						FunkinLua.luaTrace("addVideoFinishCallback: Video " + tag + " does not exist!", false, false, FlxColor.RED);
						return false;
					}
					video.onVideoEnd.add(myFunction);
					return true;
				}
			}
			return false;
		});

		funk.set("addVideoStartCallback", function(myFunction:Dynamic, ?tag:String = null)
		{
			if (myFunction != null)
			{
				if (tag == null)
				{
					if (PlayState.instance.video == null)
						return false;
					PlayState.instance.video.onVideoStart.add(myFunction);
					return true;
				}
				else
				{
					var video = LuaUtils.getVideoSpriteObject(tag);
					if (video == null)
					{
						FunkinLua.luaTrace("addVideoStartCallback: Video " + tag + " does not exist!", false, false, FlxColor.RED);
						return false;
					}
					video.onVideoStart.add(myFunction);
					return true;
				}
			}
			return false;
		});

		funk.set("removeVideoFinishCallbacks", function(?tag:String = null)
		{
			if (tag == null)
			{
				if (PlayState.instance.video == null)
					return false;
				PlayState.instance.video.onVideoEnd.removeAll();
				return true;
			}
			else
			{
				var video = LuaUtils.getVideoSpriteObject(tag);
				if (video == null)
				{
					FunkinLua.luaTrace("removeVideoFinishCallbacks: Video " + tag + " does not exist!", false, false, FlxColor.RED);
					return false;
				}
				video.onVideoEnd.removeAll();
				return true;
			}
			return false;
		});

		funk.set("removeVideoStartCallbacks", function(?tag:String = null)
		{
			if (tag == null)
			{
				if (PlayState.instance.video == null)
					return false;
				PlayState.instance.video.onVideoStart.removeAll();
				return true;
			}
			else
			{
				var video = LuaUtils.getVideoSpriteObject(tag);
				if (video == null)
				{
					FunkinLua.luaTrace("removeVideoFinishCallbacks: Video " + tag + " does not exist!", false, false, FlxColor.RED);
					return false;
				}
				video.onVideoStart.removeAll();
				return true;
			}
			return false;
		});
	}
}
#end

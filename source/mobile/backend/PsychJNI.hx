package mobile.backend;

#if android
import lime.system.JNI;

class PsychJNI
{
	@:noCompletion private static var setOrientation_jni:Dynamic = JNI.createStaticMethod('org/libsdl/app/SDLActivity', 'setOrientation','(IIZLjava/lang/String;)V');

	public static inline function setOrientation(width:Int, height:Int, resizeable:Bool, hint:String):Dynamic
		return setOrientation_jni(width, height, resizeable, hint);
}
#end

/*
The functions needs to be added: setWindowStyle
The functions "maybe" needs to be added: isScreenKeyboardShown, getDisplayDPI, messageboxShowMessageBox, clipboardHasText, clipboardGetText, clipboardSetText
NOTE: THESE AT "SDLActivity"!!
*/
package mobile.backend;

#if android
import lime.system.JNI;

class PsychJNI #if (lime >= "8.0.0") implements JNISafety #end
{
	@:noCompletion private static var getCurrentOrientation_jni:Dynamic = JNI.createStaticMethod('org/libsdl/app/SDLActivity', 'getCurrentOrientation','()I');
	@:noCompletion private static var setOrientation_jni:Dynamic = JNI.createStaticMethod('org/libsdl/app/SDLActivity', 'setOrientation','(IIZLjava/lang/String;)V');

	public static inline function setOrientation(width:Int, height:Int, resizeable:Bool, hint:String):Dynamic
		return setOrientation_jni(width, height, resizeable, hint);

	public static inline function getCurrentOrientation():Dynamic
		return getCurrentOrientation_jni();

	// public static inline function getCurrentOrientationAsString():Dynamic {}
}
#end

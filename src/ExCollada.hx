/*

Basic Collada loading in Away3dLite

Demonstrates:

How to load a Collada file.
How to access loaded textures from the material library.

Code by Rob Bateman & Katopz
rob@infiniteturtles.co.uk
http://www.infiniteturtles.co.uk
katopz@sleepydesign.com
http://sleepydesign.com/

This code is distributed under the MIT License

Copyright (c)  

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the “Software”), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

*/

package;
import away3dlite.core.base.Object3D;
import away3dlite.core.utils.Debug;
import away3dlite.events.Loader3DEvent;
import away3dlite.loaders.Collada;
import away3dlite.loaders.Loader3D;
import away3dlite.templates.FastTemplate;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Loader;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.Lib;
import flash.display.StageQuality;
import haxe.Resource;

//[SWF(backgroundColor="#000000", frameRate="30", quality="MEDIUM", width="800", height="600")]

/**
 * Collada example.
 */
class ExCollada extends FastTemplate
{
	//signature swf
	//[Embed(source="assets/signature_lite_katopz.swf", symbol="Signature")]
	private static var SignatureSwf:Loader;
	
	private var Signature:Sprite;
	private var SignatureBitmap:Bitmap;
	
	private var collada:Collada;
	private var loader:Loader3D;
	private var loaded:Bool;
	private var model:Object3D;
	private static var filesToLoad:Int;
	
	
	public static function main()
	{
		filesToLoad = 1;
		SignatureSwf = new Loader();
		loadResource(SignatureSwf, "signatureSwf");
	}
	
	private function onSuccess(event:Loader3DEvent):Void
	{
		loaded = true;
		model = loader.handle;
	}
	
	private static function loadResource(loader:Loader , resname:String)
	{
		loader.contentLoaderInfo.addEventListener("complete", onLoadComplete);
		loader.loadBytes(Resource.getBytes(resname).getData());
	}
	
	private static function onLoadComplete(e:Event):Void 
	{
		if (--filesToLoad == 0)
			Lib.current.addChild(new ExCollada());
	}
	
	/**
	 * @inheritDoc
	 */
	override private function onInit():Void
	{
		title += " : Collada Example.";
		Debug.active = true;
		Debug.redirectTraces = true;
		camera.z = -1000;
		
		collada = new Collada();
		collada.scaling = 600;
		collada.centerMeshes = true;
		
		loader = new Loader3D();
		loader.loadGeometry("assets/chameleon.dae", collada);
		loader.addEventListener(Loader3DEvent.LOAD_SUCCESS, onSuccess);
		scene.addChild(loader);
		
		//add signature
		Signature = Lib.as(SignatureSwf.content, Sprite);
		SignatureBitmap = new Bitmap(new BitmapData(Std.int(Signature.width), Std.int(Signature.height), true, 0));
		SignatureBitmap.y = stage.stageHeight - Signature.height;
		stage.quality = StageQuality.HIGH;
		SignatureBitmap.bitmapData.draw(Signature);
		stage.quality = StageQuality.MEDIUM;
		addChild(SignatureBitmap);
		
		stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		stage.addEventListener(MouseEvent.CLICK, onMouseUp);
	}
	
	/**
	 * @inheritDoc
	 */
	override private function onPreRender():Void
	{
			scene.rotationX = (mouseX - stage.stageWidth/2)/5;
			scene.rotationZ = (mouseY - stage.stageHeight/2)/5;
			scene.rotationY++;
	}
	
	/**
	 * Listener function for mouse up event
	 */
	private function onMouseUp(?event:MouseEvent):Void
	{
		if (loaded)
			model.materialLibrary.getMaterial("material_0_1_0ID").material.debug = false;
	}
	
	/**
	 * Listener function for mouse down event
	 */
	private function onMouseDown(?event:MouseEvent):Void
	{
		if (loaded)
			model.materialLibrary.getMaterial("material_0_1_0ID").material.debug = true;
	}
}
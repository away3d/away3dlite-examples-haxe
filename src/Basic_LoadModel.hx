/*

3ds file loading example in away3dlite

Demonstrates:

How to use the Loader3D object to load and parse an external 3ds model.
How to extract material data and use it to set materials on a model.
how to access the children of a loaded 3ds model.

Code by Rob Bateman
rob@infiniteturtles.co.uk
http://www.infiniteturtles.co.uk

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
import away3dlite.cameras.HoverCamera3D;
import away3dlite.containers.ObjectContainer3D;
import away3dlite.containers.Scene3D;
import away3dlite.containers.View3D;
import away3dlite.core.utils.Cast;
import away3dlite.core.utils.Debug;
import away3dlite.events.Loader3DEvent;
import away3dlite.events.MouseEvent3D;
import away3dlite.loaders.Loader3D;
import away3dlite.loaders.Max3DS;
import away3dlite.materials.Material;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Loader;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.Lib;
import haxe.Resource;
import flash.display.StageQuality;
import net.hires.debug.Stats;

//[SWF(backgroundColor="#000000", frameRate="60", quality="MEDIUM", width="800", height="600")]

class Basic_LoadModel extends Sprite
{
	//signature swf
	//[Embed(source="assets/signature_lite.swf", symbol="Signature")]
	public var SignatureSwf:Loader;
	
	//ferrari texture
	//[Embed(source="assets/fskingr.jpg")]
	private var GreenPaint:Loader;
	
	//ferrari texture
	//[Embed(source="assets/fskin.jpg")]
	private var RedPaint:Loader;
			
	//ferrari texture
	//[Embed(source="assets/fskiny.jpg")]
	private var YellowPaint:Loader;
			
	//ferrari texture
	//[Embed(source="assets/fsking.jpg")]
	private var GreyPaint:Loader;
	
	//engine variables
	private var scene:Scene3D;
	private var camera:HoverCamera3D;
	private var view:View3D;
	
	//signature variables
	private var Signature:Sprite;
	private var SignatureBitmap:Bitmap;
	
	//material objects
	private var materialArray:Array<Material>;
	private var materialIndex:Int;
	
	//scene objects
	private var max3ds:Max3DS;
	private var loader:Loader3D;
	private var model:ObjectContainer3D;
	
	//navigation variables
	private var move:Bool;
	private var lastPanAngle:Float;
	private var lastTiltAngle:Float;
	private var lastMouseX:Float;
	private var lastMouseY:Float;
	
	private var filesToLoad:Int;
	
	/**
	 * Constructor
	 */
	public function new()
	{
		super();
		
		materialIndex = 0;
		Debug.active = true;
		Debug.redirectTraces = true;
		
		filesToLoad = 5;
		SignatureSwf = new Loader();
		loadResource(SignatureSwf, "signatureSwf");
		GreenPaint = new Loader();
		loadResource(GreenPaint, "greenPaint");
		RedPaint = new Loader();
		loadResource(RedPaint, "redPaint");
		YellowPaint = new Loader();
		loadResource(YellowPaint, "yellowPaint");
		GreyPaint = new Loader();
		loadResource(GreyPaint, "greyPaint");
		
	}
	
	public static function main()
	{
		Lib.current.addChild(new Basic_LoadModel());
	}
	
	private function loadResource(loader:Loader , resname:String)
	{
		loader.contentLoaderInfo.addEventListener("complete", onLoadComplete);
		loader.loadBytes(Resource.getBytes(resname).getData());
	}
	
	private function onLoadComplete(e:Event):Void 
	{
		Lib.trace(filesToLoad);
		if (--filesToLoad == 0)
			init();
	}
	
	/**
	 * Global initialise function
	 */
	private function init():Void
	{
		initEngine();
		initMaterials();
		initObjects();
		initListeners();
	}
	
	/**
	 * Initialise the engine
	 */
	private function initEngine():Void
	{
		scene = new Scene3D();
		
		camera = new HoverCamera3D();
		camera.panAngle = 45;
		camera.tiltAngle = 20;
		camera.hover(true);
		
		view = new View3D();
		view.scene = scene;
		view.camera = camera;
		
		//view.addSourceURL("srcview/index.html");
		addChild(view);
		
		//add signature
		Signature = Lib.as(SignatureSwf.content, Sprite);
		SignatureBitmap = new Bitmap(new BitmapData(Std.int(Signature.width),Std.int( Signature.height), true, 0));
		stage.quality = StageQuality.HIGH;
		SignatureBitmap.bitmapData.draw(Signature);
		stage.quality = StageQuality.MEDIUM;
		addChild(SignatureBitmap);
		
		addChild(new Stats());
	}
	
	/**
	 * Initialise the materials
	 */
	private function initMaterials():Void
	{
		materialArray = [Cast.material(GreenPaint.content), Cast.material(RedPaint.content), Cast.material(YellowPaint.content), Cast.material(GreyPaint.content)];
	}
	
	/**
	 * Initialise the scene objects
	 */
	private function initObjects():Void
	{
		max3ds = new Max3DS();
		max3ds.scaling = 100;
		max3ds.centerMeshes = true;
		max3ds.material = materialArray[materialIndex];
		
		loader = new Loader3D();
		loader.addEventListener(Loader3DEvent.LOAD_SUCCESS, onSuccess);
		loader.loadGeometry("assets/f360.3ds", max3ds);
		
		scene.addChild(loader);
		/*//
		var plane:Plane = new Plane();
		plane.segmentsH = 80;
		plane.segmentsW = 80;
		plane.material = new WireframeMaterial(0xFF0000);
		plane.bothsides = true;
		plane.yUp = false;
		plane.width = 500;
		plane.height = 500;
		scene.addChild(plane);
		//*/
	}
	
	/**
	 * Initialise the listeners
	 */
	private function initListeners():Void
	{
		addEventListener(Event.ENTER_FRAME, onEnterFrame);
		stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		stage.addEventListener(Event.RESIZE, onResize);
		onResize();
	}
	
	/**
	 * Navigation and render loop
	 */
	private function onEnterFrame(event:Event):Void
	{
		loader.handle.rotationY += 2;
		
		if (move) {
			camera.panAngle = 0.3*(stage.mouseX - lastMouseX) + lastPanAngle;
			camera.tiltAngle = 0.3*(stage.mouseY - lastMouseY) + lastTiltAngle;
		}
		
		//rotate the wheels
		if (model != null) {
			for (object in model.children) {
				if (object.name.indexOf("wheel") != -1)
					object.rotationX -= 10;
			}
		}
		
		camera.hover();
		view.render();
	}
			
	/**
	 * Listener function for loading complete event on loader
	 */
	private function onSuccess(event:Event):Void
	{
		model = Lib.as(loader.handle, ObjectContainer3D);
		
		model.rotationX = -90;
		
		model.addEventListener(MouseEvent3D.MOUSE_UP, onClickModel);
	}
	
	/**
	 * Listener function for mouse click on car
	 */
	private function onClickModel(event:MouseEvent3D):Void
	{
		materialIndex++;
		if (materialIndex > materialArray.length - 1)
			materialIndex = 0;
		
		model.materialLibrary.getMaterial("fskin").material = materialArray[materialIndex];
	}
	
	/**
	 * Mouse down listener for navigation
	 */
	private function onMouseDown(event:MouseEvent):Void
	{
		lastPanAngle = camera.panAngle;
		lastTiltAngle = camera.tiltAngle;
		lastMouseX = stage.mouseX;
		lastMouseY = stage.mouseY;
		move = true;
		stage.addEventListener(Event.MOUSE_LEAVE, onStageMouseLeave);
	}
	
	/**
	 * Mouse up listener for navigation
	 */
	private function onMouseUp(event:MouseEvent):Void
	{
		move = false;
		stage.removeEventListener(Event.MOUSE_LEAVE, onStageMouseLeave);     
	}
	
	/**
	 * Mouse stage leave listener for navigation
	 */
	private function onStageMouseLeave(event:Event):Void
	{
		move = false;
		stage.removeEventListener(Event.MOUSE_LEAVE, onStageMouseLeave);     
	}
	
	/**
	 * stage listener for resize events
	 */
	private function onResize(event:Event = null):Void
	{
		view.x = stage.stageWidth / 2;
		view.y = stage.stageHeight / 2;
		SignatureBitmap.y = stage.stageHeight - Signature.height;
	}
}
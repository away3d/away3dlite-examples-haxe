/*

Collada bones example in away3dlite

Demonstrates:

How to import an animated collada file that uses bones.
How to posiiton a mouse cursor that hovers over a plane.
how to duplicate animated geometry with the minimum processing overhead.

Code by Rob Bateman
rob@infiniteturtles.co.uk
http://www.infiniteturtles.co.uk

Models by Peter Kapelyan
flashnine@gmail.com
http://www.flashten.com/

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

import away3dlite.cameras.Camera3D;
import away3dlite.containers.ObjectContainer3D;
import away3dlite.containers.Scene3D;
import away3dlite.containers.View3D;
import away3dlite.core.render.BasicRenderer;
import away3dlite.core.utils.Cast;
import away3dlite.core.utils.Debug;
import away3dlite.events.MouseEvent3D;
import away3dlite.core.base.SortType;
import away3dlite.animators.BonesAnimator;
import away3dlite.core.base.Mesh;
import away3dlite.haxeutils.MathUtils;
import away3dlite.loaders.Collada;
import away3dlite.materials.BitmapMaterial;
import away3dlite.primitives.Plane;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Loader;
import flash.display.Sprite;
import flash.events.Event;
import flash.Lib;
import flash.utils.ByteArray;
import flash.display.StageQuality;
import haxe.Resource;

import net.hires.debug.Stats;


//[SWF(backgroundColor="#000000", frameRate="60", quality="LOW", width="800", height="600")]

class Advanced_MultiMario extends Sprite
{
	//grass texure for floor
	//[Embed(source="assets/floor.jpg")]
	/**
	 * Embedded file will be made accessible by the compiler switch -resource
	 * 
	 * @see Advanced_MultiMario.hxml
	 */
	public var Floor:Loader;
	
	//shadow texture for under mario
	//[Embed(source="assets/shadow.png")]
	/**
	 * Embedded file will be made accessible by the compiler switch -resource
	 * 
	 * @see Advanced_MultiMario.hxml
	 */
	public var Shade:Loader;
	
	//crosshair texture for mouse pointer
	//[Embed(source="assets/position.png")]
	/**
	 * Embedded file will be made accessible by the compiler switch -resource
	 * 
	 * @see Advanced_MultiMario.hxml
	 */
	public var Position:Loader;
	
	//texture for mario
	//[Embed(source="assets/mario_tex.jpg")]
	/**
	 * Embedded file will be made accessible by the compiler switch -resource
	 * 
	 * @see Advanced_MultiMario.hxml
	 */
	private var Charmap:Loader;
	
	//collada file for mario
	//[Embed(source="assets/mario_testrun.dae",mimeType="application/octet-stream")]
	/**
	 * Embedded file will be made accessible by the compiler switch -resource
	 * 
	 * @see Advanced_MultiMario.hxml
	 */
	private var Charmesh:String;
	
	//signature swf
	//[Embed(source="assets/signature_lite_peter.swf", symbol="Signature")]
	/**
	 * Embedded file will be made accessible by the compiler switch -resource
	 * 
	 * @see Advanced_MultiMario.hxml
	 */
	public var SignatureSwf:Loader;
	
	//engine variables
	private var camera:Camera3D;
	private var view:View3D;
	private var scene:Scene3D;
	
	//material variables
	private var material:BitmapMaterial;
	private var shadeMaterial:BitmapMaterial;
	private var positionMaterial:BitmapMaterial;
	private var floorMaterial:BitmapMaterial;
	
	//signature variables
	private var Signature:Sprite;
	private var SignatureBitmap:Bitmap;
	
	//objectvariables
	private var collada:Collada;
	private var model1:ObjectContainer3D;
	private var mesh:Mesh;
	private var model2:ObjectContainer3D;
	private var model3:ObjectContainer3D;
	private var model4:ObjectContainer3D;
	private var model5:ObjectContainer3D;
	private var model6:ObjectContainer3D;
	private var model7:ObjectContainer3D;
	private var model8:ObjectContainer3D;
	private var model9:ObjectContainer3D;
	private var position:Plane;
	private var shade1:Plane;
	private var shade2:Plane;
	private var shade3:Plane;
	private var shade4:Plane;
	private var shade5:Plane;
	private var shade6:Plane;
	private var shade7:Plane;
	private var shade8:Plane;
	private var shade9:Plane;
	private var floor:Plane;
	
	private var loadersLeft:Int;
	
	//animation varibles
	private var skinAnimation:BonesAnimator;
	
	//navigation variables
	private var rotate:Float;
	private var scrollX:Float;
	private var scrollY:Float;
	
	public static function main()
	{
		Debug.redirectTraces = true;
		Lib.current.addChild(new Advanced_MultiMario());
	}
	
	public function new()
	{
		loadersLeft = 0;
		prepareLoad(Floor = new Loader(), "floor");
		prepareLoad(Shade = new Loader(), "shade");
		prepareLoad(Position = new Loader(), "position");
		prepareLoad(Charmap = new Loader(), "charmap");
		prepareLoad(SignatureSwf = new Loader(), "signatureSwf");
		
		Debug.active = true;
		
		super();
	}
	
	function loadAndInit(?e:Event)
	{
		if (--loadersLeft == 1)
			init();
	}
	
	private function prepareLoad(loader:Loader, resourceName:String)
	{
		loadersLeft++;
		loader.contentLoaderInfo.addEventListener("complete", loadAndInit);
		loader.loadBytes( Resource.getBytes(resourceName).getData() );
	}
	
	/**
	 * Global initialise function
	 */
	private function init():Void
	{
		Debug.active = true;
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
		camera = new Camera3D();
		
		//view = new View3D({camera:camera, scene:scene});
		view = new View3D();
		view.camera = camera;
		view.scene = scene;
		view.renderer = new BasicRenderer();
		
		//view.addSourceURL("srcview/index.html");
		view.mouseZeroMove = true;
		addChild(view);
		
		//add signature
		Signature = Lib.as(SignatureSwf.content, Sprite);
		SignatureBitmap = new Bitmap(new BitmapData(Std.int(Signature.width), Std.int(Signature.height), true, 0));
		stage.quality = StageQuality.HIGH;
		SignatureBitmap.bitmapData.draw(Signature);
		stage.quality = StageQuality.LOW;
		addChild(SignatureBitmap);
		
		addChild(new Stats());
	}
	
	/**
	 * Initialise the materials
	 */
	private function initMaterials():Void
	{
		material = new BitmapMaterial(Cast.bitmap(Charmap.content));
		
		//floorMaterial = new TransformBitmapMaterial(Cast.bitmap(Floor), {repeat:true,scaleX:3,scaleY:3, precision:2});
		floorMaterial = new BitmapMaterial(Cast.bitmap(Floor.content));
		floorMaterial.repeat = true;
		//floorMaterial.scaleX = 3;
		//floorMaterial.scaleY = 3;
		
		shadeMaterial = new BitmapMaterial(Cast.bitmap(Shade.content));
		
		positionMaterial = new BitmapMaterial(Cast.bitmap(Position.content));
	}
	
	/**
	 * Initialise the scene objects
	 */
	private function initObjects():Void
	{
		collada = new Collada();
		collada.scaling = 10;
		Charmesh = Resource.getString("charmesh");
		model1 = cast collada.parseGeometry(Charmesh);
		model1.materialLibrary.getMaterial("FF_FF_FF_mario1").material = material;
		
		scene.addChild(model1);
		
		mesh = cast model1.getChildByName("polySurface1");
		mesh.mouseEnabled = false;
		
		model2 = new ObjectContainer3D();
		model2.addChild(mesh.clone());
		model2.x = 150;
		
		scene.addChild(model2);
		
		model3 = new ObjectContainer3D();
		model3.addChild(mesh.clone());
		model3.x = -150;
		
		scene.addChild(model3);
		
		model4 = new ObjectContainer3D();
		model4.addChild(mesh.clone());
		model4.z = 150;
		
		scene.addChild(model4);
		
		model5 = new ObjectContainer3D();
		model5.addChild(mesh.clone());
		model5.z = -150;
					
		scene.addChild(model5);
		
		model6 = new ObjectContainer3D();
		model6.addChild(mesh.clone());
		model6.z = -150;
		model6.x = -150;
		
		scene.addChild(model6);
		
		model7 = new ObjectContainer3D();
		model7.addChild(mesh.clone());
		model7.z = 150;
		model7.x = -150;
		
		scene.addChild(model7);
		
		model8 = new ObjectContainer3D();
		model8.addChild(mesh.clone());
		model8.z = 150;
		model8.x = 150;
		
		scene.addChild(model8);
		
		model9 = new ObjectContainer3D();
		model9.addChild(mesh.clone());
		model9.z = -150;
		model9.x = 150;
		
		scene.addChild(model9);
		
		position = new Plane();
		position._width = 50;
		position._height = 50;
		position.material = positionMaterial;
		position.mouseEnabled = false;
		
		scene.addChild(position);
		
		shade1 = new Plane();
		shade1.material = shadeMaterial;
		shade1.sortType = SortType.BACK;
		shade1.mouseEnabled = false;
		
		scene.addChild(shade1);
		
		shade2 = cast shade1.clone();
		shade2.x = 150;
		
		scene.addChild(shade2);
		
		shade3 = cast shade1.clone();
		shade3.x = -150;
		
		scene.addChild(shade3);
		
		shade4 = cast shade1.clone();
		shade4.z = 150;
		
		scene.addChild(shade4);
		
		shade5 = cast shade1.clone();
		shade5.z = -150;
		
		scene.addChild(shade5);
		
		shade6 = cast shade1.clone();
		shade6.z = -150;
		shade6.x = -150;
		
		scene.addChild(shade6);
		
		shade7 = cast shade1.clone();
		shade7.z = 150;
		shade7.x = -150;
		
		scene.addChild(shade7);
		
		shade8 = cast shade1.clone();
		shade8.z = 150;
		shade8.x = 150;
		
		scene.addChild(shade8);
		
		shade9 = cast shade1.clone();
		shade9.z = -150;
		shade9.x = 150;
		
		scene.addChild(shade9);
		
		floor = new Plane();
		floor._width = 600;
		floor._height = 600;
		floor.material = floorMaterial;
		//floor.ownCanvas = true;
		floor.sortType = SortType.BACK;
		scene.addChild(floor);
		
		//grabs an instance of the skin animation from the animationLibrary
		skinAnimation = cast model1.animationLibrary.getAnimation("default").animation;
		skinAnimation.loop = true;
	}
	
	/**
	 * Initialise the listeners
	 */
	private function initListeners():Void
	{
		scene.addEventListener(MouseEvent3D.MOUSE_MOVE, onMouseMove);
		addEventListener(Event.ENTER_FRAME, onEnterFrame);
		stage.addEventListener(Event.RESIZE, onResize);
		onResize();
	}
	
	/**
	 * Navigation and render loop
	 */
	private function onEnterFrame(event:Event):Void
	{
		//calculate the polar coordinate rotation for the cursor position on the floor plane
		rotate = (Math.floor(Math.atan2(-position.x, -position.z)*(180/MathUtils.PI)) + 180);
		
		//calculate scroll values for the floor material
		scrollY = Math.sin((rotate + 90)/180*MathUtils.PI)*5;
		scrollX = Math.cos((rotate + 90)/180*MathUtils.PI)*5;
		
		//apply scroll values to the floor material
		//floorMaterial.offsetX += scrollX;
		//floorMaterial.offsetY += scrollY;
		
		//update the rotation of each mario model
		model1.rotationY = rotate;
		model2.rotationY = rotate;
		model3.rotationY = rotate;
		model4.rotationY = rotate;
		model5.rotationY = rotate;
		model6.rotationY = rotate;
		model7.rotationY = rotate;
		model8.rotationY = rotate;
		model9.rotationY = rotate;
		
		//update the camera position
		camera.x = 0;
		camera.y = -70;
		camera.z = -10;
		camera.rotationX = -mouseY/20;
		camera.transform.matrix3D.prependTranslation(0, 0, mouseY/2 - 700);
		
		//update the collada animation
		skinAnimation.update(Lib.getTimer()*2/1000);
		
		//render scene
		view.render();
	}
	
	/**
	 * scene listener for crosshairs plane
	 */
	private function onMouseMove(e:MouseEvent3D):Void {
		position.x = e.scenePosition.x;
		position.z = e.scenePosition.z;
	}
	
	/**
	 * stage listener for resize events
	 */
	private function onResize(?event:Event):Void
	{
		view.x = stage.stageWidth / 2;
		view.y = stage.stageHeight / 2;
		SignatureBitmap.y = stage.stageHeight - Signature.height;
	}
}
package;
import away3dlite.core.utils.Debug;
import away3dlite.events.Loader3DEvent;
import away3dlite.materials.BitmapFileMaterial;
import away3dlite.primitives.Plane;
import away3dlite.primitives.Sphere;
import away3dlite.templates.FastTemplate;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Loader;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.filters.GlowFilter;
import flash.Lib;
import flash.display.StageQuality;
import haxe.Resource;

//[SWF(backgroundColor="#000000", frameRate="30", quality="MEDIUM", width="800", height="600")]
/**
 * Example : Layer
 * @author katopz
 */
class ExLayer extends FastTemplate
{
	//signature swf
	//[Embed(source="assets/signature_lite_katopz.swf", symbol="Signature")]
	private static var SignatureSwf:Loader;
	
	//signature variables
	private var Signature:Sprite;
	private var SignatureBitmap:Bitmap;
	private static var filesToLoad:Int;
	
	private function onClick(event:MouseEvent):Void
	{
		trace("! onClick : " +event);
		
		var layer:Sprite = Lib.as(event.target, Sprite);
		
		if(layer.filters.length==0)
			layer.filters = [new GlowFilter(0xFF0000, 1, 4, 4, 16, 1)];
		else
			layer.filters = null;
	}
	
	public static function main()
	{
		Debug.redirectTraces = true;
		Debug.active = true;
		
		filesToLoad = 1;
		SignatureSwf = new Loader();
		loadResource(SignatureSwf, "signatureSwf");
	}
	
	private static function onLoadComplete(e:Event):Void 
	{
		if (--filesToLoad == 0)
			Lib.current.addChild(new ExLayer());
	}
	
	private static function loadResource(loader:Loader , resname:String)
	{
		loader.contentLoaderInfo.addEventListener("complete", onLoadComplete);
		loader.loadBytes(Resource.getBytes(resname).getData());
	}
	
	override private function onInit():Void
	{
		title += " : Layer, Click plane to change filters"; 
		
		// index layer
		var plane:Plane;
		var i = -1;
		while (++i < 4)
		{
			// Plane
			plane = new Plane(new BitmapFileMaterial("assets/earth.jpg"), 256, 128,1,1);
			plane.bothsides = true;
			plane.rotationX = 45;
			plane.y = i*50 - 4*50/2;
			scene.addChild(plane);
			
			// Layer
			var layer:Sprite = new Sprite();
			layer.name = Std.string(i);
			view.addChild(layer);
			plane.layer = layer;
			
			// Event
			plane.layer.addEventListener(MouseEvent.CLICK, onClick);
		}
		
		// no layer test
		var earth:Sphere = new Sphere(new BitmapFileMaterial("assets/earth.jpg"), 100, 10, 10);
		scene.addChild(earth);
		
		// on top layer
		var moon:Sphere = new Sphere(new BitmapFileMaterial("assets/moon.jpg"), 25, 10, 10);
		scene.addChild(moon);
		moon.layer = new Sprite();
		view.addChild(moon.layer);
		
		// test filters
		moon.layer.filters = [new GlowFilter(0xFFFF00, 1, 4, 4, 16, 1)];
		
		//add signature
		Signature = Lib.as(SignatureSwf.content, Sprite);
		SignatureBitmap = new Bitmap(new BitmapData(Std.int(Signature.width), Std.int(Signature.height), true, 0));
		SignatureBitmap.y = stage.stageHeight - Signature.height;
		stage.quality = StageQuality.HIGH;
		SignatureBitmap.bitmapData.draw(Signature);
		stage.quality = StageQuality.MEDIUM;
		addChild(SignatureBitmap);
	}
	
	
	/**
	 * @inheritDoc
	 */
	override private function onPreRender():Void
	{
		scene.rotationY++;
	}
}
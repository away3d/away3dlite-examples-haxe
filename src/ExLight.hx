package;

import away3dlite.core.base.Object3D;
import away3dlite.events.Loader3DEvent;
import away3dlite.haxeutils.ResourceLoader;
import away3dlite.lights.DirectionalLight3D;
import away3dlite.lights.PointLight3D;
import away3dlite.loaders.Loader3D;
import away3dlite.loaders.MD2;
import away3dlite.materials.BitmapMaterial;
import away3dlite.materials.Dot3BitmapMaterial;
import away3dlite.templates.BasicTemplate;
import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.display.BitmapData;
import flash.geom.Vector3D;
import flash.Lib;

//[SWF(backgroundColor="#000000", frameRate="30", quality="MEDIUM", width="800", height="600")]
class ExLight extends BasicTemplate
{
	//[Embed(source="../src/assets/torso_marble256.jpg")]
	//private var Texture:Class;
	private static var Texture = new away3dlite.haxeutils.ResourceLoader<Bitmap>("Texture", Bitmap);

	//[Embed(source="../src/assets/torso_normal_256.jpg")]
	//private var Normal:Class;
	private static var Normal = new away3dlite.haxeutils.ResourceLoader<Bitmap>("Normal", Bitmap);

	private var model:Object3D;
	
	public static function main()
	{
		ResourceLoader.onComplete = function() { Lib.current.addChild(new ExLight()); };
		ResourceLoader.init();
	}

	override private function onInit():Void
	{
		var rLight = new DirectionalLight3D();
		rLight.direction = new Vector3D(1, 0, 0);
		rLight.color = 0xFF0000;
		rLight.ambient = 0.1;
		scene.addLight(rLight);

		var gLight = new DirectionalLight3D();
		gLight.direction = new Vector3D(0, 1, 0);
		gLight.color = 0x00FF00;
		gLight.ambient = 0.1;
		scene.addLight(gLight);

		var bLight = new DirectionalLight3D();
		bLight.direction = new Vector3D(0, 0, 1);
		bLight.color = 0x0000FF;
		bLight.ambient = 0.1;
		scene.addLight(bLight);

		var _texture:Bitmap = Texture.content;
		var _bitmap:BitmapData = new BitmapData(Std.int(_texture.width), Std.int(_texture.height), false);
		_bitmap.draw(_texture);

		var _normalMap:Bitmap = Normal.content;
		var material:BitmapMaterial = new Dot3BitmapMaterial(_bitmap, _normalMap.bitmapData);
		material.smooth = true;

		var md2:MD2 = new MD2();
		md2.material = material;
		md2.centerMeshes = true;

		var loader:Loader3D = new Loader3D();
		loader.loadGeometry("../src/assets/torsov2.MD2", md2);
		loader.addEventListener(Loader3DEvent.LOAD_SUCCESS, onSuccess);
		scene.addChild(loader);

		camera.z = -200;
	}

	private function onSuccess(event:Loader3DEvent):Void
	{
		model = event.loader.handle;
		model.rotationX = 90;
	}

	override private function onPreRender():Void
	{
		scene.rotationY++;
	}
}
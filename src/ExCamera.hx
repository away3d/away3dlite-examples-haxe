package;
import away3dlite.materials.BitmapFileMaterial;
import away3dlite.primitives.Sphere;
import away3dlite.templates.BasicTemplate;
import flash.events.KeyboardEvent;
import flash.geom.Vector3D;

//[SWF(backgroundColor="#000000", frameRate="30", quality="MEDIUM", width="800", height="600")]
/**
 * Camera pitch, yaw, roll example
 */
class ExCamera extends BasicTemplate
{
	private var _degrees:Vector3D;
	
	static function main()
	{
		flash.Lib.current.addChild(new ExCamera());
	}
	
	/**
	 * @inheritDoc
	 */
	override private function onInit():Void
	{
		title += " : Camera W,S=yaw | A,D=picth | Q,E=roll";

		_degrees = new Vector3D();
		
		var sphere:Sphere = new Sphere(new BitmapFileMaterial("assets/earth.jpg"), 100, 32, 32);
		scene.addChild(sphere);

		stage.addEventListener(KeyboardEvent.KEY_DOWN, keyHandler);
		stage.addEventListener(KeyboardEvent.KEY_UP, keyHandler);
	}

	private function keyHandler(event:KeyboardEvent):Void
	{
		_degrees = new Vector3D();
		
		switch (event.type)
		{
			case KeyboardEvent.KEY_DOWN:	
				switch (event.keyCode)
				{
					case "W".charCodeAt(0):
						_degrees.y--;
					case "S".charCodeAt(0):
						_degrees.y++;
					case "A".charCodeAt(0):
						_degrees.x++;
					case "D".charCodeAt(0):
						_degrees.x--;
					case "Q".charCodeAt(0):
						_degrees.z++;
					case "E".charCodeAt(0):
						_degrees.z--;
				}
		}
	}

	/**
	 * @inheritDoc
	 */
	override private function onPreRender():Void
	{
		camera.pitch(_degrees.y);
		camera.yaw(_degrees.x);
		camera.roll(_degrees.z);
	}
}
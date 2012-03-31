import de.polygonal.core.math.Mathematics;
import de.polygonal.core.Root;
import de.polygonal.gl.vector.VectorRenderer;
import de.polygonal.gl.Window;
import de.polygonal.core.math.Vec2;
import de.polygonal.motor.geom.primitive.AABB2;
import de.polygonal.motor.geom.primitive.Poly2;

class TestVectorRenderer
{
	static var _app:TestVectorRenderer;
	public static function main()
	{
		Root.initKeepNativeTrace = true;
		Window.initBackgroundColor = 0xffffff;
		Window.initUseHardware = false;
		de.polygonal.core.Root.init(onInit, true);
	}
	
	static function onInit()
	{
		_app = new TestVectorRenderer();
	}
	
	var _vr:VectorRenderer;
	
	public function new()
	{
		#if flash
		_vr = new de.polygonal.gl.vector.GraphicsPathRenderer(Window.surface.graphics, 256, 1024);
		#elseif js
		_vr = new de.polygonal.gl.vector.CanvasPathRenderer('c');
		#end
		
		//testArrowOutline(_vr);
		
		//testFont(_vr);
		//testBezier(_vr);
		
		testEllipse(_vr);
		
		//testDrawTriangle(_vr);
		//testDrawArc(_vr);
		//testDrawWedge(_vr);
		//testDrawCircle(_vr);
		
		//test(_vr);
		
		//testDrawSSL(_vr);
		//testDrawSSR(_vr);
		//testPoly(_vr);
		//testPolyline(_vr);
		//testGrid(_vr);
		//testDashedLine(_vr);
	}
	
	/*public function testFont(r:VectorRenderer)
	{
		var font = new de.polygonal.gl.vector.text.fonts.coreweb.Arial();
		font.bezierThreshold = .5;
		font.setRenderer(_vr);
		r.setLine();
		r.setFill(0xff00ff, .5);
		font.write('hello js!', 100, 100);
		r.clrFill();
		r.flush();
	}*/
	
	public function testHelix(r:VectorRenderer)
	{
		r.setLine();
		r.shape.drawHelix7(0, 0, 100, 200, 100, 2, 2);
		r.flush();
	}
	
	public function testArrowOutline(r:VectorRenderer)
	{
		r.setLine();
		r.shape.arrowOutline7(20, 20, 100, 100, 5, 20, 20);
		r.flush();
	}
	
	public function testBezier(r:VectorRenderer)
	{
		r.setLine();
		r.shape.bezier8(0, 0, 50, 50, 200, 50, 250, 0, 0, false);
		r.shape.moveTo2(250, 0);
		r.shape.bezier8(250, 0, 300, 100, 400, 100, 500, 100, 0, true);
		r.flush();
	}
	
	public function testEllipse(r:VectorRenderer)
	{
		r.setLine();
		r.shape.ellipse4(100, 100, 100, 50);
		r.flush();
	}
	
	public function test(r:VectorRenderer)
	{
		r.setLine(0xff0000, 1, 3);
		r.setFill(0x0000ff, 0.5);
		r.shape.circle3(100, 100, 20);
		
		r.clrFill();
		r.clrLine();
		
		//r.setLine(0x00ff00, 1, 3);
		r.shape.circle3(200, 100, 20);
		
		
		//r.clrLine();
		//r.setFill(0x0000ff, .5);
		//r.shape.circle3(300, 100, 20);
		//r.clrFill();
		
		
		//r.setLine(0x0000ff, 1, 2);
		//r.shape.circle3(400, 100, 20);
		
		
		r.flush();
		return;
		
		//r.setWinding(flash.display.GraphicsPathWinding.EVEN_ODD);
		r.setLine(0x00ff00, 0.5, 2);
		
		r.setFill(0x0000ff, 1);
		r.shape.circle3(100, 100, 20);
		r.clrFill();
		
		r.setFill(0xff0000, 1);
		r.shape.circle3(110, 95, 20);
		r.clrFill();
		//
		//
		//r.shape.circle3(105, 120, 10);
		
		r.flush();
	}
	
	public function testDrawCircle(vr:VectorRenderer):Void
	{
		vr.setLine();
		vr.shape.circle3(100, 100, 25);
		vr.flush();
	}
	
	public function testDrawTriangle(r:VectorRenderer):Void
	{
		r.setLine();
		r.shape.tri6(10, 10, 30, 15, 20, 30);
		r.shape.tri6(20, 20, 50, 35, 40, 50);
		r.flush();
	}
	
	public function testDrawArc(r:VectorRenderer):Void
	{
		r.setLine();
		r.shape.arc5(100, 100, 0, 90 * Mathematics.DEG_RAD, 20);
		r.flush();
	}
	
	public function testDrawWedge(r:VectorRenderer):Void
	{
		r.setLine();
		r.shape.wedge5(100, 100, 0, 45 * Mathematics.DEG_RAD, 20);
		r.flush();
	}
	
	public function testDrawSSL(r:VectorRenderer):Void
	{
		r.setLine();
		r.shape.ssl5(100, 100, 200, 200, 10);
		r.flush();
	}
	
	public function testDrawSSR(r:VectorRenderer):Void
	{
		r.setLine();
		r.shape.ssr5(100, 100, 50, 30, 20);
		r.flush();
	}
	
	public function testPoly(r:VectorRenderer):Void
	{
		r.setLine();
		
		var p = Poly2.createBlob(4, 20);
		p.transform(100, 100, 0);
		r.shape.poly(p, true);
		r.flush();
	}
	
	public function testPolyline(r:VectorRenderer):Void
	{
		r.setLine();
		
		//var vertexList = [0., 0., 50., 50., 100., 0., 200., 300.];
		//r.shape.polylineScalar(vertexList, false);
		
		var vertexList = [new Vec2(0, 0), new Vec2(50, 50), new Vec2(100, 0), new Vec2(200, 300)];
		r.shape.polylineVector(cast vertexList, false);
		
		r.flush();
	}
	
	public function testDashedLine(r:VectorRenderer):Void
	{
		r.setLine();
		
		r.shape.dashedLine4(100, 100, 200, 150, 4, 4);
		
		r.flush();
	}
	
	function testGrid(vr:VectorRenderer):Void 
	{
		vr.setLine();
		
		vr.shape.grid6(20, 50, 50, 250, 250, true);
		
		vr.flush();
	}
}
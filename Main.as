

package 
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.display.LineScaleMode;
	import flash.display.CapsStyle;
	import flash.display.JointStyle;
	import flash.display.Shape;
	import fl.transitions.Tween;
	import fl.transitions.easing.Strong;
	import fl.transitions.easing.Back;



	public class Main extends MovieClip
	{
		private var dots:Array = [];
		private var path:Array = [];
		private var dotslink:Shape = null;
		private var last_dot_index:int = -1;

		private var lastX:Number = 0;
		private var lastY:Number = 0;
		private var trace_path:Array = [];
		
		private var work_mode_:String = null;
		private var banner_:MovieClip = null;
		private var tween_:Tween;
		
		private var trace_line_drawer_:TraceLineDrawer = null;

		public function Main():void
		{
			trace_line_drawer_ = new TraceLineDrawer(this, 200);
			dots = [one,two,three,four,five,six,seven,eight,nine];
			addListeners();
			do_init();
		}
		
		private function do_init()
		{
			var m:String = loaderInfo.parameters["m"];
			if (!m)
			{
				m = WorkMode.CREATE;
			}

			switch(m)
			{
				case WorkMode.CREATE:
					banner_ = new CreateIntro();
					break;
				case WorkMode.VERIFY:
					banner_ = new CreateVerify();
					break;
				case WorkMode.DELETE:
					break;
				case WorkMode.MODIFY:
					break;
			}
			if (banner_)
			{
				work_mode_ = m;
				addChild(banner_);
				tween_ = new Tween(banner_,"x",Strong.easeOut,320,0,0.8,true);
			}
		}

		private function addListeners():void
		{
			var dotsLength:int = dots.length;

			for (var i:int = 0; i < dotsLength; i++)
			{
				dots[i].addEventListener(MouseEvent.MOUSE_DOWN, initiatePattern);
				dots[i].alpha=0.6;
			}
		}

		private function initiatePattern(e:MouseEvent):void
		{
			path = [];

			var dotsLength:int = dots.length;
			e.target.alpha = 1;

			for (var i:int = 0; i < dotsLength; i++)
			{
				dots[i].addEventListener(MouseEvent.MOUSE_OVER, addPattern);
				dots[i].addEventListener(MouseEvent.MOUSE_OUT, mouseMoveOut);
			}
			stage.addEventListener(MouseEvent.MOUSE_MOVE, drawTraceLine);
			stage.addEventListener(MouseEvent.MOUSE_UP, stopPattern);

			path.push(dots.indexOf(e.target));

			last_dot_index = dots.indexOf(e.target);
		}
		private function mouseMoveOut(e:MouseEvent)
		{
			e.target.alpha = 0.6;
		}

		private function addPattern(e:MouseEvent):void
		{
			var index:int = dots.indexOf(e.target);
			e.target.removeEventListener(MouseEvent.MOUSE_OVER, addPattern);
			e.target.alpha = 1;
			path.push(index);

			if (false)
			{
				dotslink = new Shape();
				this.addChild(dotslink);

				dotslink.graphics.lineStyle(10, 0xFFD700, 1, false, LineScaleMode.VERTICAL,
				                               CapsStyle.ROUND, JointStyle.ROUND, 10);
				dotslink.graphics.moveTo(75+(last_dot_index%3)*85, 121+int(last_dot_index/3)*85);
				dotslink.graphics.lineTo(75+(index%3)*85, 121+int(index/3)*85);
				last_dot_index = index;
			}
		}

		private function stopPattern(e:MouseEvent):void
		{
			var dotsLength:int = dots.length;

			for (var i:int = 0; i < dotsLength; i++)
			{
				dots[i].removeEventListener(MouseEvent.MOUSE_OVER, addPattern);
			}
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, drawTraceLine);
			checkPattern();
		}

		private function checkPattern():void
		{
			var pLength:int = path.length;
			var pass:String = "";

			for (var i:int = 0; i < pLength; i++)
			{
				pass +=  path[i];
			}
			pwdt.text = pass;

			if (work_mode_ == WorkMode.CREATE)
			{
				drawPattern();
				removeChild(banner_);
				banner_ = new CreateConfirm();
				addChild(banner_);
				var tween:Tween = new Tween(banner_,"x",Strong.easeOut,320,0,0.8,true);
			}
		}

		function drawTraceLine(e:MouseEvent)
		{
			var x:Number = stage.mouseX;
			var y:Number = stage.mouseY;
			trace_line_drawer_.addPoint(stage.mouseX, stage.mouseY);
			trace_line_drawer_.draw();
		}
		
		function drawPattern()
		{
			if (path.length < 1)
			{
				return;
			}
			
			dotslink = new Shape();
			dotslink.graphics.lineStyle(10, 0xFFD700, 1, false, LineScaleMode.VERTICAL,
				                               CapsStyle.ROUND, JointStyle.ROUND, 10);
			this.addChild(dotslink);
			trace(path[0]);
			dotslink.graphics.moveTo(dots[path[0]].x, dots[path[0]].y);
			for (var i:int = 0; i < path.length; i++)
			{
				dotslink.graphics.lineTo(dots[path[i]].x, dots[path[i]].y);
			}
		}
	}
}
import flash.display.Shape;
import flash.display.CapsStyle;
import flash.display.JointStyle;
import flash.display.LineScaleMode;

internal final class WorkMode
{
	public static const CREATE:String = "create";
	public static const DELETE:String = "delete";
	public static const VERIFY:String = "verify";
	public static const MODIFY:String = "modify";
}

internal class TracePoint
{
	public var len_:uint = 0;
	public var x_:uint = 0;
	public var y_:uint = 0;

	public function TracePoint(x:uint, y:uint, len:uint)
	{
		len_ = len;
		x_ = x;
		y_ = y;
	}
}

internal class TraceLineDrawer
{
	import flash.geom.Point;

	private var canvas_:Main = null;
	private var expect_len_:uint = 0;
	private var points_:Array = [];
	private var line_:Shape = null;

	public function TraceLineDrawer(canvas:Main, len:uint)
	{
		expect_len_ = len;
		canvas_ = canvas;
	}

	public function addPoint(x:uint, y:uint)
	{
		if (points_.length == 0)
		{
			points_.unshift(new TracePoint(x, y, 0));
		}
		else
		{
			var last_point:TracePoint = points_[0];
			points_.unshift(new TracePoint(x, y, Point.distance(new Point(x, y), new Point(last_point.x_, last_point.y_))));
		}
	}

	public function draw()
	{
		if (points_.length < 2)
		{
			return;
		}

		if (line_)
		{
			canvas_.removeChild(line_);
			line_ = null;
		}
		var left_len:Number = expect_len_;
		line_ = new Shape();
		canvas_.addChild(line_);
								 
		var i:uint = 0;
		line_.graphics.moveTo(points_[i].x_, points_[i].y_);

		for (i = 1; i<points_.length; i++)
		{
			line_.graphics.lineStyle(5, 0xFFD700, left_len/expect_len_, false, LineScaleMode.NORMAL,
									 CapsStyle.NONE, JointStyle.ROUND, 10);
			line_.graphics.lineTo(points_[i].x_, points_[i].y_);
			left_len -= points_[i].len_;
			if (left_len <= 0)
			{
				points_.splice(i);
				break;
			}
		}
	}

	public function clear()
	{
		points_ = [];
	}
}

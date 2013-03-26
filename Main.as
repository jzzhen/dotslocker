

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
		private var dotsline_:Shape = null;

		private var lastX:Number = 0;
		private var lastY:Number = 0;
		private var trace_path:Array = [];
		
		private var work_mode_:String = null;
		private var banner_:MovieClip = null;
		private var tween_:Tween;
		private var newpwd_ = "";
		
		private var trace_line_drawer_:TraceLineDrawer = null;

		public function Main():void
		{
			trace_line_drawer_ = new TraceLineDrawer(this, 200);
			dots = [one,two,three,four,five,six,seven,eight,nine];
			
			var m:String = loaderInfo.parameters["m"]
			if (!m)
			{
				m = WorkMode.CREATE;
			}
			do_init(m);
		}
		
		private function do_init(m:String)
		{
			// remove dot-lines
			if (dotsline_)
			{
				this.removeChild(dotsline_);
				dotsline_ = null;
			}
			
			showBanner(m);
			enablePatternPannel(m);
		}
		
		private function showBanner(m:String)
		{
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
		
		private function enablePatternPannel(m:String)
		{
			for each (var dot:MovieClip in dots)
			{
				dot.addEventListener(MouseEvent.MOUSE_DOWN, startPattern);
				dot.alpha=0.6;
			}
		}
		
		private function disablePatternPannel()
		{
			for each (var dot:MovieClip in dots)
			{
				dot.removeEventListener(MouseEvent.MOUSE_DOWN, startPattern);
				disableDot(dot);
			}
		}

		private function startPattern(e:MouseEvent):void
		{
			path = [];

			for each (var dot:MovieClip in dots)
			{
				enableDot(dot);
			}
			stage.addEventListener(MouseEvent.MOUSE_MOVE, drawTraceLine);
			stage.addEventListener(MouseEvent.MOUSE_UP, stopPattern);
			
			addPattern(e);
		}
		
		private function enableDot(dot:MovieClip)
		{
			dot.addEventListener(MouseEvent.MOUSE_OVER, addPattern);
			dot.addEventListener(MouseEvent.MOUSE_OUT, mouseMoveOut);
		}
		
		private function disableDot(dot:MovieClip)
		{
			dot.removeEventListener(MouseEvent.MOUSE_OVER, addPattern);
			dot.removeEventListener(MouseEvent.MOUSE_OUT, mouseMoveOut);
		}
		
		private function mouseMoveOut(e:MouseEvent)
		{
			e.target.alpha = 0.6;
			disableDot(e.target as MovieClip);
		}

		private function addPattern(e:MouseEvent):void
		{
			var index:int = dots.indexOf(e.target);
			e.target.alpha = 1;
			path.push(index);
		}

		private function stopPattern(e:MouseEvent):void
		{
			var dotsLength:int = dots.length;

			for each (var dot:MovieClip in dots)
			{
				dot.removeEventListener(MouseEvent.MOUSE_OVER, addPattern);
			}
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, drawTraceLine);
			stage.removeEventListener(MouseEvent.MOUSE_UP, stopPattern);
			disablePatternPannel();
			checkPattern();
		}

		private function checkPattern():void
		{
			var pLength:int = path.length;
			var pass:String = "";

			for each (var index:int in path)
			{
				pass +=  index;
			}
			pwdt.text = pass;

			if (work_mode_ == WorkMode.CREATE)
			{
				newpwd_ = pass;
				trace_line_drawer_.clear();
				drawPattern();
				
				// 
				removeChild(banner_);
				banner_ = new CreateConfirm();
				addChild(banner_);
				var tween:Tween = new Tween(banner_,"x",Back.easeOut,320,0,0.8,true);
				banner_.btnBackward.addEventListener(MouseEvent.CLICK, function(){do_init(WorkMode.CREATE);});
				banner_.btnForward.addEventListener(MouseEvent.CLICK, function(){do_init(WorkMode.VERIFY);});
			}
			else if (work_mode_ == WorkMode.VERIFY)
			{
				if (newpwd_)
				{
					if (pass == newpwd_)
					{
						banner_ = new CreateSuc();
						addChild(banner_);
						tween_ = new Tween(banner_,"x",Strong.easeOut,320,0,0.8,true);
					}
					else
					{
						do_init(WorkMode.CREATE);
					}
				}
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
			
			dotsline_ = new Shape();
			dotsline_.graphics.lineStyle(10, 0xFFD700, 1, false, LineScaleMode.VERTICAL,
				                               CapsStyle.ROUND, JointStyle.ROUND, 10);
			this.addChild(dotsline_);
			dotsline_.graphics.moveTo(dots[path[0]].x, dots[path[0]].y);
			for each (var index:int in path)
			{
				dots[index].alpha = 1;
				dotsline_.graphics.lineTo(dots[index].x, dots[index].y);
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
		canvas_.removeChild(line_);
		line_ = null;
		points_ = [];
	}
}

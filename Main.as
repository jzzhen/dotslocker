

package 
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.display.LineScaleMode;
	import flash.display.CapsStyle;
	import flash.display.JointStyle;
	import flash.display.Shape;



	public class Main extends MovieClip
	{
		private var dots:Array = [];
		private var path:Array = [];
		private var dotslink:Shape = null;
		private var last_dot_index:int = -1;

		private var lastX:Number = 0;
		private var lastY:Number = 0;
		private var trace_path:Array = [];

		private var init:Boolean = false;

		public function Main():void
		{
			dots = [one,two,three,four,five,six,seven,eight,nine];
			addListeners();
		}

		private function addListeners():void
		{
			var dotsLength:int = dots.length;

			for (var i:int = 0; i < dotsLength; i++)
			{
				dots[i].addEventListener(MouseEvent.MOUSE_DOWN, initiatePattern);
				dots[i].addEventListener(MouseEvent.MOUSE_UP, stopPattern);
			}
		}

		private function initiatePattern(e:MouseEvent):void
		{
			//startListening();
			var dotsLength:int = dots.length;

			for (var i:int = 0; i < dotsLength; i++)
			{
				dots[i].addEventListener(MouseEvent.MOUSE_OVER, addPattern);
			}
			stage.addEventListener(MouseEvent.MOUSE_MOVE, duplicateCircle);

			path.push(dots.indexOf(e.target) + 1);

			last_dot_index = dots.indexOf(e.target);
		}

		private function addPattern(e:MouseEvent):void
		{
			var index:int = dots.indexOf(e.target);
			path.push(index + 1);

			if (dotslink)
			{
				this.removeChild(dotslink);
			}

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
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, duplicateCircle);
			checkPattern();

			if (dotslink)
			{
				this.removeChild(dotslink);
			}
			dotslink = null;
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

			path = [];
		}

		function duplicateCircle(e:MouseEvent)
		{
			var x:Number = stage.mouseX;
			var y:Number = stage.mouseY;

			if (init==false)
			{
				init = true;
				lastX = x;
				lastY = y;
			}
			else
			{
				var trace_line:TraceLine = new TraceLine(this);
				trace_line.draw(lastX, lastY, x, y);
				trace_path.push(trace_line);
				lastX = x;
				lastY = y;
				
				if (trace_path.length > 100)
				{
					trace_path.shift().fade(0);
				}
				
				for (var i:int = 0; i<trace_path.length; i++)
				{
					trace_path[i].fade((2*i)/100.0);
					if ( i > 50 )
						break;
				}
			}
		}

	}
}
	internal class TraceLine
	{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.display.LineScaleMode;
	import flash.display.CapsStyle;
	import flash.display.JointStyle;
	import flash.display.Shape;
	import fl.transitions.*;
 import fl.transitions.easing.*;

private var len_:uint = 0;
		private var line_:Shape = null;
		private var parent_:Main = null;

		public function TraceLine(parent:Main)
		{
			parent_ = parent;
		}
		
		public function length():uint
		{
			return len_;
		}

		public function draw(startX:int, startY:int, endX:int, endY:int)
		{
			len_ = 1;
			
			line_ = new Shape();
			parent_.addChild(line_);

			line_.graphics.lineStyle(5, 0xFFD700, 1, false, LineScaleMode.VERTICAL,
			                               CapsStyle.ROUND, JointStyle.ROUND, 10);
			line_.graphics.moveTo(startX, startY);
			line_.graphics.lineTo(endX, endY);
			line_.graphics.lineStyle(5, 0x00D700, .1, false, LineScaleMode.VERTICAL,
			                               CapsStyle.ROUND, JointStyle.ROUND, 10);
			line_.graphics.lineTo(endX+5, endY+5);

		}

		public function fade(al:Number)
		{
			line_.alpha = al;
//TransitionManager.start(line_, {type:Fade, direction:Transition.IN, duration:9, easing:Strong.easeOut});;
		}
	}
	
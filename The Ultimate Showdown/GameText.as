package  {
	import flash.display.MovieClip;
	import flash.events.TimerEvent;
	import flash.text.*;
	import flash.utils.Timer;
	
	public class GameText extends MovieClip {
		//var your_parent:Object;
		var timer:Timer;
		var t_msg:TextField;

		public function GameText(parent:Object, msg:String, format:TextFormat, x, y, time:Number) {
			//your_parent = parent;
			timer = new Timer(time, 1);
			
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, Remove);
			
			t_msg = new TextField();
			t_msg.text = msg;
			t_msg.selectable = false;
			t_msg.setTextFormat(format);
			t_msg.autoSize = TextFieldAutoSize.LEFT;
			this.addChild(t_msg);
			parent.addChild(this);
			t_msg.width = stage.stageWidth;
			t_msg.height = stage.stageHeight;
			t_msg.y = y - (t_msg.height / 2);
			t_msg.x = x - (t_msg.width / 2);
			timer.start();
			
		}
		function Remove(e:TimerEvent){
			timer.removeEventListener(TimerEvent.TIMER_COMPLETE, Remove);
			this.removeChild(t_msg);
			parent.removeChild(this);
			
		}
		
		public function Remove_Manual() {
			timer.removeEventListener(TimerEvent.TIMER_COMPLETE, Remove);
			this.removeChild(t_msg);
			if(parent.contains(this) && this != null) {
				parent.removeChild(this);
			}
		}
	}
}

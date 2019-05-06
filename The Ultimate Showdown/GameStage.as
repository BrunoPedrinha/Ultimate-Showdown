package  {
	import flash.display.MovieClip;
	
	public class GameStage extends MovieClip {
		
		public function GameStage(parent:Object, width, height:Number) {
			this.width = width;
			this.height = height;
			parent.addChild(this);
		}

	}
	
}

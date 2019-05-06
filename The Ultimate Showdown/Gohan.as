package  {
	
	public class Gohan extends GameCharacter {

		public function Gohan(parent: Object, p_number: Number) {
			super(parent, p_number);
			walk_frame = 8;
			punch_frame = 10;
			kick_frame = 14;
			jump_frame = 19;
			drop_frame = 19;
			ko_frame = 20;
			stun_frame = 29;
			
			punch_power = 23;
			kick_power = 27;
		}
		
		public override function Special_Attack() {
			super.Special_Attack();
			var speed: Vector2D = new Vector2D(13, 0);
			if(scaleX < 0) {
				speed = speed.scalarMultiplication(-1);
			}
			new Hadoken(parent, this.pos.getX(), this.pos.getY(), 0, 0, speed, 80, player_number);
		}
	}
}

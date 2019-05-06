package  {
	
	public class Mario extends GameCharacter {
		
		public function Mario(parent: Object, p_number: Number) {
			super(parent, p_number);
			walk_frame = 11;
			punch_frame = 19;
			kick_frame = 23;
			jump_frame = 30;
			drop_frame = 31;
			ko_frame = 32;
			stun_frame = 41;
			
			punch_power = 23;
			kick_power = 28;
		}
		
		public override function Special_Attack() {
			super.Special_Attack();
			var speed: Vector2D = new Vector2D(10, -40);
			if(scaleX < 0) {
				speed = speed.scalarMultiplication(-1);
			}
			new Fireball(parent, this.pos.getX(), this.pos.getY(), 0, 0, speed, 100, player_number);
		}
	}
}

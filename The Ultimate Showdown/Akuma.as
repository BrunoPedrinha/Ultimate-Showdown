package  {
	
	public class Akuma extends GameCharacter {
		
		public function Akuma(parent: Object, p_number: Number) {
			super(parent, p_number);
			walk_frame = 22;
			punch_frame = 31;
			kick_frame = 37;
			jump_frame = 45;
			drop_frame = 45;
			ko_frame = 46;
			stun_frame = 73;
			
			punch_power = 25;
			kick_power = 35;
		}
		
		public override function Special_Attack() {
			super.Special_Attack();
			var speed: Vector2D = new Vector2D(10, 0);
			if(scaleX < 0) {
				speed = speed.scalarMultiplication(-1);
			}
			new Hadoken(parent, this.pos.getX(), this.pos.getY(), 0, 0, speed, 100, player_number);
		}
	}
}

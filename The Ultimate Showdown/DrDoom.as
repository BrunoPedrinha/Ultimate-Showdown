package  {
	
	public class DrDoom extends GameCharacter {
		
		public function DrDoom(parent: Object, p_number: Number) {
			super(parent, p_number);
			walk_frame = 26;
			punch_frame = 35;
			kick_frame = 43;
			jump_frame = 54;
			drop_frame = 55;
			ko_frame = 56;
			stun_frame = 69;
			
			punch_power = 25;
			kick_power = 32;
		}
	}
}

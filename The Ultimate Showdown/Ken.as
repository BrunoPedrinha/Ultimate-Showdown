package  {
	
	public class Ken extends GameCharacter {
		
		public function Ken(parent: Object, p_number: Number) {
			super(parent, p_number);
			walk_frame = 15;
			punch_frame = 31;
			kick_frame = 36;
			jump_frame = 47;
			drop_frame = 48;
			ko_frame = 49;
			stun_frame = 62;
			
			punch_power = 25;
			kick_power = 35;
		}
	}
}

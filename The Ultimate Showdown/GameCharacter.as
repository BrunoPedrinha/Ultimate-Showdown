package  {
	import flash.display.MovieClip;
	import flash.geom.Point;
	import flash.events.*;
	import flash.utils.*;
	import flash.text.*;
	import flash.geom.Rectangle;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.net.URLRequest;
	
	public class GameCharacter extends MovieClip {
		// animation variables
		// these act similarly to frame names
		var stance_frame = 1, walk_frame, jump_frame, drop_frame, punch_frame, kick_frame, ko_frame, stun_frame: Number;
		// determines the y coordinate of the base of the character so it doesn't go past the floor of the stage
		var feet_box: Number;
		// variables for time based animation
		var accumulated_steps: Number = 0;
		var last_timer: Number = getTimer();
		
		// combat variables, vitality, etc
		var hp, hp_max: Number = 1000;
		//var stamina, stamina_max: Number = 300;
		var special, special_max: Number = 1000;
		var last_hit, get_up, combo, punch_power, kick_power: Number = 0;
		// store the keys pressed for special moves
		var key_sequence: Array;
		// variable for the key sequence delay
		var last_key: Number;
		// use getTimer() for this since it's based on time as opposed to boolean
		var last_action: Number = 0;
		var apply_gravity, jumping, attacking, ko, recovering, invincible, stunned: Boolean;
		var dmgbox_list, hitbox_list, combo_sequence: Array;
		var health_bar: HealthBar;
		
		// other variables
		var player_number: Number;
		var speed: Number = 200;
		var mass: Number = 50;
		var v_i, v_f, force_burst, pos: Vector2D;
		const hud_padding: Number = 10;
		var hit_sound: Sound;
		
		// constructor with arguments for parent and "player number"
		public function GameCharacter(parent: Object, p_number: Number) {
			/*temp values*/
			punch_power = 30;
			kick_power = 500;
			/*end*/
			// initialize variables
			player_number = p_number;
			hp = hp_max;
			//stamina = stamina_max;
			special = combo = 0;
			apply_gravity = true;
			v_i = v_f = force_burst = new Vector2D(0, 0);
			// apply the FeetBox
			for(var i:uint = 0; i<numChildren; ++i) {
				if(this.getChildAt(i) is FeetBox) {
					feet_box = this.getChildAt(i).y;
					break;
				}
			}
			// add a health bar
			health_bar = new HealthBar();
			parent.addChild(health_bar);
			parent.addChild(this);
			var _p_num = new p_num();
			_p_num.x -= _p_num.width / 2;
			_p_num.y = feet_box - this.height - (_p_num.height * 2);
			if(p_number == 2) {
				_p_num.gotoAndStop(2);
				pos = new Vector2D(stage.stageWidth * 0.75, 0);
				health_bar.x = stage.stageWidth - health_bar.width - hud_padding;
			} else {
				pos = new Vector2D(stage.stageWidth * 0.25, 0);
				health_bar.x = hud_padding;
			}
			x = pos.getX();
			y = pos.getY();
			key_sequence = new Array();
			hit_sound = new punch();
			this.addChild(_p_num);
			health_bar.y = hud_padding;
			health_bar.gotoAndStop(100);
			this.addEventListener(Event.ENTER_FRAME, Update);
		}
		
		private function Update(e: Event) {
			if(!Get_Target()) {
				return;
			}
			// get the time elapsed
			var time_elapsed = (getTimer() - last_timer) / 1000;
			last_timer = getTimer();
			if(last_key + 700 < last_timer) {
				key_sequence = new Array();
			}
			if(last_hit + 1000 < last_timer){
				combo = 0;
				Display_Combo(0);
			}
			// update the HUD bars and direction
			UpdateHUD();
			Update_Direction();
			// character cannot move if it's stunned/restricted
			if(Game.restrict_movement || stunned) {
				return;
			}
			else {
				// control movement based on what keys are being pressed
				if(player_number == 1 && Game.w_pressed || player_number == 2 && Game.up_pressed) {
					Jump();
				}
				if((player_number == 1 && Game.a_pressed && !Game.d_pressed) || 
				   (player_number == 2 && Game.left_pressed && !Game.right_pressed)) {
					// move x coordinate
					Check_Movement(true, time_elapsed);
					if(Check_Animation(false)) {
						// if the character is not in the movement loop frames, put it there
						if(currentFrame < walk_frame) {
							gotoAndStop(walk_frame);
						} else {
							// control movement frames by time elapsed...
							// increment the frame every X seconds
							accumulated_steps += time_elapsed;
							// in this case, every 0.06 seconds
							if(accumulated_steps > 0.06) {
								accumulated_steps = 0;
								gotoAndStop(currentFrame + 1);
							}
						}
					}
				}
				else if((player_number == 1 && Game.d_pressed && !Game.a_pressed) || 
				   (player_number == 2 && Game.right_pressed && !Game.left_pressed)) {
					// move x coordinate
					Check_Movement(false, time_elapsed);
					if(Check_Animation(false)) {
						// if the character is not in the movement loop frames, put it there
						if(currentFrame < walk_frame) {
							gotoAndStop(walk_frame);
						} else {
							// control movement frames by time elapsed...
							// increment the frame every X seconds
							accumulated_steps += time_elapsed;
							// in this case, every 0.06 seconds
							if(accumulated_steps > 0.06) {
								accumulated_steps = 0;
								gotoAndStop(currentFrame + 1);
							}
						}
					}
				} else {
					Reset_Animation();
				}
			}
		}
		
		function Get_BoundingBox(): Rectangle {
			return new Rectangle(pos.getX() - 40, pos.getY(), 40, height);
		}
		
		// check to see if movement is valid or if characters are going on top of each other
		private function Check_Movement(left: Boolean, time_elapsed: Number) {
			var new_x = pos.getX();
			if(left) {
				new_x -= (speed * time_elapsed);
			} else {
				new_x += (speed * time_elapsed);
			}
			var target: GameCharacter = Get_Target();
			var my_bound: Rectangle = Get_BoundingBox();
			//my_bound.x = new_x;
			var tar_bound: Rectangle = target.Get_BoundingBox();
			// resolve collisions
			if(left && my_bound.left < 0) {
				return;
			} else if(!left && my_bound.width + new_x > stage.stageWidth) {
				return;
			}
			if(my_bound.intersects(tar_bound)) {
				if(scaleX < 0 && left){
					new_x = tar_bound.right + width / 2;
					if(!target.Pushed(new Vector2D(-2, 0))) {
					   new_x += 1;
					   pos.setX(new_x);
					}
				} else if(scaleX > 0 && !left){
					new_x = tar_bound.left;
					if(!target.Pushed(new Vector2D(2, 0))) {
						new_x -= 1;
						pos.setX(new_x);
					}
				} else {
					pos.setX(new_x);
				}
			} else {
				pos.setX(new_x);
			}
			x = pos.getX();
		}
		// same as check movement, except for falling on top of one another
		// return true when there is a collision
		public function Check_Fall(): Boolean {
			var target: GameCharacter = Get_Target();
			var b: Boolean;
			var my_bound: Rectangle = Get_BoundingBox();
			var tar_bound: Rectangle = target.Get_BoundingBox();
			if(my_bound.intersects(tar_bound)) {
				if(scaleX > 0) {
					target.Pushed(new Vector2D(5, 0));
					this.Pushed(new Vector2D(-5, 0));
				} else {
					target.Pushed(new Vector2D(-5, 0));
					this.Pushed(new Vector2D(5, 0));
				}
				b = true;
			}
			return b;
		}
		
		public function Apply_Gravity(time_elapsed: Number) {
			//var dt = (getTimer() - last_timer) / 1000; // innacurate
			// this is the interval of "gravity_timer"
			var dt = time_elapsed;
			// calculate the forces and acceleration of the character
			var force_net: Vector2D = Game.force_gravity.addVector(force_burst);
			// once force burst has been added to the calculations, reset it
			force_burst = new Vector2D(0, 0);
			var accel: Vector2D = force_net.scalarDivision(mass);
			// calculate the velocity and position
			var old_y = pos.getY();
			v_f = v_i.addVector(accel.scalarMultiplication(dt));
			pos = pos.addVector(v_i.scalarMultiplication(dt).addVector(accel.scalarMultiplication(0.5).scalarMultiplication(dt).scalarMultiplication(dt)));
			v_i = v_f;
			// check if the character is on the floor
			// if it isn't, play its jumping animation
			if(!Floor()) {
				// 'true' is just a boolean which means there's a jump involved
				if(Check_Animation(true)) {
					if(v_i.getY() < 0) {
						gotoAndStop(jump_frame);
					} else {
						gotoAndStop(drop_frame);
					}
				}
				if(v_i.getY() > 0 && Check_Fall()){
					var new_y = old_y + 3
					pos.setY(new_y);
				}
			}
		}
		
		// get a target based on player_number's
		private function Get_Target(): GameCharacter {
			var target: GameCharacter = Game.in_game[0];
			if(target == null){
				Remove()
				return null;
			}
			if(player_number == 1) {
				target = Game.in_game[1];
				if(target == null){
					Remove()
					return null;
				}
			}
			return target;
		}
		
		// update the facing direction
		private function Update_Direction() {
			var target: GameCharacter = Get_Target();
			if(x > target.x) {
				if(scaleX > 0) {
					scaleX *= -1;
				}
			} else {
				if(scaleX < 0) {
					scaleX *= -1;
				}
			}
		}
		
		// jump
		private function Jump() {
			if(!jumping) {
				jumping = true;
				apply_gravity = true;
				force_burst = new Vector2D(0, -1500000);
			}
		}
		
		// populate the dmgbox array with the frame's dmgboxes
		protected function Get_DamageBox(): Array {
			dmgbox_list = new Array();
			for(var i = 0; i < this.numChildren; i++) {
				if(getChildAt(i) is DamageBox) {
					dmgbox_list.push(getChildAt(i));
				}
			}
			return dmgbox_list
		}
		// same for the hitbox, or bounding box
		public function Get_HitBox(): Array {
			hitbox_list = new Array();
			for(var i = 0; i < this.numChildren; i++) {
				if(getChildAt(i) is HitBox) {
					hitbox_list.push(getChildAt(i));
				}
			}
			return hitbox_list;
		}
		
		// check collision between the hitboxes
		protected function Check_Collision(target: GameCharacter): Boolean {
			var attack_list = Get_DamageBox();
			var defender_list = target.Get_HitBox();
			var b: Boolean;
			
			for each(var dmgbox: DamageBox in attack_list) {
				for each(var hitbox: HitBox in defender_list) {
					if(dmgbox.hitTestObject(hitbox)){
						b = true;
					}
				}
			}
			attack_list = null;
			defender_list = null;
			return b;
		}
		
		// function to store the key sequence pressed for special moves
		private function Register_Keys(key: String) {
			if(Game.restrict_movement)return;
			last_key = getTimer();
			key_sequence.push(key);
			var count = key_sequence.length;
			if(count >= 3) {
				// limit the array to 3 slots
				key_sequence.splice(0, count - 3);
				// check for combo sequence
				if(String(key_sequence.toString()) == "P,P,K") {
					Special_Attack();
				}
			}
		}
		
		// attack methods
		public function Punch() {
			if(stunned)return;
			if(!attacking) {
				attacking = true;
				gotoAndPlay(punch_frame);
				return;
			// set the target player based on "this" player number
			} else {
				Register_Keys("P");
				var target: GameCharacter = Get_Target();
				if(this.Check_Collision(target)){
					target.Damage(punch_power);
					Increase_Combo();
				}
				hit_sound.play();
			}
		}
		
		public function Kick() {
			if(stunned)return;
			// if the player is not attacking, place him in the attacking animation
			if(!attacking) {
				attacking = true;
				gotoAndPlay(kick_frame);
				return;
			// set the target player based on "this" player number and check collision
			} else {
				Register_Keys("K");
				var target: GameCharacter = Get_Target();
				if(this.Check_Collision(target)){
					target.Damage(kick_power);
					Increase_Combo();
				}
				hit_sound.play();
			}
		}
		
		public function Special_Attack() {
			key_sequence = new Array();
		}
		
		public function Check_Blocking(): Boolean {
			var blocking: Boolean;
			if(player_number == 1 && Game.s_pressed) {
				blocking = true;
			} else if(player_number == 2 && Game.down_pressed) {
				blocking = true;
			}
			return blocking;
		}
		
		private function Stun(num: Number) {
			// stun for 'num' seconds
			stunned = true;
			Display_Combo(0);
			gotoAndPlay(stun_frame);
		}
		
		// function to deal damage
		public function Damage(dmg:Number) {
			if(ko) {
				return;
			}
			attacking = false;
			
			if(Check_Blocking()){
				dmg /= 3;
			} else {
				Stun(0.15);
			}
			last_action = getTimer();
			hp -= dmg;
			hit_sound.play();
			if(hp <= 0){
				Die();
			}
		}
		
		public function Increase_Combo() {
			last_hit = getTimer();
			++combo;
			if(combo > Game.best_combo){
				Game.best_combo = combo;
			}
			Display_Combo(combo);
		}
		
		private function Die() {
			ko = true;
			recovering = false;
			hp = 0;
			gotoAndPlay(ko_frame);
			Game.game_over = true;
		}
		
		// update the heads up display
		private function UpdateHUD() {
			var hp_percent: Number = Math.floor((hp / hp_max) * 100) + 1;
			if(health_bar.currentFrame > hp_percent) {
				// use this variable to give the health bar a smooth animation transition
				var frame_skip: Number = Math.floor(Math.min(health_bar.currentFrame - hp_percent, 2));
				// go towards the right frame
				health_bar.gotoAndStop(health_bar.currentFrame - frame_skip);
			} else {
				health_bar.gotoAndStop(hp_percent);
			}
		}
		
		// floor the character on the stage
		// so gravity doesn't pull him under a certain height
		public function Floor(): Boolean {
			var b: Boolean;
			// get coordinates from the "pos"ition vector
			x = pos.getX();
			y = pos.getY();
			// do the checks
			if(y + feet_box > stage.stageHeight - 50) {
				y = stage.stageHeight - feet_box - 50;
				v_i = new Vector2D(0, 0);
				jumping = false;
				attacking = false;
				apply_gravity = false;
				stunned = false;
				Reset_Animation();
				b = true;
			}
			// re-assign x and y to the position vector
			pos = new Vector2D(x, y);
			return b;
		}
		
		// go back to frame 1
		protected function Reset_Animation() {
			if(Check_Animation(false)) {
				if(currentFrame >= walk_frame) {
					gotoAndPlay(stance_frame);
				}
			}
		}
		
		// return true if you want to reset animation back to stance
		// ^if jump_check is true, return true to play the jump animation
		protected function Check_Animation(jump_check: Boolean): Boolean {
			var b: Boolean;
			if(!attacking && !ko && !recovering) {
				// allows the character to play the jumping animation
				if(jump_check && jumping) {
					b = true;
				} else if(!jump_check && !jumping) {
					b = true;
				}
			}
			return b;
		}
		
		public function Pushed(dir: Vector2D): Boolean {
			var b: Boolean;
			// predict the next step and position accordingly
			var new_x = x + dir.getX();
			if(new_x + width / 2 > stage.stageWidth) {
				new_x = stage.stageWidth - width / 2;
			} else if(new_x - width / 2 < 0) {
				new_x = width / 2;
			} else {
				b = true;
			}
			pos.setX(new_x);
			x = new_x;
			return b;
		}
		
		// display the combo streak on screen
		public function Display_Combo(streak: Number) {
			// remove any existing text
			if(Game.combo_txt[player_number - 1] is GameText) {
				Game.combo_txt[player_number - 1].Remove_Manual();
				Game.combo_txt[player_number - 1] = null;
			}
			// if streak is 0, that means we just want to remove the text
			if(streak <= 0) {
				// reset combo
				combo = 0;
				return;
			}
			// otherwise add the new text
			else {
				var _x = 150, _y = 100;
				if(player_number > 1) {
					_x = stage.stageWidth - 200;
				}
				var t_format:TextFormat = new TextFormat();
				t_format.bold = true;
				t_format.size = 40;
				t_format.color = Game.txt_color;
				t_format.font = new Font1().fontName;
				t_format.align = TextFormatAlign.CENTER;
				Game.combo_txt[player_number - 1] = new GameText(parent, "COMBO " + streak, t_format, _x, _y, 2000);
			}
		}
		
		// remove the character and all its events
		public function Remove() {
			this.removeEventListener(Event.ENTER_FRAME, Update);
			parent.removeChild(health_bar);
			health_bar = null;
			while(this.numChildren) {
				this.removeChildAt(0);
			}
			hit_sound = null;
			parent.removeChild(this);
		}
	}
}

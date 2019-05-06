package  {
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.display.*;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	
	public class Projectile extends MovieClip {

		var mass: Number = 200;
		var v_i, v_f: Vector2D;
		var pos: Vector2D;
		var damage:Number;
		var player_number:Number;
		var my_parent: Object;
		var timer: Timer;
		var apply_gravity, bouncy: Boolean;
		
		public function Projectile(my_parent: Object,  x, y, width, height: Number, vector: Vector2D, damage, player_num:Number) {
			this.my_parent = my_parent;
			pos = new Vector2D(x, y);
			this.x = x;
			this.y = y;
			if(width > 0)this.width = width;
			if(height > 0)this.height = height;
			v_i = v_f = vector;
			this.damage = damage;
			player_number = player_num;
			if(vector.getX() < 0) {
				scaleX *= -1;
			}

			my_parent.addChild(this);
			
			timer = new Timer(30);
			timer.addEventListener(TimerEvent.TIMER, Movement);
			timer.start();
		}
		
		public function Movement(e:TimerEvent){
			Apply_Gravity(0.03);
			this.x = pos.getX();
			this.y = pos.getY();
			x += v_f.getX();
			
			if(x + width < 0){
				Remove();
			} else if(x > stage.stageWidth + width){
				Remove();
				return;
			} else {
				this.pos = new Vector2D(x, y);
				var target: GameCharacter = Game.in_game[1];
				if(player_number == 2) {
					target = Game.in_game[0];
				}
				if(Check_Collision(target)) {
					target.Damage(this.damage);
					GameCharacter(Game.in_game[player_number-1]).Increase_Combo();
					Remove();
					return;
				}
			}
		}
		
		private function Get_DamageBox(): Array {
			var dmgbox_list = new Array();
			for(var i = 0; i < this.numChildren; i++) {
				if(getChildAt(i) is DamageBox) {
					dmgbox_list.push(getChildAt(i));
				}
			}
			return dmgbox_list
		}
		
		private function Check_Collision(target: GameCharacter) {
			var attack_list = Get_DamageBox();
			var defender_list = target.Get_HitBox();
			
			for each(var dmgbox: DamageBox in attack_list) {
				for each(var hitbox: HitBox in defender_list) {
					if(dmgbox.hitTestObject(hitbox)){
						return true;
					}
				}
			}
			return false;
		}
		
		private function Apply_Gravity(time_elapsed: Number) {
			if(!apply_gravity)return;
			var dt = time_elapsed;
			// calculate the forces and acceleration of the object
			var force_net: Vector2D = Game.force_gravity;
			var accel: Vector2D = force_net.scalarDivision(mass);
			// calculate the velocity and position
			v_f = v_i.addVector(accel.scalarMultiplication(dt));
			pos = pos.addVector(v_i.scalarMultiplication(dt).addVector(accel.scalarMultiplication(0.5).scalarMultiplication(dt).scalarMultiplication(dt)));
			v_i = v_f;
			// check if the character is on the floor
			if(pos.getY() + this.height > stage.stageHeight - 50) {
				pos.setY(stage.stageHeight - this.height - 50);
				if(bouncy) {
					v_i.setY(v_i.getY() * -0.8);
				}
			}
			
		}
		
		public function Remove(){
			timer.stop();
			timer.removeEventListener(TimerEvent.TIMER, Movement);
			timer = null;
			if(parent.contains(this)) {
				parent.removeChild(this);
			}
		}
	}
	
}

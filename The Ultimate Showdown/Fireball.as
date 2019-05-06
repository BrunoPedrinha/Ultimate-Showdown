package  {
	
	public class Fireball extends Projectile {

		public function Fireball(my_parent: Object,  x, y, width, height: Number, vector: Vector2D, damage, player_num:Number) {
			super(my_parent, x, y, width, height, vector, damage, player_num);
			this.scaleX = 5;
			this.scaleY = 5;
			apply_gravity = bouncy = true;
		}
	}
}
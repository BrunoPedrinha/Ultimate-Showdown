package  {
// this class was done last semester.
// similar to Point(), with a few extra features for addition, etc.

	public class Vector2D {
	
		private var _x: Number;
		private var _y: Number;
		
		function Vector2D(xValue: Number, yValue: Number) {
			_x = xValue;
			_y = yValue;
		}
	
		function getX(): Number {
			return _x;
		}
	
		function getY(): Number {
			return _y;
		}
		
		function addX(xx: Number) {
			_x += xx;
		}
		
		function addY(yy: Number) {
			_x += yy;
		}
	
		function setX(xValue: Number) {
			_x = xValue;
		}
	
		function setY(yValue: Number) {
			_y = yValue;
		}
	
		function setXY(xValue: Number, yValue: Number) {
			_x = xValue;
			_y = yValue;
		}
		
		function addVector(vec: Vector2D): Vector2D {
			return new Vector2D(_x + vec._x, _y + vec._y);
		}
	
		function subtractVector(vec: Vector2D): Vector2D {
			return new Vector2D(_x - vec._x, _y - vec._y);
		}
	
		function scalarMultiplication(scalar: Number): Vector2D {
			return new Vector2D(_x * scalar, _y * scalar);
		}
		
		function scalarDivision(scalar: Number): Vector2D {
			return new Vector2D(_x / scalar, _y / scalar);
		}
	
		function getMagnitude(): Number {
			return Math.sqrt((_x * _x) + (_y * _y));
		}
		
		function toString() {
			return "x: " + _x + "\ny: " + _y;
		}
	}
}

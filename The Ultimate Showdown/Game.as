package  {
	import flash.display.MovieClip;
	import flash.events.*;
	import flash.utils.*;
	import flash.text.*;
	import flash.net.SharedObject;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	
	public class Game extends MovieClip {
		
		// game vars
		// type of characters selected
		var player_1, player_2;
		// set to false once the game starts
		static var restrict_movement: Boolean = true;
		// fighting characters go in here
		static var in_game: Array;
		// character than can be selected in the title screen
		var character_list: Array;
		var player_1_index, player_2_index: Number;
		var p1_select, p2_select;
		var p1_wins, p2_wins: Number;
		static var best_combo, rounds_played: Number = 0;
		static var game_over: Boolean;
		// type of class the game stage is
		var game_stage;
		static var txt_color = 0x000000;
		// best out of 3
		const MAX_WINS: Number = 3;
		const PRE_ROUND_DELAY: Number = 4;
		
		static var force_gravity: Vector2D = new Vector2D(0, 90000);
		var last_timer: Number = getTimer();
		// timers to control the gravity, "3, 2, 1, Fight!", and time left
		var update_timer, pre_round_timer, post_round_timer, countdown_timer: Timer;
		
		// character control: player 1
		static var w_pressed, a_pressed, s_pressed, d_pressed, p1_attack_sticky: Boolean;
		// attack_sticky makes sure the player releases the attack button before attacking again
		// character control: player 2
		static var up_pressed, left_pressed, right_pressed, down_pressed, p2_attack_sticky: Boolean;
		
		// other vars
		var records_txt: TextField;
		static var combo_txt: Array;
		var theme: Sound;
		var channel: SoundChannel;

		public function Game(parent: Object) {
			parent.addChild(this);
			p1_wins = p2_wins = 0;
			in_game = new Array();
			combo_txt = new Array();
			combo_txt.push(null);
			combo_txt.push(null);
			Character_Select();
			Load_Local_Data();
			if(Math.floor(Math.random() * 2) > 0) {
				game_stage = City;
				txt_color = 0xFFFF00;
			} else {
				game_stage = Waterfall;
			}
			theme = new kentheme();
		}
		
		// save the data locally
		public function Save_Local_Data(){
			var local_savefile:SharedObject = SharedObject.getLocal("project");
			local_savefile.data.best_combo = best_combo;
			local_savefile.data.rounds_played = rounds_played;
		}
		
		// load the stored data
		function Load_Local_Data() {
			var local_savefile:SharedObject = SharedObject.getLocal("project");
			//trace("Best Combo: " + local_savefile.data.best_combo);
			//trace("Rounds Played: " + local_savefile.data.rounds_played);
			best_combo = local_savefile.data.best_combo;
			rounds_played = local_savefile.data.rounds_played;
			// make sure the variables aren't undefined
			if(!(best_combo >= 0)) {
				best_combo = 0;
			}
			if(!(rounds_played >= 0)) {
				rounds_played = 0;
			}
			//trace(best_combo);
			//trace(rounds_played);
			// display the scores on screen
			var txt_format:TextFormat = new TextFormat();
			txt_format.bold = true;
			txt_format.font = new Font2().fontName;
			txt_format.size = 22;
			txt_format.color = 0xFFFFFF;
			records_txt = new TextField();
			records_txt.x = 75;
			records_txt.y = stage.stageHeight - 100;
			records_txt.appendText("Rounds Played:\t\t" + rounds_played);
			records_txt.appendText("\nBest Combo:\t\t\t" + best_combo);
			records_txt.setTextFormat(txt_format);
			records_txt.autoSize = TextFieldAutoSize.LEFT;
			records_txt.selectable = false;
			this.addChild(records_txt);
		}
		
		// function to select the characters.
		// display the char selection boxes on screen
		function Character_Select(){
			character_list = new Array();
			var x_facepos = 50, y_facepos = 75;
			for(var i:uint = 1; i<9; i++){
				var facebox:FaceBox = new FaceBox();
				facebox.gotoAndStop(i);
				facebox.x = x_facepos;
				facebox.y = y_facepos;
				this.addChild(facebox);
				character_list.push(facebox);
				x_facepos += 100;
				if(i != 0 &&(i % 4) == 0){
					x_facepos = 75;
					y_facepos += 100;
				}
			}
			player_1_index = player_2_index = 0;
			p1_select = new p1_selector();
			p1_select.x = character_list[0].x;
			p1_select.y = character_list[0].y;
			p2_select = new p2_selector();
			p2_select.x = p1_select.x;
			p2_select.y = p1_select.y;
			this.addChild(p1_select);
			this.addChild(p2_select);
			var ctrl: Controls =  new Controls();
			ctrl.x = stage.stageWidth - ctrl.width;
			this.addChild(ctrl);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, Toggle_Character);
		}
		
		// moves the character selector from "facebox" to "facebox"
		function Toggle_Character(e: KeyboardEvent) {
			if(p1_select == null || p2_select == null)return;
			switch(e.keyCode) {
				// player 1 keys
				case 65:
					if(player_1 != null)return;
					player_1_index = Math.max(0, player_1_index - 1);
					break;
				case 87:
					if(player_1 != null)return;
					player_1_index = Math.max(0, player_1_index - 4);
					break;
				case 68:
					if(player_1 != null)return;
					player_1_index = Math.min(character_list.length - 1, player_1_index + 1);
					break;
				case 83:
					if(player_1 != null)return;
					player_1_index = Math.min(character_list.length - 1, player_1_index + 4);
					break;
				case 70:
					if(player_1 != null)return;
					p1_select.gotoAndStop(13);
					player_1 = character_list[player_1_index].char_name;
					Check_Character_Select();
					break;
				case 71:
					player_1 = null;
					p1_select.gotoAndPlay(1);
					break;
				
				// player 2 keys
				case 37:
					if(player_2 != null)return;
					player_2_index = Math.max(0, player_2_index - 1);
					break;
				case 38:
					if(player_2 != null)return;
					player_2_index = Math.max(0, player_2_index - 4);
					break;
				case 39:
					if(player_2 != null)return;
					player_2_index = Math.min(character_list.length - 1, player_2_index + 1);
					break;
				case 40:
					if(player_2 != null)return;
					player_2_index = Math.min(character_list.length - 1, player_2_index + 4);
					break;
				case 75:
					if(player_2 != null)return;
					p2_select.gotoAndStop(13);
					player_2 = character_list[player_2_index].char_name;
					Check_Character_Select();
					break;
				case 76:
					player_2 = null;
					p2_select.gotoAndPlay(1);
					break;
			}
			// if they are not null, place them in the right position
			if(p1_select != null && p2_select != null) {
				p1_select.x = character_list[player_1_index].x;
				p1_select.y = character_list[player_1_index].y;
				p2_select.x = character_list[player_2_index].x;
				p2_select.y = character_list[player_2_index].y;
			}
		}
		
		function Check_Character_Select(){
			// check if both players have selected a character
			if(player_1 != null && player_2 != null) {
				stage.removeEventListener(KeyboardEvent.KEY_DOWN, Toggle_Character);
				p1_select = p2_select = null;
				character_list = null;
				Setup_Round();
			}
		}
		
		// get a fight round ready to start
		function Setup_Round() {
			Clear_Stage();
			Spawn_Characters();
			// pre round timer counts down to the start of the match
			pre_round_timer = new Timer(1000, PRE_ROUND_DELAY);
			pre_round_timer.addEventListener(TimerEvent.TIMER, Pre_Round);
			pre_round_timer.addEventListener(TimerEvent.TIMER_COMPLETE, Start_Round);
			pre_round_timer.start();
		}
		
		function Pre_Round(e: TimerEvent) {
			var num: Number = PRE_ROUND_DELAY - pre_round_timer.currentCount;
			var display_txt: String = String(num);
			if(num <= 0) {
				display_txt = "FIGHT!";
			}
			var t_format:TextFormat = new TextFormat();
			t_format.bold = true;
			t_format.size = 120;
			t_format.color = Game.txt_color;
			t_format.font = new Font1().fontName;
			t_format.align = TextFormatAlign.CENTER;
			var g:GameText = new GameText(this, display_txt, t_format, stage.stageWidth / 2, stage.stageHeight / 2, 999); 
		}
		
		function Start_Round(e: TimerEvent) {
			pre_round_timer.removeEventListener(TimerEvent.TIMER, Pre_Round);
			pre_round_timer.removeEventListener(TimerEvent.TIMER_COMPLETE, Start_Round);
			pre_round_timer = null;
			restrict_movement = false;
		}
		
		function Spawn_Characters() {
			// place the characters in the game by adding them to the array
			in_game = new Array();
			// error found
			if(player_1 == null || player_2 == null) {
				Remove();
			} else {
				channel = theme.play(0, 999);
				new game_stage(this, stage.stageWidth, stage.stageHeight);
				in_game.push(new player_1(this, 1));
				in_game.push(new player_2(this, 2));
				in_game[0].gotoAndStop(in_game[0].drop_frame);
				in_game[1].gotoAndStop(in_game[1].drop_frame);
				// getTimer() was giving us some accuracy issues. However small, they were very noticeable.
				// opt for a Timer function instead and hardcode the time elapsed for smoother jumps.
				if(update_timer == null) {
					update_timer = new Timer(30);
					update_timer.addEventListener(TimerEvent.TIMER, Update);
				}
				update_timer.start();
			}
			stage.addEventListener(KeyboardEvent.KEY_DOWN, Key_Down);
			stage.addEventListener(KeyboardEvent.KEY_UP, Key_Up);
		}
		
		public function End_Round() {
			// determine winner
			channel.stop();
			var p1 = in_game[0] as GameCharacter;
			var p2 = in_game[1] as GameCharacter;
			if(p1 == null || p2 == null) {
				Remove();
			} else {
				// player 2 wins
				if(p1.hp <= 0 && p2.hp > 0) {
					++p2_wins;
				// player 1 wins
				} else if(p2.hp <= 0 && p1.hp > 0) {
					++p1_wins;
				// draw
				} else {
					++p1_wins;
					++p2_wins;
				}
			//	trace(p1_wins);
			//	trace(p2_wins);
			}
			// increment rounds played
			++rounds_played;
			// win text
			var t_format:TextFormat = new TextFormat();
			t_format.bold = true;
			t_format.size = 110;
			t_format.color = Game.txt_color;
			t_format.font = new Font1().fontName;
			t_format.align = TextFormatAlign.CENTER;
			var g:GameText = new GameText(this, "KO!", t_format, stage.stageWidth / 2, (stage.stageHeight / 2) - 20, 2500);
			t_format.size = 30;
			var g2:GameText = new GameText(this, p1_wins + " - " + p2_wins, t_format, stage.stageWidth / 2, (stage.stageHeight / 2) + 50, 2500); 
			restrict_movement = true;
			if(post_round_timer == null) {
				post_round_timer = new Timer(5000, 1);
				post_round_timer.addEventListener(TimerEvent.TIMER_COMPLETE, Game_Over);
				post_round_timer.start();
			}
			// save data
			Save_Local_Data();
		}
		
		function Game_Over(e: TimerEvent) {
			post_round_timer.removeEventListener(TimerEvent.TIMER_COMPLETE, Game_Over);
			post_round_timer = null;
			// check for a winner of the series
			if((p1_wins + p2_wins) > MAX_WINS) {
				if(p1_wins > p2_wins) {
					// player 1 wins
				} else if(p2_wins > p1_wins) {
					// player 2 wins
				} else {
					// tie breaker
					Setup_Round();
				}
			// check for best of X winner
			} else if(p1_wins > MAX_WINS / 2) {
				// player 1 wins
				Remove();
			} else if(p2_wins > MAX_WINS / 2) {
				// player 2 wins
				Remove();
			} else {
				// start next round
				Setup_Round();
			}
		}
		
		// apply gravity on the players' characters
		function Update(e: TimerEvent) {
			if(game_over) {
				game_over = false;
				End_Round();
			}
			// apply gravity for each character in the game
			for each(var char: GameCharacter in in_game) {
				if(char != null && char.apply_gravity) {
					char.Apply_Gravity(0.030);
				}
			}
		}
		
		// key down events
		function Key_Down(e: KeyboardEvent) {
		//	trace (e.keyCode);
			switch(e.keyCode) {
				case 65:
					a_pressed = true;
					break;
				case 87:
					w_pressed = true;
					break;
				case 68:
					d_pressed = true;
					break;
				case 83:
					s_pressed = true;
					break;
				case 70:
					if(p1_attack_sticky)break;
					p1_attack_sticky = true;
					in_game[0].Punch();
					break;
				case 71:
					if(p1_attack_sticky)break;
					p1_attack_sticky = true;
					in_game[0].Kick();
					break;
				
				// player 2
				case 37:
					left_pressed = true;
					break;
				case 38:
					up_pressed = true;
					break;
				case 39:
					right_pressed = true;
					break;
				case 40:
					down_pressed = true;
					break;
				case 75:
					if(p2_attack_sticky)break;
					p2_attack_sticky = true;
					in_game[1].Punch();
					break;
				case 76:
					if(p2_attack_sticky)break;
					p2_attack_sticky = true;
					in_game[1].Kick();
					break;
			}
		}
		
		// key release events
		function Key_Up(e: KeyboardEvent) {
			switch(e.keyCode) {
				// PLAYER 1 controls
				case 65:
					a_pressed = false;
					break;
				case 87:
					w_pressed = false;
					break;
				case 68:
					d_pressed = false;
					break;
				case 83:
					s_pressed = false;
					break;
				case 70:
					p1_attack_sticky = false;
					break;
				case 71:
					p1_attack_sticky = false;
					break;
				// PLAYER 2 controls
				case 37:
					left_pressed = false;
					break;
				case 38:
					up_pressed = false;
					break;
				case 39:
					right_pressed = false;
					break;
				case 40:
					down_pressed = false;
					break;
				case 75:
					p2_attack_sticky = false;
					break;
				case 76:
					p2_attack_sticky = false;
					break;
			}
		}
		
		// removes all the children
		function Clear_Stage() {
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, Key_Down);
			stage.removeEventListener(KeyboardEvent.KEY_UP, Key_Up);
			while(in_game.length) {
				in_game[0].Remove();
				in_game.shift();
			}
			while(this.numChildren){
				this.removeChildAt(0);
			}
		}
		// disposes of the game
		public function Remove() {
			Clear_Stage();
			in_game = null;
			player_1 = null;
			player_2 = null;
			if(update_timer != null) {
				update_timer.removeEventListener(TimerEvent.TIMER, Update);
				update_timer = null;
			}
			MovieClip(root).gotoAndStop(1);
		}
	}
}

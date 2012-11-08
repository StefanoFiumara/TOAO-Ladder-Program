package {
	import flash.display.*;
	public class Player {
		public var username:String; //name of the player
		public var rank:String; //Player's rank
		public var score:int; //Player's score
		public var streak:int; //Player's win/lose streak
		public var numLosses:uint; //Number of games lost
		public var numWins:uint; //Number of games won
		public var numGames:uint; //Number of games played
		public var flag:String; //String containing the url for the flag image used for TOAO export
		private var TierNames:Array; //Array with Tier names used for internal getRank function
		
		public function Player($name:String, $TierList:Array, $score:int = 75, $numWins:uint = 0, $numLosses:uint = 0, $streak = 0, $flag:String = "") {
			
			TierNames = $TierList.concat();
			username = $name;
			score = $score;
			rank = getRank();
			streak = $streak;
			numLosses = $numLosses;
			numWins = $numWins;
			numGames = numWins + numLosses;
			flag = $flag;
		}
		//gets the player's rank based on score
		public function getRank():String {
			if(score >= 20 && score <= 40) {
				return TierNames[5];
			}
			else if(score >= 41 && score <= 60) {
				return TierNames[4];
			}
			else if(score >= 61 && score <= 80) {
				return TierNames[3];
			}
			else if(score >= 81 && score <= 105) {
				return TierNames[2];
			}
			else if(score >= 106 && score <= 154) {
				return TierNames[1];
			}
			else if(score >= 155) {
				return TierNames[0];
			}
			return "";
		}
		
		//Calculates win %
		public function getWinPercent():Number {
			var Percent:Number = 0;
			
			if(numGames == 0) {
				return Percent;
			} else {
				Percent = (numWins/numGames) * 100;
				Percent = Math.round(Percent * 100) / 100;
			}
			 
			return Percent;
		}
		
		//adds wins and losses to get number of games played
		public function getNumGames():uint {
			return numWins + numLosses;
		}
		//exports default text
		public function exportFunction($style:String):String {
			var export:String;
			trace("Exporting player "+username+" with style: "+$style);
			switch($style) {
				case "Default":
					export = "("+score+") "+username+" ("+numWins+"-"+numLosses+") "+streak;
					break;
				case "TOAO":
					export = TOAOExport();
					break;
				case "AoKH":
					export = AoKHExport();
					break;
				case "RoR":
					export = RoRExport();
					break;
				default:
					export = "This Export Mode is not yet implemented.";
					break;
			}
			
			return export;
		}
		
		private function TOAOExport():String {
			var txt:String = new String();			
			numGames = getNumGames();
			
			var numGamesSymbols:String = new String();
			if(numGames >= 100 && numGames < 150) {
				numGamesSymbols = "[color=#FFFF00]♦[/color]";
			}
			else if(numGames >= 150 && numGames < 200) {
				numGamesSymbols = "[color=#FFFF00]♦♦[/color]";
			}
			else if(numGames >= 200 && numGames < 250) {
				numGamesSymbols = "[color=#FFFF00]♦♦♦[/color]";
			}
			else if(numGames >= 250 && numGames < 350) {
				numGamesSymbols = "[color=#FFFF00]♦♦♦♦[/color]";
			}
			else if(numGames >= 350 && numGames < 500) {
				numGamesSymbols = "[color=#FFFF00]♦♦♦♦♦[/color]";
			}
			else if(numGames >= 500) {
				numGamesSymbols = "[color=#40FFFF]♦♦♦♦♦[/color]";
			}
			
			txt = "[img]"+flag+"[/img] ("+score+") "+username+" ("+numWins+"-"+numLosses+") "+streak +" "+ numGamesSymbols;
			
			return txt;
		}
		
		private function AoKHExport():String {
			var txt:String = new String();
			var colorTag:String = new String();
			var stringStreak:String = new String();
			numGames = getNumGames();
			if(streak > 0) {
				colorTag = "[color=green]";
				stringStreak = "+"+streak.toString();
			} else if(streak < 0) {
				colorTag = "[color=red]";
				stringStreak = streak.toString();
			}
			
			txt = "[img]"+flag+"[/img] "+colorTag+""+score+":[/c] "+username+" [i][color=purple]([b]"+numGames+"[/b] [whisper]"+getWinPercent()+"%[/whisper])[/c] "+colorTag+"("+stringStreak+")[/c][/i]";
			return txt;
		}
		private function RoRExport():String {
			var txt:String = new String();			
			numGames = getNumGames();
			
			var numGamesSymbols:String = new String();
			if(numGames >= 50 && numGames < 100) {
				numGamesSymbols = "[color=#FFFF00]♦[/color]";
			}
			else if(numGames >= 100 && numGames < 200) {
				numGamesSymbols = "[color=#FFFF00]♦♦[/color]";
			}
			else if(numGames >= 200 && numGames < 300) {
				numGamesSymbols = "[color=#FFFF00]♦♦♦[/color]";
			}
			else if(numGames >= 300 && numGames < 500) {
				numGamesSymbols = "[color=#FFFF00]♦♦♦♦[/color]";
			}
			else if(numGames >= 500 && numGames < 500) {
				numGamesSymbols = "[color=#FFFF00]♦♦♦♦♦[/color]";
			}
			
			txt = "[img]"+flag+"[/img] ("+score+") "+username+" ("+numWins+"-"+numLosses+") "+streak +" "+ numGamesSymbols;
			
			return txt;
		}
		
		//current plan is to write 3 separate export styles which will be selected by the operator through a radio button when exporting the list
		//Default, TOAO, and AoKH styles are planned, the above is the default, the others will come in future releases.
	}
}
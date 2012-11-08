package {
	import Player;
	//Holds an Array of Players
	public class PlayerLibrary {
		//List of player Objects
		public var list:Array;
		//number of players in the ladder
		public var numPlayers:uint;
		
		public function PlayerLibrary() {
			list = new Array();
			numPlayers = 0;
		}
		
		//Adds a player to the ladder, returns true if sucessful
		public function addPlayer(playerObj:Player):Boolean {
			//check if name is already in use
			for(var i in list) {
				if(list[i].username == playerObj.username) {
					//name already in use, exit the function
					//Throw Error Here
					return false;
				}
			}
			//add the player if the function hasn't already exited.
			list.push(playerObj);
			numPlayers++;
			return true;
		}
		
		//Removes player from the ladder, returns true if sucessful
		public function removePlayer(playerName:String):Boolean {
			for(var i in list) {
				//find the player username
				if(list[i].username == playerName) {
					list.splice(i, 1);
					numPlayers--;
					return true; //exit the function once it's found.
				}
			}
			//Throw Error Here
			return false;
		}
		
		public function updateNumGames(updateArray:Array = null) {
			if(updateArray == null) {
				for(var i in list) {
					list[i].numGames = list[i].getNumGames();
					return;
				}
			}
			else {
				for (var e in updateArray) {
					updateArray[e].numGames = updateArray[e].getNumGames();
				}
			}
		}
		
		//Updates every player's rank
		public function updateRanks(updateArray:Array = null) {
			//if no paramenter
			if(updateArray == null) {
				//update all ranks
				for(var i in list) {
					list[i].rank = list[i].getRank();
				}
				return;
			}
			else {
				//update only the players passed in the parameter
				for (var e in updateArray) {
					updateArray[e].rank = updateArray[e].getRank();
				}
			}
		}
	}
}
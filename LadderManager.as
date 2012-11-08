package {
	
	import flash.display.*;
	import flash.events.*;
	import flash.text.*;
	import fl.controls.dataGridClasses.DataGridColumn;
	import fl.controls.RadioButtonGroup;
	//import fl.controls.RadioButton;
	import PlayerLibrary;
	import Player;
	import WindowDialog;
	
	public class LadderManager extends Sprite {
		//Combo boxes will go in the LadderManager MovieClip
		//Create Arrays for those here to reference
		private var buttonArray:Array;
		private var comboBoxArray:Array;
		
		private var players:PlayerLibrary;
		
		private var FFAMatch:Boolean = false;
		
		private var ladderName:String;
		private var ladderData:XML;
		
		public var TierList:Array;
		public var Tier1:String;
		public var Tier2:String;
		public var Tier3:String;
		public var Tier4:String;
		public var Tier5:String;
		public var Tier6:String;
		
		private var radioGroup:RadioButtonGroup = new RadioButtonGroup("Styles");
		private var radioButtons:Array;
		
		public function LadderManager($ladder:XML = null, $ladderName:String = null) {
			//put all buttons and combo boxes in arrays
			buttonArray = new Array(addPlayerBtn, OneVsOneBtn, saveChangesBtn, exportTxtBtn, teamGameBtn, removePlayerBtn, FFABtn, clearBtn);
			comboBoxArray = new Array(comboBoxRemove, comboBoxWinner, comboBoxLoser,teamOne1,teamOne2,teamOne3,teamOne4,teamTwo1,teamTwo2,teamTwo3,teamTwo4);
			radioButtons = new Array(radioDefault, radioTOAO, radioAoKH, radioRoR);
			
			//hide the ffa winner box
			ffaWinner.visible = false;
			
			//create the grid and assign the button names and event listeners
			createGrid();
			setButtonLabels();
			
			//new player library
			players = new PlayerLibrary();
			
			ladderName = $ladderName;
			ladderData = $ladder;
			
			//test code for customizing tiers
			Tier1 = ladderData.TierList.Tier1; //Expert
			Tier2 = ladderData.TierList.Tier2; //Upper Inter
			Tier3 = ladderData.TierList.Tier3; //Inter
			Tier4 = ladderData.TierList.Tier4; //Grook
			Tier5 = ladderData.TierList.Tier5; //Rook
			Tier6 = ladderData.TierList.Tier6; //Newb
			TierList = new Array(Tier1, Tier2, Tier3, Tier4, Tier5, Tier6);
			
			//Parse the XML data into the player library, datagrid, and combo boxes
			var oldPlayers:XMLList = ladderData.PlayerList.Player;
			for each(var nextPlayer:XML in oldPlayers) {
				var thisPlayer:Player = new Player(String(nextPlayer.name), TierList, int(nextPlayer.score), uint(nextPlayer.wins), uint(nextPlayer.losses), int(nextPlayer.streak), String(nextPlayer.flag));
				players.addPlayer(thisPlayer);
				addToDataGrid(thisPlayer);
				addToComboBox(thisPlayer.username);
				players.numPlayers++;
			}
		}
		
		
		//Adds button listener and etc
		private function setButtonLabels() {
			//Use hand cursor, add event listener
			for(var i in buttonArray) {
				buttonArray[i].useHandCursor = true;
				buttonArray[i].addEventListener(MouseEvent.CLICK, clickBtn);
			}
			
			//Combo box prompts
			for (var j in comboBoxArray) {
				comboBoxArray[j].useHandCursor = true;
				comboBoxArray[j].prompt = "Select a Player...";
				comboBoxArray[j].addItem({label:"Select a Player..."});
			}
			
			for(var k in radioButtons) {
				radioButtons[k].useHandCursor = true;
				radioGroup.addRadioButton(radioButtons[k]);
				radioButtons[k].addEventListener(MouseEvent.CLICK, clickBtn);
			}
			
			//radioGroup.selection = radioTOAO;
			//trace(radioGroup.selection);
			
			//labels for each button
			var txtformat:TextFormat = new TextFormat("Eras Demi ITC",null,0x000000);
			FFABtn.setStyle("textFormat", txtformat);
		}
		
		//handles click events for all buttons
		private function clickBtn(e:MouseEvent) {
			//call different functions based on which button was clicked.
			switch(e.target) {
				case addPlayerBtn:
					addPlayer();
					break;
				case removePlayerBtn:
					removePlayer();
					break;
				case exportTxtBtn:
					exportStandings();
					break;
				case OneVsOneBtn:
					OneVsOne();
					break;
				case saveChangesBtn:
					saveLadder();
					break;
				case teamGameBtn:
					if(FFAMatch) {
						FFAGame();
					} else {
						TeamGame();
					}
					break;
				case FFABtn:
					FFAMatch = !FFAMatch;
					ffaWinner.visible = FFAMatch;
					break;
				case clearBtn:
					clearSelection();
					break;
				case radioDefault:
					exportStyleTxt.text = "(score) username (wins-losses) streak";
					break;
				case radioTOAO:
					exportStyleTxt.text = "[Flag Image](score) username (wins-losses) streak [numGames]";
					break;
				case radioAoKH:
					exportStyleTxt.text = "score:  username (numGames  win%) (streak)";
					break;
				case radioRoR:
					exportStyleTxt.text = "[Flag Image](score) username (wins-losses) streak [numGames]";
			}
		}
		////////////////////////////////////////////////////////////
		//The following functions are called in the click event handler to make it look a bit cleaner
		private function addPlayer() {
			if(newPlayerInput.text == "") {
				var confirmMsg:WindowDialog = new WindowDialog(this, "Unable To Add Player", "The player cannot have a blank name.");
				return;
			}
			var newPlayer:Player = new Player(newPlayerInput.text, TierList,75,0,0,0,flagInput.text);
			
			if(players.addPlayer(newPlayer)) {
				addToDataGrid(newPlayer);
				addToComboBox(newPlayer.username);
				var confirmMsg2:WindowDialog = new WindowDialog(this, "Player Sucessfully Added", "The player "+newPlayer.username+" was sucessfully added to the ladder.");
			} else {
				var confirmMsg3:WindowDialog = new WindowDialog(this, "Unable To Add Player", "The username "+newPlayer.username+" is already in use.");
			}
		}
		
		private function removePlayer() {
			var playerToRemove:String;
			for (var i in players.list) {
				if(players.list[i].username == comboBoxRemove.selectedItem.label) {
					playerToRemove = players.list[i].username;
					break;
				}
			}
			if(players.removePlayer(playerToRemove)) {
				remakeGrid();
				removeFromComboBox();
				var confirmMsg:WindowDialog = new WindowDialog(this, "Player Sucessfully Removed", "The player "+playerToRemove+" was sucessfully removed from the ladder.");
			} 
		}
		
		private function OneVsOne() {
			//Get player variables from combo boxes
			var Player1:Player = getPlayerInstance(comboBoxWinner.selectedLabel);
			
			var Player2:Player = getPlayerInstance(comboBoxLoser.selectedLabel);
			
			//Error checking
			if(Player1 == null || Player2 == null) {
				var errorMsg2:WindowDialog = new WindowDialog(this,"No player selected", "No player is selected in one of the drop down boxes.");
				return;
			}
			
			if(Player1.username == Player2.username) {
				var errorMsg:WindowDialog = new WindowDialog(this,"Same Player Selected Twice", "Please select two different players. Players can't play against themselves.");
				return;
			}
			
			//Calculates the point difference between the two ranks (ie the points gained or lost by the players)
			var points:int = calculatePoints(Player1.rank,Player2.rank);
			
			//Adds and substracts points to players
			Player1.score += points;
			Player2.score -= points;
			//if double ladder points is checked, add points again, but do not substract
			if(doubleLadderPointsBtn.selected) {
				Player1.score += points;
			}
			
			//Player can't go below 20 points.
			if(Player2.score < 20) {
				Player2.score = 20;
			}
			
			//Streak
			if(Player1.streak >= 0) {
				Player1.streak++;
			} else {
				Player1.streak = 1;
			}
			
			if(Player2.streak <= 0) {
				Player2.streak--;
			} else {
				Player2.streak = -1;
			}
			
			//Wins/losses
			Player1.numWins++;
			Player2.numLosses++;
			
			//Number of games and ranks
			players.updateNumGames([Player1, Player2]);
			players.updateRanks([Player1, Player2]);
			
			updateGrid();
			//WindowDialog confirms the match was processed successfully
			
			//check for double ladder points, if true, double the value to be shown in the confirmTxt
			var confirmTxt:String = Player1.username +" defeats "+Player2.username+"\n\n"+Player1.username+" takes "+points+" points from "+Player2.username+".";
			if(doubleLadderPointsBtn.selected) {
				confirmTxt += "\nIn addition, double ladder points are awarded.";
			}
			var confirmMsg:WindowDialog = new WindowDialog(this, "Match Successfully Added", confirmTxt);
		}
		
		private function TeamGame() {
			//team one and team two player references in array
			var teamOne:Array = [getPlayerInstance(teamOne1.selectedLabel),getPlayerInstance(teamOne2.selectedLabel),getPlayerInstance(teamOne3.selectedLabel),getPlayerInstance(teamOne4.selectedLabel)];
			
			var teamTwo:Array = [getPlayerInstance(teamTwo1.selectedLabel),getPlayerInstance(teamTwo2.selectedLabel),getPlayerInstance(teamTwo3.selectedLabel),getPlayerInstance(teamTwo4.selectedLabel)];
			
			//splice undefined values by looping through the arrays backwards
			for(var i:int = teamOne.length-1; i >=0; i--) {
				if(teamOne[i] == null) {
					teamOne.splice(i,1);
				}
			}
			
			for(var e:int = teamTwo.length-1; e >=0; e--) {
				if(teamTwo[e] == null) {
					teamTwo.splice(e,1);
				}
			}
			
			//////////////////
			//Error Checking
			
			//team size
			if(teamOne.length != teamTwo.length) {
				var errorMsg:WindowDialog = new WindowDialog(this, "Uneven Teams", "The teams are uneven, this cannot count as a ladder game.");
				return;
			}
			if(teamOne.length == 1) {
				var errorMsg2:WindowDialog = new WindowDialog(this, "1v1 Game?", "1v1 games should be added through the 1v1 game section.");
				return;
			}
			if(teamOne.length <=0) {
				var errorMsg3:WindowDialog = new WindowDialog(this, "No Players Selected", "No players are selected.");
				return;
			}
			
			//check if any names are repeated
			var allPlayers:Array = teamOne.concat(teamTwo);
			for (var j in allPlayers) {
				for (var k in allPlayers) {
					if (j!=k) {
						if (allPlayers[j].username==allPlayers[k].username) {
							var errorMsg4:WindowDialog = new WindowDialog(this, "Player Repeated", "One or more players are repeated, this cannot count as a ladder game.");
							return;
						}
					}
				}
			}
			
			/////////////////
			//All's good, math goes here
			
			//Team averages
			var teamOnePts:Number = 0;
			for(var p in teamOne) {
				teamOnePts += teamOne[p].score;
			}
			teamOnePts /= teamOne.length;
			
			var teamTwoPts:Number = 0;
			for(var q in teamTwo) {
				teamTwoPts += teamTwo[q].score;
			}
			teamTwoPts /= teamTwo.length;
			
			//Ranks
			var teamOneRank:String = getRank(teamOnePts);
			var teamTwoRank:String = getRank(teamTwoPts);
			
			var totalNumPlayers:uint = teamOne.length + teamTwo.length;
			
			var OneVsOnePoints:int = calculatePoints(teamOneRank, teamTwoRank);
			var points:Number = Math.floor(OneVsOnePoints * (1 - (0.05 * totalNumPlayers)));
			
			if(points < 1) {
				points = 1;
			}

			//Add points to players
			for(var s in teamOne) {
				teamOne[s].score += points;
				//check for double ladder points
				if(doubleLadderPointsBtn.selected) {
					teamOne[s].score += points;
				}
				
				teamTwo[s].score -= points;

				if(teamTwo[s].score < 20) {
					teamTwo[s].score = 20;
				}
				//////////////////////////
				teamOne[s].numWins++;
				teamTwo[s].numLosses++;
				//////////////////////////
				if(teamOne[s].streak >= 0) {
					teamOne[s].streak++;
				} else {
					teamOne[s].streak = 1;
				}
				//////////////////////////
				if(teamTwo[s].streak <= 0) {
					teamTwo[s].streak--;
				} else {
					teamTwo[s].streak = -1;
				}
				//////////////////////////
			}
			//for the update ranks we pass the array we created in earlier
			players.updateRanks(allPlayers);
			updateGrid();
			
			//send confirmation
			//for confirm text, double the ladder points shown if the double ladder points box is checked
			
			var confirmTxt:String = "";
			for(var c in teamOne) {
				confirmTxt += teamOne[c].username+", ";
			}
			confirmTxt = confirmTxt.substr(0,confirmTxt.length-2);
			confirmTxt+= "\n\nDefeat\n\n";
			for(var m in teamTwo) {
				confirmTxt += teamTwo[m].username+", ";
			}
			confirmTxt = confirmTxt.substr(0,confirmTxt.length-2);
			confirmTxt += "\n\nThe winning team receives "+points+" points from the losing team.";
			if(doubleLadderPointsBtn.selected) {
				confirmTxt += "\nIn addition, double ladder points are awarded.";
			}
			
			var confirmMsg:WindowDialog = new WindowDialog(this, "Match Successfully Added", confirmTxt);
		}
		
		private function FFAGame() {
			var winner:Player = getPlayerInstance(teamOne1.selectedLabel);
			
			var FFALoserComboBoxes:Array = [teamOne2,teamOne3,teamOne4,teamTwo1,teamTwo2,teamTwo3,teamTwo4];
			var losers:Array = new Array();
			
			//create losers array
			for(var i in FFALoserComboBoxes) {
				if(getPlayerInstance(FFALoserComboBoxes[i].selectedLabel) != null) {
					var nextPlayer:Player = getPlayerInstance(FFALoserComboBoxes[i].selectedLabel);
					losers.push(nextPlayer);
				}
			}
			
			//////////////////////////
			//Error Checking
			if(winner == null) {
				var errorMsg:WindowDialog = new WindowDialog(this, "There's No Winner", "Pick a winner from the highlighted drop down box.");
				return;
			}
			if(losers.length == 0) {
				var errorMsg2:WindowDialog = new WindowDialog(this, "There's No Losers", "Pick any number of losing players from the remaining drop down boxes.");
				return;
			}
			
			//Check if a player is listed twice
			for (var e in losers) {
				//check if winner is also listed as loser.
				if (losers[e].username==winner.username) {
					var errorMsg3:WindowDialog = new WindowDialog(this, "Player Repeated", "One or more players are repeated, this cannot count as a ladder game.");
					return;
				}
				//check if any loser is repeated.
				for (var t in losers) {
					if (t!=e) {
						if (losers[t].username==losers[e].username) {
							var errorMsg4:WindowDialog = new WindowDialog(this, "Player Repeated", "One or more players are repeated, this cannot count as a ladder game.");
							return;
						}
					}
				}
			}
			//////////////////////////
			//All's good, Math here
				winner.score+=losers.length;
				winner.numWins++;
				//Streak
				if (winner.streak>=0) {
					winner.streak++;
				} else {
					winner.streak=1;
				}
				//Losers
				for (var q in losers) {
					losers[q].score--;
					if (losers[q].score<20) {
						losers[q].score=20;
					}
					//losses
					losers[q].numLosses++;
					//Streak
					if (losers[q].streak<=0) {
						losers[q].streak--;
					} else {
						losers[q].streak=-1;
					}
				}
				var confirmTxt:String = winner.username+" has gained "+losers.length+" points from:\n\n";
				for(var j in losers) {
					confirmTxt += losers[j].username+", ";
				}
				confirmTxt = confirmTxt.substr(0, confirmTxt.length-2);
				var confirmMsg:WindowDialog = new WindowDialog(this, "Match Successfully Added", confirmTxt);
				
				losers.push(winner);
				players.updateRanks(losers);
				players.updateNumGames(losers);
				updateGrid();
		}
		
		private function saveLadder() {
			var playerXMLList:XMLList = new XMLList();
			//Sort the array numerically by score before parsing to make the XML look neater
			players.list.sortOn("score", Array.NUMERIC | Array.DESCENDING);
			for(var i in players.list) {
				var curPlayer:Player = players.list[i];
				
				var playerXML:XML = <Player>
										<name>{curPlayer.username}</name>
										<score>{curPlayer.score}</score>
										<wins>{curPlayer.numWins}</wins>
										<losses>{curPlayer.numLosses}</losses>
										<streak>{curPlayer.streak}</streak>
										<flag>{curPlayer.flag}</flag>
									</Player>;
									
				playerXMLList += playerXML;
			}
			
			XML.prettyPrinting=true;
			XML.prettyIndent=5;
			delete ladderData.PlayerList.Player;
			ladderData.PlayerList.appendChild(playerXMLList);
			var saveFile:Object = ssCore.App.showFileSave({caption: "Save Ladder File", path:"startdir://", filter:"Ladder Files (.xml)|*.xml||", filename:ladderName});
			ssCore.FileSys.writeToFile({path:saveFile.result, data:ladderData});
			var confirmMsg:WindowDialog = new WindowDialog(this, "Ladder Data Was Saved Successfully","The ladder data was successfully written to "+saveFile.result);
		}
		
		private function exportStandings() {
			switch(radioDefault.group.selection) {
				case radioDefault:
					exportStandings2("Default");
					break;
				case radioTOAO:
					exportStandings2("TOAO");
					break;
				case radioAoKH:
					exportStandings2("AoKH");
					break;
				case radioRoR:
					exportStandings2("RoR");
			}
		}
		
		private function exportStandings2($style:String) {
			//Date object
			var todaysDate:Date = new Date();
			players.list.sortOn("score", Array.NUMERIC | Array.DESCENDING);
			var exportArray = players.list.concat();
			exportList.text = "The Current "+ladderName+" Ladder Standings\nExported on "+(todaysDate.getMonth()+1)+"/"+todaysDate.getDate()+"/"+todaysDate.getFullYear()+"\n\n[b]"+Tier1+"[/b]\n";
			for (var i:uint = 0; i<= exportArray.length-1; i++) {
				if(exportArray[i].rank != Tier1) {
					exportArray.splice(0,i);
					break;
				}
				exportList.appendText(exportArray[i].exportFunction($style) +"\n");
			}
			
			exportList.appendText("\n[b]"+Tier2+"[/b]\n");
			for (var j:uint = 0; j<= exportArray.length-1; j++) {
				if(exportArray[j].rank != Tier2) {
					exportArray.splice(0,j);
					break;
				}
				exportList.appendText(exportArray[j].exportFunction($style) +"\n");
			}
			
			exportList.appendText("\n[b]"+Tier3+"[/b]\n");
			for (var k:uint = 0; k<= exportArray.length-1; k++) {
				if(exportArray[k].rank != Tier3) {
					exportArray.splice(0,k);
					break;
				}
				exportList.appendText(exportArray[k].exportFunction($style) +"\n");
			}
			
			exportList.appendText("\n[b]"+Tier4+"[/b]\n");
			for (var m:uint = 0; m<= exportArray.length-1; m++) {
				if(exportArray[m].rank != Tier4) {
					exportArray.splice(0,m);
					break;
				}
				exportList.appendText(exportArray[m].exportFunction($style) +"\n");
			}
			
			exportList.appendText("\n[b]"+Tier5+"[/b]\n");
			for (var n:uint = 0; n<= exportArray.length-1; n++) {
				if(exportArray[n].rank != Tier5) {
					exportArray.splice(0,n);
					break;
				}
				exportList.appendText(exportArray[n].exportFunction($style) +"\n");
			}
			
			exportList.appendText("\n[b]"+Tier6+"[/b]\n");
			for (var p:uint = 0; p<= exportArray.length-1; p++) {
				if(exportArray[p].rank != Tier6) {
					exportArray.splice(0,p);
					break;
				}
				exportList.appendText(exportArray[p].exportFunction($style) +"\n");
			}
		}
		
		private function clearSelection() {
			for(var i in comboBoxArray) {
				comboBoxArray[i].selectedItem = 0;
			}
		}
		////////////////////////////////////////////////////////////
		//The following functions help carry out the math for calculating wins and losses
		private function getPlayerInstance($name:String):Player {
			for (var i in players.list) {
				if(players.list[i].username == $name) {
					return players.list[i];
				}
			}
			return undefined;
		}
		
		private function calculatePoints($p1:String, $p2:String):int {
			switch ($p1) {
				case Tier1 :
					switch ($p2) {
						case Tier1 :
							return 6;
							break;
						case Tier2 :
							return 3;
							break;
						case Tier3 :
							return 3;
						default :
							return 1;
							break;
					}
					break;
				case Tier2 :
					switch ($p2) {
						case Tier1 :
							return 9;
							break;
						case Tier2 :
							return 6;
							break;
						case Tier3 :
							return 3;
							break;
						case Tier4 :
							return 3;
							break;
						default :
							return 1;
							break;
					}
					break;
				case Tier3 :
					switch ($p2) {
						case Tier1 :
							return 12;
							break;
						case Tier2 :
							return 9;
							break;
						case Tier3 :
							return 6;
							break;
						case Tier4 :
							return 3;
							break;
						case Tier5 :
							return 3;
							break;
						default :
							return 1;
							break;
					}
					break;
				case Tier4 :
					switch ($p2) {
						case Tier1 :
							return 15;
							break;
						case Tier2 :
							return 12;
							break;
						case Tier3 :
							return 9;
							break;
						case Tier4 :
							return 6;
							break;
						default :
							return 3;
							break;
					}
					break;
				case Tier5 :
					switch ($p2) {
						case Tier1 :
							return 18;
							break;
						case Tier2 :
							return 15;
							break;
						case Tier3 :
							return 12;
							break;
						case Tier4 :
							return 9;
							break;
						case Tier5 :
							return 6;
							break;
						case Tier6 :
							return 3;
							break;
					}
					break;
				case Tier6 :
					switch ($p2) {
						case Tier1 :
							return 21;
							break;
						case Tier2 :
							return 18;
							break;
						case Tier3 :
							return 15;
							break;
						case Tier4 :
							return 12;
							break;
						case Tier5 :
							return 9;
							break;
						case Tier6 :
							return 6;
							break;
					}
					break;
			}
			return undefined;
		}
		
		private function getRank(score:Number):String {
			if(score >= 20 && score <= 30) {
				return Tier6;
			}
			else if(score >= 31 && score <= 60) {
				return Tier5;
			}
			else if(score >= 61 && score <= 80) {
				return Tier4;
			}
			else if(score >= 81 && score <= 105) {
				return Tier3;
			}
			else if(score >= 106 && score <= 154) {
				return Tier2;
			}
			else if(score >= 155) {
				return Tier1;
			}
			return "";
		}
		
		////////////////////////////////////////////////////////////
		//Functions for adding and removing players from combo boxes
		private function addToComboBox($name:String) {
			//instead of adding the player objects here we just make a temporary object
			//then in the match functions we search for the player in the library based
			//on their username
			var obj:Object = {label:$name};
			for(var i in comboBoxArray) {
				comboBoxArray[i].addItem(obj);
			}
		}
		
		private function removeFromComboBox() {
			var itemToRemove:Object = comboBoxRemove.selectedItem;
			for(var i in comboBoxArray) {
				if(comboBoxArray[i].selectedItem == itemToRemove) {
					comboBoxArray[i].selectedItem = 0;
				}
				comboBoxArray[i].removeItem(itemToRemove);
			}
		}
		
		////////////////////////////////////////////////////////////
		//functions for creating the grid displaying the ladder standings.
		//creates columns
		private function createGrid() {
			//DataGrid columns
			var colName:DataGridColumn = new DataGridColumn("Name");
			var colScore:DataGridColumn = new DataGridColumn("Score");
			var colRank:DataGridColumn = new DataGridColumn("Rank");
			var colNumWins:DataGridColumn = new DataGridColumn("Wins");
			var colNumLosses:DataGridColumn = new DataGridColumn("Losses");
			var colStreak:DataGridColumn = new DataGridColumn("Streak");
			
			//few aesthetic changes
			colName.width = 197;
			colScore.width = 110;
			//don't let them resize the columns
			colName.resizable = colRank.resizable = colScore.resizable = colNumWins.resizable = colStreak.resizable = colNumLosses.resizable =false;
			//certain columns can't be sorted
			colRank.sortable = colStreak.sortable = false;
			colName.sortable = true;
			
			//Sortable columns should be sorted numerically
			colScore.sortOptions = Array.NUMERIC;
			colNumWins.sortOptions = Array.NUMERIC;
			colNumLosses.sortOptions = Array.NUMERIC;
			
			ladderStandings.addColumn(colName);
			ladderStandings.addColumn(colScore);
			ladderStandings.addColumn(colRank);
			ladderStandings.addColumn(colNumWins);
			ladderStandings.addColumn(colNumLosses);
			ladderStandings.addColumn(colStreak);
		}
		//updates cell data
		private function updateGrid() {
			for(var i in players.list) {
				for (var e in players.list) {
					if(players.list[i].username == returnCellData(ladderStandings, e)) {
						ladderStandings.editField(e,"Score", players.list[i].score);
						ladderStandings.editField(e,"Rank", players.list[i].rank);
						ladderStandings.editField(e,"Games", players.list[i].numGames);
						ladderStandings.editField(e, "Wins", players.list[i].numWins);
						ladderStandings.editField(e, "Losses", players.list[i].numLosses);
						if(players.list[i].streak > 0) {
							ladderStandings.editField(e,"Streak", "+"+players.list[i].streak);
						}
						else{
							ladderStandings.editField(e,"Streak", players.list[i].streak);
						}
					}
				}
			}
		}
		//adds player object to data grid
		private function addToDataGrid(obj:Player) {
			ladderStandings.addItem({Name: obj.username, Score: obj.score,Rank: obj.rank, Wins:obj.numWins, Losses: obj.numLosses, Streak: obj.streak});
		}
		//removes all columns, creates the grid again, and populates it with the player list, mainly used to remove a player from the ladder list after he has been removed from the array
		private function remakeGrid() {
			ladderStandings.removeAll();
			ladderStandings.removeAllColumns();
			createGrid();
			
			for(var i in players.list) {
				var obj:Player = players.list[i];
				addToDataGrid(obj);
			}
			updateGrid();
		}
		
		//used in updateGrid function to match cell data
		private function returnCellData(dataGrid:DataGrid, rowIndex:int, columnIndex:int = 0):String {
			var cellData:String = dataGrid.columns[columnIndex].itemToLabel(dataGrid.getItemAt(rowIndex));
			return cellData;
		}
	}
}
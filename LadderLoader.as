package {
	import flash.display.Sprite;
	import flash.display.MovieClip;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.events.*;
	import WindowDialog;
	import caurina.transitions.Tweener;
	
	public class LadderLoader extends Sprite {
		
		private var xmlLoader:URLLoader;
		private var emptyLadderData:XML;
		
		public function LadderLoader() {
			//synchronous commands for ssCore
			ssDefaults.synchronousCommands = true;
			
			//Load empty ladder data for creating new ladders
			var emptyObj:Object = ssCore.FileSys.readFile({path:"internal://emptyLadderData.xml"});
			emptyLadderData = new XML(emptyObj.result);
			
			loadBtn.addEventListener(MouseEvent.CLICK, loadLadderBtn);
			newBtn.addEventListener(MouseEvent.CLICK, newLadderBtn);
		}
		
		private function loadLadderBtn(e:MouseEvent) {
			ssCore.Win.show();
			var openFile:Object = ssCore.App.showFileOpen({caption:"Select a Ladder file", path:"startdir://", filter:"Ladder Files Files (.xml)|*.xml||"});
			
			xmlLoader = new URLLoader();
			xmlLoader.load(new URLRequest(openFile.result));
			xmlLoader.addEventListener(Event.COMPLETE, sendXMLToParent);
		}
		
		private function newLadderBtn(e:MouseEvent) {
			ssCore.Win.show();
			var createFile:Object = ssCore.App.showFileSave({caption: "Save New Ladder File", path:"startdir://", filter:"Ladder Files (.xml)|*.xml||", filename:"NewLadder.xml"});
			ssCore.FileSys.writeToFile({path:createFile.result, data: emptyLadderData});
			
			xmlLoader = new URLLoader();
			ssDebug.trace(createFile.result);
			xmlLoader.load(new URLRequest(createFile.result));
			xmlLoader.addEventListener(Event.COMPLETE, sendXMLToParent);
		}
		
		private function sendXMLToParent(e:Event) {
			//removes event listeners
			loadBtn.removeEventListener(MouseEvent.CLICK, loadLadderBtn);
			newBtn.removeEventListener(MouseEvent.CLICK, newLadderBtn);
			xmlLoader.removeEventListener(Event.COMPLETE, sendXMLToParent);
			
			//sends the loaded xml data to the main movieclip (which will then pass it on to the ladder manager).
			MovieClip(parent).loadedLadder = new XML(e.target.data);
			
			//sends the ladder name to main movieclip to pass to ladder manager.
			MovieClip(parent).ladderName = MovieClip(parent).loadedLadder.LadderName;
			//tweens the alpha to 0 and then removes the instance from the stage, this sets off an event listener 
			//in the main class that starts the ladder manager.
			Tweener.addTween(this, {alpha:0, time:0.5, transition:"linear", onComplete:removeSelf});
		}
		
		private function removeSelf() {
			MovieClip(parent).removeChild(this);
		}
	}
}
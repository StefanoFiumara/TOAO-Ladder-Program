package {
	import flash.display.MovieClip;
	import flash.events.*;
	import caurina.transitions.Tweener;
	
	public class LadderProgram extends MovieClip {
		
		private var ladderLoader:LadderLoader;
		private var ladderManager:LadderManager;
		
		//Ladder name and xml file must be accesible to both LadderLoader and LadderManager
		public var loadedLadder:XML;
		public var ladderName:String;
		
		//Tier List must be accesible to both LadderManager and Player classes
		
		
		public function LadderProgram() {
			ladderLoader = new LadderLoader();
			addChild(ladderLoader);
			
			ladderLoader.addEventListener(Event.REMOVED_FROM_STAGE, addLadderManager);
		}
		
		private function addLadderManager(e:Event) {
			ladderManager = new LadderManager(loadedLadder, ladderName);
			ladderManager.alpha = 0;
			addChild(ladderManager);
			Tweener.addTween(ladderManager, {alpha:1, time:0.5, transition:"linear"});
		}
	}
}
package {
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.*;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	
	public class WindowDialog extends Sprite {
		
		public var parentMC:Sprite;
		
		public function WindowDialog(mc:Sprite, $title:String, $msg:String) {
			parentMC = mc;
			msgTxt.text = $msg;
			titleTxt.text = $title;
			okBtn.addEventListener(MouseEvent.CLICK, removeSelf);
			addEventListener(Event.ADDED_TO_STAGE, addedToStage);
			parentMC.addChild(this);
		}
		
		private function removeSelf(e:MouseEvent) {
			parentMC.removeChild(this);
			parentMC.removeEventListener(KeyboardEvent.KEY_DOWN, listenForEnter);
			okBtn.removeEventListener(MouseEvent.CLICK, removeSelf);
			delete this;
		}
		
		private function addedToStage(e:Event) {
			removeEventListener(Event.ADDED_TO_STAGE, addedToStage);
			parentMC.addEventListener(KeyboardEvent.KEY_DOWN, listenForEnter);
		}
		
		private function listenForEnter(e:KeyboardEvent) {
			if(e.keyCode == 13) {
				removeSelf(null);
			}
		}
	}
}
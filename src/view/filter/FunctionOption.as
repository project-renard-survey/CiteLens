package view.filter {
	
	//imports
	import com.greensock.TweenMax;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import events.CiteLensEvent;
	
	import model.CitationFunction;
	
	import view.assets.Button;
	import view.style.ColorSchema;
	
	public class FunctionOption extends OptionBox {
		
		//properties
		private var _id:int;																								//Function Option ID
		private var _type:String;
		private var _label:String;
		private var _options:Array;
		private var _subFunctions:Array;
		private var _selected:Boolean;
		private var _subItemLevel:int = 0;
		private var posX:Number = 90;

		private var labelContainer:Sprite;
		private var functionButton:Button;	
		private var button:Button;	
		private var functionOption:FunctionOption
		private var line:Sprite;
		private var sepLine:Sprite;
		
		public function FunctionOption(labelString:String, fID:int, id_:int = -1, type_:String = CitationFunction.UNIQUE) {
			
			super(fID);
			
			//Save id
			if (_id != -1) {
				id = id_;
			}
			
			//save label
			_label = labelString;
			
			//type
			type = type_;
			
			//If unique
			if (type == CitationFunction.UNIQUE) {
				selected = false;
			}
			
			//Container
			labelContainer = new Sprite();
			this.addChild(labelContainer);
			
			//button
			functionButton = new Button(labelString.toLowerCase(),"General Label");
			labelContainer.addChild(functionButton);
			functionButton.addEventListener(MouseEvent.CLICK, _functionClick);
			
			//spaces
			posY = this.height + 2;
			
		}

		public function get id():int {
			return _id;
		}
		
		public function set id(value:int):void {
			_id = value;
		}
		
		public function get label():String {
			return _label;
		}

		public function set label(value:String):void {
			_label = value;
		}
		
		public function get type():String {
			return _type;
		}
		
		public function set type(value:String):void {
			_type = value;
		}
		
		public function get subItemLevel():int {
			return _subItemLevel;
		}
		
		public function set subItemLevel(value:int):void {
			_subItemLevel = value;
		}
		
		public function get selected():Boolean {
			return _selected;
		}
		
		public function set selected(value:Boolean):void {
			_selected = value;
			if (functionButton){
				(_selected) ? functionButton.status = "selected" : functionButton.status = "active";
			}
		}

		public function get options():Array {
			return _options.concat();
		}

		public function set options(value:Array):void {
			_options = value;
			
			//test if there is selected options
			for each (var item:Object in _options) {
				if (item.value == true) {
					showFactOpinion();
					break;
				}
			}
		}
		
		public function get subFunctions():Array {
			return _subFunctions.concat();
		}
		
		public function set subFunctions(value:Array):void {
			_subFunctions = value;
			
			//test if there is selected options
			var testSelected:Boolean = false;
			
			for each (var subFunct:CitationFunction in _subFunctions) {
				var items:Array = subFunct.options;
				for each (var item:Object in items) {
					if (item.value == true) {
						showSubFunctions();
						testSelected = true;
						break;
					}
				}
				if (testSelected) {
					break;
				}
			}
		}
		
		public function get hasSubFuntions():Boolean {
			return (_subFunctions) ? true : false;
		}
		
		public function get hasOption():Boolean {
			return (_options) ? true : false;
		}
		
		public function separateLine():void {
			
			var lineW:Number = maxW - (4 * margin)
			var dashLenght:Number = 2;
			var gapLenght:Number = 4;
			var currentXPos:Number = 0;	
			
			line = new Sprite();
			line.graphics.lineStyle(1,ColorSchema.getColor("filter"+filterID));
			line.graphics.beginFill(0x000000);
			
			while(currentXPos < lineW) {
				line.graphics.lineTo(currentXPos + dashLenght, 0);
				currentXPos = currentXPos + dashLenght;
				line.graphics.moveTo(currentXPos + gapLenght, 0);
				currentXPos = currentXPos + gapLenght;
			}
			
			line.graphics.endFill();
			
			line.y = this.height + 2;
			this.addChild(line);
		}
		
		private function _functionClick(e:MouseEvent):void {
			
			var button:Button = Button(e.target);
			
			if (!selected) {
				switchClick(button, "selected")
			} else {
				switchClick(button, "active");
			}
			
			switch (type) {
				
				case CitationFunction.SIMPLE:
					(selected) ? hideFactOpinion() : showFactOpinion();
					break;
				
				case CitationFunction.COMPLEX:
					(selected) ? hideSubFunctions() : showSubFunctions();
					break;
				
			}
			
		}
		
		
		private function showSubFunctions():void {
			
			optionArray = new Array;
			
			
			
			var expandedHeight:Number = 0;
			for each (var item:CitationFunction in subFunctions) {
				
				//Functions
				functionOption = new FunctionOption(item.label, filterID, item.id, item.type);
				functionOption.subItemLevel = 1;
				functionOption.options = item.options;
				
				functionOption.x = 15;
				functionOption.y = posY;
				this.addChild(functionOption);
				
				//check if the button is selected
				if (item.value == true) {
					functionOption.selected
				}
				
				optionArray.push({id:item.id, label:item.label, bt:functionOption, source:item}); //original id:item.label
					
				//update position
				posY = this.height + 2;
				
				expandedHeight += functionOption.height + 2;
				
				//TweenMax.from(functionOption,.5,{y:functionOption.y - 20, alpha:0,delay:.1 * item.id});
			}
			
			//prevent the button to be clicked during the animation
			//labelContainer.mouseChildren = false;
			
			//move endline further down
			if (line) {
				TweenMax.to(line,.5,{y:line.y + expandedHeight,onComplete:showOptionCompleted});
				
				function showOptionCompleted():void {
					labelContainer.mouseChildren = true;
				}
				
			}

			//expand main box
			FunctionBox(this.parent.parent).expandHeight(this, expandedHeight);
			
			//change expenad state
			selected = true;
			
			triggerEvent()
		}
		
		private function hideSubFunctions():void {

			var contractedHeight:Number = 0;
			
			for (var i:int = 0; i < optionArray.length; i++) {
				var item:FunctionOption = optionArray[i].bt;
				contractedHeight += item.height + 2;
				
				//animation
				TweenMax.to(item,.5,{y:0, alpha:0});
				
			}
			
			//move endline further down
			if (line) {
				TweenMax.to(line,.5,{y:line.y - contractedHeight,onComplete:removeSubOptions});
			}
			
			//remove items
			removeSubOptions();
			
			//expand main box
			FunctionBox(this.parent.parent).contactHeight(this, contractedHeight);
		}
		
		
		private function removeSubOptions():void {
			
			var item:FunctionOption;
			for (var i:int = 0; i < optionArray.length; i++) {
				item = optionArray[i].bt;
				
				this.removeChild(item);
			}
			
			posY = this.height;
			
			item = null;
			optionArray = null;
			
			//change expenad state
			selected = false;
			
			triggerEvent()
		}
	
		
		private function showFactOpinion():void {
			optionArray = new Array;
			
			for (var i:int = 0; i < options.length; i++) {
				
				//taking the 1º character
				var optLabel:String = options[i].label		
				optLabel = optLabel.slice(0,1);
				
				button = new Button(optLabel,"Button Style");
				button.x = posX - (subItemLevel * 30);
				this.addChild(button);
				
				button.addEventListener(MouseEvent.CLICK, factOpinionClick);
				
				//check if the button is selected
				if (options[i].value == true) {
					switchClick(button, "selected")
				}
				
				optionArray.push({label:options[i].label, bt:button, selected:options[i].value});
				
				//update position
				posX += button.width + 2;
				
				//animation
				TweenMax.from(button,.3,{x:button.x - 5, alpha:0});
				
			}
			
			if (label == "Further Reading") {
				button = optionArray[0].bt;
				button.status = "selected";
				optionArray[0].selected = true;
			}
			
			
			selected = true;
			
			triggerEvent()
			
		}
		
		
		private function hideFactOpinion():void {
			
			for (var i:int = 0; i < optionArray.length; i++) {
				var item:Button = optionArray[i].bt;
				
				//animation
				if (i == optionArray.length-1) {
					TweenMax.to(item,.5,{x:item.x - 5, alpha:0,onComplete:removeFactOpinion});
				} else {
					TweenMax.to(item,.5,{x:item.x - 5, alpha:0});
				}
				
			}
			
			changeSubFunctionsStatus();
		}
		
		private function removeFactOpinion():void {
			
			for (var i:int = 0; i < optionArray.length; i++) {
				var item:Button = optionArray[i].bt;
				
				this.removeChild(item);
			}
			
			posX = 90;
			optionArray = null;
			selected = false;
			triggerEvent();
		}
		
		private function factOpinionClick(e:MouseEvent = null):void {

			var option:Object;
			
			var targetButton:Button = Button(e.target);
			
			//deselect
			if (targetButton.status != "selected") {
				for each (option in optionArray) {
					button = option.bt;
					button.status = "active";
					option.selected = false;
				}
			}
			
			
			//option click
			if (e) {
				_click(e);
			}
			
		}
		
		private function changeSubFunctionsStatus():void {
			this.selected = false;
			
			if (this.parent is FunctionOption) {
				
				var func:FunctionOption = FunctionOption(this.parent);
				
				var sub:Object;
				var anySubSelected:Boolean = false;
				
				for each (sub in func.optionArray) {
					var subBT:FunctionOption = sub.bt;
					
					
					
					if (subBT.selected == true) {
						anySubSelected = true;
						break;
					}
				}
				if (!anySubSelected) {
					FunctionOption(this.parent).selected = false;
				}
			}
		}
		
		private function triggerEvent():void {
			//dispatch visualization change
			var obj:Object = new Object()
			obj.filterID = filterID;
			
			dispatchEvent(new CiteLensEvent(CiteLensEvent.CHANGE_VISUALIZATION,obj));
		}

	}
}
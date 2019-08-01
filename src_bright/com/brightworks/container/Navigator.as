package com.brightworks.container {

import com.brightworks.util.Log;

import mx.core.IVisualElement;
import mx.core.UIComponent;

import spark.components.Group;

public class Navigator extends Group {


	// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	//
	//          Getters / Setters
	//
	// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

	private var _selectedItem:IVisualElement;

	public function get selectedItem():IVisualElement {
		return _selectedItem;
	}

	public function set selectedItemById(id:String):void {
		var previousSelectedItem:IVisualElement = _selectedItem;
		_selectedItem = null;
		var elementCount:int = numElements;
		for (var i:int = 0; i < elementCount; i++) {
			var e:IVisualElement = getElementAt(i);
			if (e is UIComponent) {
				var comp:UIComponent = UIComponent(e);
				if (comp.id == id) {
					e.visible = true;
					_selectedItem = e;
				}
				else {
					e.visible = false;
				}
			}
			else {
				Log.warn("Navigator.set selectedItemById() - Element at index " + i + " is not a UIComponent, thus has no ID - thus Navigator can't check whether it is the desired element. Navigator feels sad and confused.");
				e.visible = false;
			}
		}
		if (_selectedItem) {
			invalidateDisplayList();
		}
		else {
			Log.warn("Navigator.set selectedItemById() - Unable to find element that matches ID");
			_selectedItem = previousSelectedItem;
		}
	}

	// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	//
	//          Public Methods
	//
	// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

	public function Navigator() {
	   super();

	}

	override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
		super.updateDisplayList(unscaledWidth, unscaledHeight);
		if (numChildren == 0)
				return;
		for (var i:int = 0; i < numChildren; i++) {
			var e:IVisualElement = getElementAt(i);
			e.height = height;
			e.width = width;
			if ((_selectedItem) && (_selectedItem == e)) {
				e.visible = true;
			}
			else {
				e.visible = false;
			}
		}
		if (!_selectedItem) {
			_selectedItem = getElementAt(0);
			_selectedItem.visible = true;

		}
	}




}
}
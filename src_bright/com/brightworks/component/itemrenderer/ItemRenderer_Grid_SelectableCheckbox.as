package com.brightworks.component.itemrenderer {
   import com.brightworks.interfaces.ISelectable;

   import flash.events.Event;

   import spark.components.CheckBox;
   import spark.components.gridClasses.GridItemRenderer;
   import spark.events.ListEvent;

   public class ItemRenderer_Grid_SelectableCheckbox extends GridItemRenderer {
      private var _checkbox:CheckBox;

      // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      //
      //     Getters / Setters
      //
      // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

      public override function set data(value:Object):void {
         var oldData:Object = data;
         super.data = value;
         if (value) {
            _checkbox.visible = true;
            if (value != oldData) {
               var item:ISelectable = ISelectable(value);
               if (item.isSelectable) {
                  _checkbox.enabled = true;
                  _checkbox.selected = item.isSelected;
               } else {
                  _checkbox.enabled = false;
                  _checkbox.selected = false;
               }
            }
         } else {
            _checkbox.visible = false;
         }
      }

      // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      //
      //     Public Methods
      //
      // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

      public function ItemRenderer_Grid_SelectableCheckbox() {
      }

      // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      //
      //     Protected Methods
      //
      // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

      override protected function createChildren():void {
         super.createChildren();
         _checkbox = new CheckBox();
         _checkbox.addEventListener(Event.CHANGE, onCheckboxChange);
         _checkbox.horizontalCenter = 3;
         _checkbox.verticalCenter = 0;
         addElement(_checkbox);
      }

      override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
         super.updateDisplayList(unscaledWidth, unscaledHeight);
         if ((height > 0) && ((width != 30) || (_checkbox.width != 18) || (_checkbox.x != 6))) {
            var foo:int = 0;
         }
      }

      // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      //
      //     Private Methods
      //
      // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

      private function onCheckboxChange(event:Event):void {
         ISelectable(data).isSelected = _checkbox.selected;
      }

   }

}

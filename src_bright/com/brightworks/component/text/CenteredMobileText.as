package com.brightworks.component.text
{
    import flash.text.TextFieldAutoSize;

    public class CenteredMobileText extends MobileText
    {
        private static const _MARGIN:Number = .01;

        public function CenteredMobileText()
        {
            super();
        }

        override protected function doInitTextField():void
        {
            super.doInitTextField();
            textField.setStyle("textAlign", "center");
            textField.autoSize = TextFieldAutoSize.CENTER;
        }

        override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
        {
            super.updateDisplayList(unscaledWidth, unscaledHeight);
            textField.width = Math.round(width * (1 - (4 * _MARGIN)));
            textField.x = Math.round((width * _MARGIN) * 2);
            textField.y = (height - textField.height) / 2;
            spriteVisualElement.height = Math.round(height * (1 - (2 * _MARGIN)));
            spriteVisualElement.width = Math.round(width * (1 - (2 * _MARGIN)));
            spriteVisualElement.x = Math.round(width * _MARGIN);
            spriteVisualElement.y = Math.round(height * _MARGIN);
        }

    }
}

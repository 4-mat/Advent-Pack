// Decompiled by AS3 Sorcerer 6.30
// www.as3sorcerer.com

//fl.controls.dataGridClasses.HeaderRenderer

package fl.controls.dataGridClasses
{
    import fl.controls.LabelButton;

    [Style(name="selectedDisabledSkin", type="Class")]
    [Style(name="selectedUpSkin", type="Class")]
    [Style(name="selectedDownSkin", type="Class")]
    [Style(name="selectedOverSkin", type="Class")]
    public class HeaderRenderer extends LabelButton 
    {

        private static var defaultStyles:Object = {
            "upSkin":"HeaderRenderer_upSkin",
            "downSkin":"HeaderRenderer_downSkin",
            "overSkin":"HeaderRenderer_overSkin",
            "disabledSkin":"HeaderRenderer_disabledSkin",
            "selectedDisabledSkin":"HeaderRenderer_selectedDisabledSkin",
            "selectedUpSkin":"HeaderRenderer_selectedUpSkin",
            "selectedDownSkin":"HeaderRenderer_selectedDownSkin",
            "selectedOverSkin":"HeaderRenderer_selectedOverSkin",
            "textFormat":null,
            "disabledTextFormat":null,
            "textPadding":5
        };

        public var _column:uint;

        public function HeaderRenderer():void
        {
            focusEnabled = false;
        }

        public static function getStyleDefinition():Object
        {
            return (defaultStyles);
        }


        public function get column():uint
        {
            return (this._column);
        }

        public function set column(_arg_1:uint):void
        {
            this._column = _arg_1;
        }

        override protected function drawLayout():void
        {
            var _local_1:Number = Number(getStyleValue("textPadding"));
            textField.height = (textField.textHeight + 4);
            textField.visible = (label.length > 0);
            var _local_2:Number = (textField.textWidth + 4);
            var _local_3:Number = (textField.textHeight + 4);
            var _local_4:Number = ((icon == null) ? 0 : (icon.width + 4));
            var _local_5:Number = Math.max(0, Math.min(_local_2, ((width - (2 * _local_1)) - _local_4)));
            if (icon != null)
            {
                icon.x = (((width - _local_1) - icon.width) - 2);
                icon.y = Math.round(((height - icon.height) / 2));
            };
            textField.width = _local_5;
            textField.x = _local_1;
            textField.y = Math.round(((height - textField.height) / 2));
            background.width = width;
            background.height = height;
        }


    }
}//package fl.controls.dataGridClasses


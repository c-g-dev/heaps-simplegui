package heaps.simplegui.components.control;

import h2d.Graphics;
import hxd.res.DefaultFont;
import h2d.TextInput;

class InputField extends h2d.Object {
    public var textInput: TextInput;

    public function new(width: Int, height: Int) {
        super();

        var graphics = new Graphics(this);
        graphics.beginFill(0xFFFFFF);
        graphics.drawRect(0, 0, width, height);
        graphics.endFill();
        graphics.lineStyle(1, 0x000000);
        graphics.drawRect(0, 0, width, height);

        //lots of issues with native TextInput especially regarding word wrap
        //looked into it and not too complex but would require a lot of regression
        //leaving existing flaws in for now.
        textInput = new TextInput(DefaultFont.get());
        textInput.textColor = 0x000000;
        textInput.inputWidth = width;
        textInput.x = 5;

        addChild(textInput);
    }

}
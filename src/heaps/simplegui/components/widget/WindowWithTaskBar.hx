package heaps.simplegui.components.widget;

import h2d.Graphics;
import h2d.Object;

class WindowWithTaskBar extends h2d.Object {
    public var content:Graphics;
    public var taskBar:Graphics;

    public var width: Int;
    public var height: Int;

    public function new(width: Int, height: Int) {
        super();

        this.width = width;
        this.height = height;

        content = new Graphics();
        taskBar = new Graphics();

        addChild(content);
        addChild(taskBar);

        resize(width, height);
    }

    public function resize(width:Int, height:Int):Void {
        this.width = width;
        this.height = height;
        
        content.clear();
        content.beginFill(0xE0E0E0);
        content.drawRect(0, 0, width, height - 50);
        content.endFill();
        
        taskBar.clear();
        taskBar.beginFill(0xCCCCCC);
        taskBar.drawRect(0, height - 50, width, 50);
        taskBar.endFill();
    }
}
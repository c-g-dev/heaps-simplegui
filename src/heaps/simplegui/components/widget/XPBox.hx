package heaps.simplegui.components.widget;

import h2d.Object;
import h2d.Bitmap;
import h2d.Tile;

class XPBox extends h2d.Object {
    public var width:Int;
    public var height:Int;
    private var bg:h2d.Bitmap;
    private var border:Border;

    public function new(width:Int, height:Int) {
        super();
        this.width = width;
        this.height = height;

        bg = new h2d.Bitmap(h2d.Tile.fromColor(0xFFCCCCCC, width, height));
        addChild(bg);

        border = new Border({
            thickness: 1, 
            size: Absolute(width, height),
            color: Single(0x000000)
        });

        addChild(border);
    }

    public function setSize(width: Int, height: Int): Void {
        this.width = width;
        this.height = height;

        bg.tile = h2d.Tile.fromColor(0xFFCCCCCC, width, height);
        border.changeSize(Absolute(width, height));
    }
}
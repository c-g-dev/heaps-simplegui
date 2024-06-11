package heaps.simplegui.components.util;

import h2d.Tile;

class InvisibleBox extends h2d.Bitmap {

    public function new(widthArg:Int, heightArg:Int) {
        super(Tile.fromColor(0x000000, Std.int(Math.max(widthArg, 1)), Std.int(Math.max(heightArg, 1)), 0));
    }

}
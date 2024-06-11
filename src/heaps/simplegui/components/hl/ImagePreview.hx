package heaps.simplegui.components.hl;

import heaps.simplegui.components.widget.Panel;
import haxe.io.Path;
import hxd.res.Image;
import h2d.Bitmap;


class ImagePreview extends h2d.Object {

    var bitmap:Bitmap;
    var panel:Panel;
    var width:Int;
    var height:Int;

    public function new(width:Int, height:Int) {
        super();

        this.width = width;
        this.height = height;
        
        panel = new Panel(width, height);
        bitmap = new Bitmap(null, panel.content);
        
        this.addChild(panel);
    }

    public function loadImage(filename:String) {
        if(["png", "jpg"].contains(Path.extension(filename))){
            var bytes = hxd.File.getBytes(filename);
            bitmap.tile = hxd.res.Any.fromBytes(filename, bytes).toTile();
            bitmap.width = this.width;
            bitmap.height = this.height;
        }
    }
}
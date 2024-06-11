package heaps.simplegui.util;

#if hl
import sys.io.File;
#end
import h2d.Layers;
import h2d.Tile;
import h2d.Graphics;
import hxd.BitmapData;
import h2d.Dropdown;

class HeapsUtil {
    

    public static function elipsizeText(maxWidth: Int, text: h2d.Text) {
        var originalText = text.text;
        var ellipsis = "...";
        
        var textWidth = text.calcTextWidth(text.text);

        if (textWidth > maxWidth) {
            var truncatedText = originalText;
            var endIndex = originalText.length;
            
            while (textWidth > maxWidth && endIndex > 0) {
                endIndex--;
                truncatedText = originalText.substr(0, endIndex) + ellipsis;
                text.text = truncatedText;
                textWidth = text.calcTextWidth(text.text);
            }
        }
    }

    public static function text(value:String): h2d.Text {
        var text = new h2d.Text(hxd.res.DefaultFont.get());
        text.text = value;
        text.textColor = 0x000000;
        return text;
    }

    
    public static function objectToTile(obj: h2d.Object, ?cut: {x: Int, y: Int, w: Int, h: Int}): h2d.Tile {
        if(cut == null){
            var gfxBounds = obj.getBounds();
            cut = {
                x: Std.int(obj.getAbsPos().x),
                y: Std.int(obj.getAbsPos().y),
                w: Std.int(gfxBounds.width),
                h: Std.int(gfxBounds.height)
            }
        }

        var currentX = obj.x;
        var currentY = obj.y;
        obj.x -= cut.x;
        obj.y -= cut.y;
        
        //if this isn't working as expected, debug with writeObjectToFile() and tweak the cut
        var texture = new h3d.mat.Texture(cut.w, cut.h, [ Target ]);
        obj.drawTo(texture);

        obj.x = currentX;
        obj.y = currentY;

        return Tile.fromTexture(texture);
    }

    #if hl
    public static function writeObjectToFile(obj: h2d.Object, outputFilename: String) {
        var texture = new h3d.mat.Texture(1000, 1000, [ Target ]);
        obj.drawTo(texture);
        var pix = texture.capturePixels();
        var pngData = pix.toPNG();
        File.saveBytes(outputFilename, pngData);
    }
    #end
    
    public static function centerInParent(obj: h2d.Object) {
        if (obj.parent != null) {
            var parentBounds = obj.parent.getBounds();
            var objBounds = obj.getBounds();
    
            obj.x = Std.int(parentBounds.x + (parentBounds.width - objBounds.width) / 2);
            obj.y = Std.int(parentBounds.y + (parentBounds.height - objBounds.height) / 2);
        }
    }

    public static function getLayerToChildrenMap(layers: Layers): Map<Int, Array<h2d.Object>> {
        var layerMap = new Map<Int, Array<h2d.Object>>();
        @:privateAccess for (i in 0...layers.layerCount) {
            layerMap.set(i, Lambda.array(cast layers.getLayer(i)));
        }
        return layerMap;
    }
    
    public static function setLayerToChildrenMap(objs: Map<Int, Array<h2d.Object>>, layers: Layers): Void {
        for (i in objs.keys()) {
            var layerObjects = objs.get(i);
            for (j in 0...layerObjects.length) {
                layers.add(layerObjects[j], i, j);
            }
        }
    }
}
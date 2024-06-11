package heaps.simplegui.components.widget;

import hxd.Window;
import h2d.Object;
import h2d.Tile;
import h2d.Graphics;
import h2d.Layers;

import h2d.Graphics;
import h2d.Object;
import h2d.Tile;
import h2d.Layers;

class Background extends h2d.Object {
    private var content:BackgroundContent;
    private var binding:BackgroundBinding;
    private var fill:BackgroundFill;
    private var g:Graphics;
    private var calcBounds: () -> {x: Int, y: Int, width: Int, height:Int};
    private var isRemoved = false;

    private function new(content:BackgroundContent, fill:BackgroundFill, binding:BackgroundBinding, calcBounds: () -> {x: Int, y: Int, width: Int, height:Int}) {
        super();
        this.content = content;
        this.fill = fill;
        this.g = new Graphics(this);
        this.calcBounds = calcBounds;
        refresh();

        switch binding {
            case BindToWindow: {
                var event: () -> Void = null;
                event = () -> {
                    if(this.isRemoved){
                        Window.getInstance().removeResizeEvent(event);
                    }
                    refresh();
                };
                Window.getInstance().addResizeEvent(event);
            }
            default:
        }
    }

    override function onRemove() {
        super.onRemove();
        this.isRemoved = true;
    }

    public static function create(content:BackgroundContent, binding:BackgroundBinding, fill:BackgroundFill):Background {
        var calcBounds = getBoundsFunction(binding);
        var bg = new Background(content, fill, binding, calcBounds);
        switch binding {
            case BindToObject(obj): {
                obj.addChild(bg);
            }
            default:
        }
        bg.refresh();
        return bg;
    }

    public static function wrap(content:BackgroundContent, binding:BackgroundBinding, fill:BackgroundFill):h2d.Layers {
        var layers = new h2d.Layers();
        var calcBounds = getBoundsFunction(binding);
        var bg = new Background(content, fill, binding, calcBounds);
        layers.addChild(bg);
        switch binding {
            case BindToObject(obj): {
                obj.addChild(bg);
            }
            default:
        }
        bg.refresh();
        return layers;
    }

    private static function getBoundsFunction(binding:BackgroundBinding): () -> {x: Int, y: Int, width: Int, height: Int} {
        return switch(binding) {
            case BindToObject(obj):
                () -> {
                    var bounds = obj.getBounds();
                    {x: Std.int(bounds.x), y: Std.int(bounds.y), width: Std.int(bounds.width), height: Std.int(bounds.height)}
                };
            case BindToWindow:
                () -> {
                    var window = hxd.Window.getInstance();
                    {x: 0, y: 0, width: window.width, height: window.height}
                };
            case Absolute(width, height):
                () -> {x: 0, y: 0, width: width, height: height};
            case Custom(cb):
                cb;
        }
    }

    public function refresh():Void {
        g.clear();
        var parentBounds = calcBounds();

        switch (content) {
            case Tile(tile):
                switch (fill) {
                    case NoFill:
                        g.drawTile(0, 0, tile);
                    case Stretch:
                        tile.scaleToSize(parentBounds.width, parentBounds.height);
                        g.drawTile(0, 0, tile);
                    case StretchAspectRatio:
                        var scale = Math.min(parentBounds.width / tile.width, parentBounds.height / tile.height);
                        var w = tile.width * scale;
                        var h = tile.height * scale;
                        var x = (parentBounds.width - w) / 2;
                        var y = (parentBounds.height - h) / 2;
                        tile.scaleToSize(w, h);
                        g.drawTile(x, y, tile);
                    case Repeat:
                        for (x in 0...Math.ceil(parentBounds.width / tile.width)) {
                            for (y in 0...Math.ceil(parentBounds.height / tile.height)) {
                                g.drawTile(x * tile.width, y * tile.height, tile);
                            }
                        }
                }
            case Color(c):
                g.beginFill(c);
                g.drawRect(0, 0, parentBounds.width, parentBounds.height);
                g.endFill();
        }
    }
}

enum BackgroundContent {
    Tile(tile: h2d.Tile);
    Color(c: Int);
}

enum BackgroundBinding {
    BindToObject(obj: h2d.Object);
    BindToWindow;
    Absolute(width: Int, height: Int);
    Custom(cb: () -> {x: Int, y: Int, width: Int, height: Int});
}

enum BackgroundFill {
    NoFill;
    Stretch;
    StretchAspectRatio;
    Repeat;
}
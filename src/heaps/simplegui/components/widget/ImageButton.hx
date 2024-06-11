package heaps.simplegui.components.widget;

import haxe.ds.Option;
import h2d.Graphics;

class ImageButton extends h2d.Object {
    public var onClick: Void -> Void;
    private var tile: h2d.Tile;
    private var background: Graphics;
    private var interactive: h2d.Interactive;
    private var _width: Int;
    private var _height: Int;
    
    public var isDisabled: Bool = false;

    public function new(tile: h2d.Tile) {
        super();

        this.tile = tile;

        _width = Std.int(tile.width + 10);
        _height = Std.int(tile.height + 10);

        background = new Graphics();
        addChildAt(background, 0);

        var image = new h2d.Bitmap(tile);
        image.setPosition(5, 5);
        addChild(image);

        interactive = new h2d.Interactive(_width, _height);
        
        interactive.onPush = (e) -> {
            if(!isDisabled){
                background.adjustColor({lightness : -0.5}); 
                image.adjustColor({lightness : -0.5});
            }
        };

        interactive.onRelease = (e) -> {
            if(!isDisabled){
                background.adjustColor({lightness : 0}); 
                image.adjustColor({lightness : 0});
                if (onClick != null) onClick();
            }
        };

        addChild(interactive);

        redrawBackground();
    }

    public function disable() {
        isDisabled = true;
        redrawBackground();
    }

    public function enable() {
        isDisabled = false;
        redrawBackground();
    }

    public function setWidth(width: Int) {
        _width = width;
        redrawBackground();
        
        interactive.width = _width;
        interactive.height = _height;
    }

    private function redrawBackground(): Void {
        _height = Std.int(tile.height + 10);
        
        background.clear();
        background.beginFill(getBGColor());
        
        background.drawRect(0, 0, _width, _height);
        background.endFill();

        background.lineStyle(1, 0x000000);
        background.drawRect(0, 0, _width, _height);
    }

    public function setTile(newTile: h2d.Tile): Void {
        this.tile = newTile;
        _width = Std.int(newTile.width + 10);
        _height = Std.int(newTile.height + 10);
        redrawBackground();
        interactive.width = _width;
        interactive.height = _height;
    }

    
    var colorOverride: Int = 0xDDDDDD;
    private function getBGColor(): Int {


        if(!isDisabled){
            return colorOverride;
        }
        else {
            return 0x888888;
        }
    }

    public function setBackgroundColor(color: Int): Void {
        this.colorOverride = color;
        redrawBackground();
    }
}
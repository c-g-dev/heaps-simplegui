package heaps.simplegui.components.widget;

import haxe.ds.Option;
import h2d.Interactive;
import h2d.Graphics;
import h2d.Text;
import hxd.res.DefaultFont;

class Button extends h2d.Object {
    public var onClick: Void -> Void;
    private var text: Text;
    private var background: Graphics;
    private var interactive: Interactive;
    private var PADDING: Int = 5;
    private var _width: Int;
    private var _height: Int;
    
    public var isDisabled: Bool = false;

    public function new(textParam: String) {
        super();

        text = new Text(DefaultFont.get());
        text.text = textParam;
        text.textColor = 0x000000;

        addChild(text);
        text.y = PADDING;
        text.x = PADDING;

        _width = Std.int(text.calcTextWidth(textParam) + (PADDING * 2));
        _height = Std.int(text.textHeight + (PADDING * 2));

        background = new Graphics();
        addChildAt(background, 0);

        interactive = new Interactive(_width, _height);
        
        interactive.onPush = (e) -> {
            if(!isDisabled){
                background.adjustColor({lightness : -0.5}); 
            }
        };

        interactive.onRelease = (e) -> {
            switch e.kind {
                case EReleaseOutside: return;
                default:
            }
            if(!isDisabled){
                background.adjustColor({lightness : 0}); 
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
        _width = Std.int(text.calcTextWidth(text.text) + (PADDING * 2));
        _height = Std.int(text.textHeight + (PADDING * 2));
        
        background.clear();

        background.beginFill(getBGColor());
        
        background.drawRect(0, 0, _width, _height);
        background.endFill();

        background.lineStyle(1, 0x000000);
        background.drawRect(0, 0, _width, _height);

        text.x = Math.max(PADDING, (_width - text.calcTextWidth(text.text)) / 2);
    }

    public function setText(newText: String): Void {
        text.text = newText;
        redrawBackground();
        interactive.width = _width;
        interactive.height = _height;
    }

    var colorOverride: Option<Int> = None;
    private function getBGColor(): Int {
        switch colorOverride {
            case Some(v): return v;
            case None:
        }

        if(!isDisabled){
            return 0xDDDDDD;
        }
        else {
            return 0x888888;
        }
    }

    public function setBackgroundColor(color: Int): Void {
        this.colorOverride = Some(color);
        redrawBackground();
        this.colorOverride = None;
    }
}
package heaps.simplegui.components.widget;

import heaps.simplegui.components.util.InvisibleBox;
import hxd.Window;
import ludi.commons.util.Styles;
import h2d.Graphics;

typedef LineBreakStyle = {
    color: Int,
    thickness: Int,
    margin: Int,
    width: LineBreakWidth,
    height: Int
}

class LineBreak extends h2d.Object {
    private var box: InvisibleBox;
    private var g:Graphics;
    private var calcWidth:() -> Int;
    private var isRemoved = false;

    private var style:LineBreakStyle = {
        color: 0x000000,
        thickness: 1,
        margin: 2,
        width: BindToWindow,
        height: 10
    }

    public function new(?styleArg:LineBreakStyle) {
        super();
        Styles.upsert(this.style, styleArg);
        this.box = new InvisibleBox(0, this.style.height);
        this.addChild(this.box);
        this.g = new Graphics(this);
        this.g.y = this.style.height / 2;
        this.calcWidth = getWidthFunction(style.width);
        refresh();

        switch this.style.width {
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

    private static function getWidthFunction(width:LineBreakWidth): () -> Int {
        return switch (width) {
            case BindToObject(obj):
                () -> Std.int(obj.getBounds().width);
            case BindToWindow:
                () -> hxd.Window.getInstance().width;
            case Absolute(width):
                () -> width;
            case Custom(cb):
                () -> cb().width;
        }
    }

    public function refresh():Void {
        g.clear();
        var width = calcWidth();
        g.beginFill(style.color);
        g.drawRect(x, style.margin, width, style.thickness);
        g.endFill();
    }
}

enum LineBreakWidth {
    BindToObject(obj: h2d.Object);
    BindToWindow;
    Absolute(width: Int);
    Custom(cb: () -> { width: Int });
}
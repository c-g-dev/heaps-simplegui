package heaps.simplegui.components.container;

import h2d.Object;
import ludi.commons.model.HorzVert;

using heaps.simplegui.util.Extensions;

class XFlow extends h2d.Object {
    var hasStaticDimension: Bool = false;
    var width: Int;
    var height: Int;
    var padding: Int = 0;
    var spacing: Int = 0;
    var direction: HorzVert;

    public function new(direction: HorzVert, ?opts: Array<XFlowOption>) {
        super();
        this.direction = direction;
        if (opts != null) {
            for (opt in opts) {
                setOption(opt);
            }
        }
    }

    public function setOption(option: XFlowOption): Void {
        switch (option) {
            case Padding(p):
                this.padding = p;
            case Spacing(s):
                this.spacing = s;
            case Dimensions(width, height):
                this.width = width;
                this.height = height;
                this.hasStaticDimension = true;
        }
    }

    public static function vertical(children: Array<h2d.Object>): XFlow {
        return new XFlow(HorzVert.Vertical).addChildren(children);
    }

    public static function horizontal(children: Array<h2d.Object>): XFlow {
        return new XFlow(HorzVert.Horizontal).addChildren(children);
    }

    private function addChildren(children: Array<h2d.Object>): XFlow {
        for (child in children) {
            addChild(child);
        }
        return this;
    }

    public function reflow() {
        
        var currentPos = padding;
        for (i in 0...this.children.length) {
            var obj = this.children[i];
            if (direction == HorzVert.Horizontal) {
                obj.x = currentPos;
                currentPos += Std.int(obj.getBounds().width) + spacing;
            } else {
                obj.y = currentPos;
                currentPos += Std.int(obj.getBounds().height) + spacing;
            }
        }

        for (i in 0...this.children.length) {
    
            if (!hasStaticDimension) {
                if (direction == HorzVert.Horizontal) {
                    var totalWidth = 0;
                    var maxHeight = 0;
                    for (child in children) {
                        var bounds = child.getBounds();
                        totalWidth += Std.int(bounds.width);
                        if (Std.int(bounds.height) > maxHeight) {
                            maxHeight = Std.int(bounds.height);
                        }
                    }
                    width = totalWidth + padding * 2 + spacing * (children.length - 1);
                    height = maxHeight + padding * 2;
                } else {
                    var maxWidth = 0;
                    var totalHeight = 0;
                    for (child in children) {
                        var bounds = child.getBounds();
                        totalHeight += Std.int(bounds.height);
                        if (Std.int(bounds.width) > maxWidth) {
                            maxWidth = Std.int(bounds.width);
                        }
                    }
                    width = maxWidth + padding * 2;
                    height = totalHeight + padding * 2 + spacing * (children.length - 1);
                }
            }
        }
    }

    public override function addChildAt(s: h2d.Object, pos: Int): Void {
        super.addChildAt(s, pos);
        reflow();
    }
}

enum XFlowOption {
    Padding(p: Int);
    Spacing(s: Int);
    Dimensions(width: Int, height: Int);
}
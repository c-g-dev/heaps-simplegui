package heaps.simplegui.components.widget;

import heaps.simplegui.components.util.DimensionBinder;

typedef BorderDef = {
    thickness: Int,
    color: BorderColorDef,
    size: BorderSize
}

enum BorderSize {
    MatchParent;
    Absolute(width: Int, height: Int);
}


enum BorderColorDef {
    Single(color: Int);
    TwoColor(upColor: Int, downColor: Int);
}

class Border extends h2d.Graphics {
    private var border:BorderDef;
    var width: Int = 0;
    var height: Int = 0;
    var binder: DimensionBinder;

    public function new(border:BorderDef) {
        super();
        this.border = border;
        switch border.size {
            case MatchParent: {
                binder = new DimensionBinder(this, BindToParentBounds(this), Custom((w, h) -> {
                    this.width = w;
                    this.height = h;
                    reflow();
                }));
            }
            case Absolute(w, h): {
                this.width = w;
                this.height = h;
                reflow();
            }
        }

    }

    public function changeSize(size: BorderSize){ 
        border.size = size;
        switch border.size {
            case MatchParent: {
                if(binder == null){
                    new DimensionBinder(this, BindToParentBounds(this), Custom((w, h) -> {
                        this.width = w;
                        this.height = h;
                        reflow();
                    }));
                }
            }
            case Absolute(w, h): {
                if(binder != null){
                    binder.remove();
                    binder = null;
                }
                this.width = w;
                this.height = h;
                reflow();
            }
        }
    }

    private function reflow(): Void {
        clear();

        switch (border.color) {
            case Single(color): {
                lineStyle(border.thickness, color);
                moveTo(0, 0);
                lineTo(this.width, 0);         
                lineTo(this.width, this.height);
                lineTo(0, this.height);        
                lineTo(0, 0);
            }
            case TwoColor(upColor, downColor):
                lineStyle(border.thickness, upColor);
                moveTo(0, 0);
                lineTo(this.width, 0);

                lineTo(0, this.height);

                lineStyle(border.thickness, downColor);
                moveTo(this.width, 0);
                lineTo(this.width, this.height);

                moveTo(0, this.height);
                lineTo(this.width, this.height);
        }

    }
}
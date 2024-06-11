package heaps.simplegui.components.container;

import h2d.Object;

class ZoomableScrollView extends h2d.Object {
    var scrollview: ScrollView;
    var zoomable: Zoomable;
    var addChildRerouteSwitch: Bool = false;

    public function new(width: Int, height: Int) {
        super();
        scrollview = new ScrollView(width, height);
        zoomable = new Zoomable(width, height);
        scrollview.addChild(zoomable);
        this.addChild(scrollview);
        this.addChildRerouteSwitch = true;
    }

    public function setZoom(level: Float) {
        zoomable.zoom = level;
        scrollview.reflow();
    }

    public function getZoom(): Float {
        return zoomable.zoom;
    }

    public function addZoom(change: Float): Void {
        zoomable.zoom += change;
        scrollview.reflow();
    }

    override function addChildAt(s: h2d.Object, pos: Int) {
        if(addChildRerouteSwitch) {
            zoomable.addContent(s);
        } else {
            super.addChildAt(s, pos);
        }
        scrollview.reflow();
    }

    public function reflow() {
        scrollview.reflow();
    }


    public function clearContent() {
        @:privateAccess zoomable.contentLayer.removeChildren();
    }
}
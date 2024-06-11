package heaps.simplegui.components.container;

import h2d.Object;
import h2d.Graphics;
import h2d.Layers;

class Zoomable extends h2d.Object {
    private var contentLayer: h2d.Layers;
    @:isVar public var zoom(default, set) : Float;

    public var width: Int;
    public var height: Int;

    public function new(width: Int, height: Int) {
        super(parent);
        contentLayer = new h2d.Layers(this);
        zoom = 1.0;
        this.width = width;
        this.height = height;
    }

    public function set_zoom(value: Float): Float {
        if (value <= 0) return zoom;
        zoom = value;
        applyZoom();
        return zoom;
    }


    private function applyZoom(): Void {
        contentLayer.setScale(zoom);
        contentLayer.setPosition(((width - width * zoom) / 2), ((height - height * zoom) / 2));
    }

    public function addContent(content: h2d.Object): Void {
        contentLayer.addChild(content);
    }
}
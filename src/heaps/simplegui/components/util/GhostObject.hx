package heaps.simplegui.components.util;

import h2d.Object;

class GhostObject extends h2d.Object {
    
    public function new(?parent: Object) {
        super(parent);
        this.visible = false;
    }

    override function set_visible(b) {
		return false;
	}
}
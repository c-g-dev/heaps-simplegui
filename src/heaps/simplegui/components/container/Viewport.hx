package heaps.simplegui.components.container;

import h2d.Object;
import h2d.Mask;
import h2d.RenderContext;

using heaps.simplegui.util.Extensions;

class Viewport extends h2d.Object {
    var width: Int;
    var height: Int;

    private var restrictBounds: Bool = true;

    public function new(width: Int, height: Int) {
        super();
        this.width = width;
        this.height = height;
    }

    override function drawRec(ctx:RenderContext) {
        Mask.maskWith(ctx, this, Math.ceil(width), Math.ceil(height), 0, 0);
        super.drawRec(ctx);
        Mask.unmask(ctx);
	}

    public function getChildrenBounds(): h2d.col.Bounds {
        restrictBounds = false;
        var out = new h2d.col.Bounds();
        if( posChanged ) {
			calcAbsPos();
			for( c in children )
				c.posChanged = true;
			posChanged = false;
		}
		var n = children.length;
		if( n == 0 ) {
			out.empty();
			return out;
		}
		if( n == 1 ) {
			var c = children[0];
			if( c.visible ) c.getBoundsRec(null, out,false) else out.empty();
			return out;
		}
		var xmin = hxd.Math.POSITIVE_INFINITY, ymin = hxd.Math.POSITIVE_INFINITY;
		var xmax = hxd.Math.NEGATIVE_INFINITY, ymax = hxd.Math.NEGATIVE_INFINITY;
		for( c in children ) {
			if( !c.visible ) continue;
			c.getBoundsRec(null, out, false);
			if( out.xMin < xmin ) xmin = out.xMin;
			if( out.yMin < ymin ) ymin = out.yMin;
			if( out.xMax > xmax ) xmax = out.xMax;
			if( out.yMax > ymax ) ymax = out.yMax;
		}
		out.xMin = xmin;
		out.yMin = ymin;
		out.xMax = xmax;
		out.yMax = ymax;
        restrictBounds = true;
        return out;
    }

    override function getBoundsRec( relativeTo : Object, out : h2d.col.Bounds, forSize : Bool ) : Void {
		super.getBoundsRec(relativeTo, out, forSize);
        if(restrictBounds){
            out.restrictSize(this.width, this.height);
        }
    }
}
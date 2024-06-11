package heaps.simplegui.util;

class Extensions {
    
    public static function restrictSize(bounds: h2d.col.Bounds, width: Int, height: Int) {
        if (bounds.width > width) {
            bounds.xMax = bounds.xMin + width;
        }
        
        if (bounds.height > height) {
            bounds.yMax = bounds.yMin + height;
        }
    }

}
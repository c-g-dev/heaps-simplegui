package heaps.simplegui.util;

class GraphicsUtils {
    public static function drawRectWithLines(gfx: h2d.Graphics, x: Int, y: Int, width: Int, height: Int) {
        gfx.moveTo(x, y);
        gfx.lineTo(x + width, y);
        gfx.lineTo(x + width, y + height);  
        gfx.lineTo(x, y + height);    
        gfx.lineTo(x, y);
    }
}
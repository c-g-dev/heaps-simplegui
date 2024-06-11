package heaps.simplegui.components.action;

import heaps.simplegui.util.HeapsUtil;
import ludi.commons.util.Styles;
import h2d.Object;
import h2d.Tile;
import h2d.Bitmap;
import h2d.Interactive;

class MoveDrag extends h2d.Object {
    var interactive: Interactive;

    var isDragging: Bool;
    var currentDragX: Int;
    var currentDragY: Int;
    var currentAbsX: Int;
    var currentAbsY: Int;

    public var dropValue: DropValue = null;

    public var config = {
        autowireToInteractive: true
    }

    public function new(interactive: Interactive, ?newConfig: Dynamic) {
        super();
        Styles.upsert(config, newConfig);
        this.interactive = interactive;
        if(config.autowireToInteractive){
            this.interactive.onPush = (_) -> {
                startDrag();
            }
            this.interactive.onRelease = (_) -> {
                stopDrag();
            }
        }
    }

    public function startDrag(): Void {
        isDragging = true;
        currentDragX = Std.int(this.parent.getAbsPos().x);
        currentDragY = Std.int(this.parent.getAbsPos().y);
        currentAbsX = Std.int(this.parent.getAbsPos().x);
        currentAbsY = Std.int(this.parent.getAbsPos().y);
        interactive.startCapture((e) -> {
            this.currentDragX += Std.int(e.relX) - currentDragX;
            this.currentDragY += Std.int(e.relY) - currentDragY;
            this.currentAbsX  = Std.int(e.relX) + Std.int(this.parent.getAbsPos().x);
            this.currentAbsY  = Std.int(e.relY) + Std.int(this.parent.getAbsPos().y);
            this.parent.x += Std.int(e.relX);
            this.parent.y += Std.int(e.relY);
        }, () -> {
            if(dropValue != null){
                DropZones.drop(currentAbsX, currentAbsY, dropValue);
            }
        });
    }

    public function stopDrag(): Void {
        isDragging = false;
        interactive.stopCapture();
    }
}

class ShadowDrag extends h2d.Object {
    var interactive: Interactive;

    var isDragging: Bool;
    var currentDragX: Int;
    var currentDragY: Int;

    public var dropValue: DropValue = null;

    public var config = {
        autowireToInteractive: true
    }

    public function new(interactive: Interactive, ?newConfig: Dynamic) {
        super();
        Styles.upsert(config, newConfig);
        this.interactive = interactive;
        if(config.autowireToInteractive){
            this.interactive.onPush = (_) -> {
                startDrag();
            }
            this.interactive.onRelease = (_) -> {
                stopDrag();
            }
        }
    }

   var currentAbsX: Int;
    var currentAbsY: Int;
    public function startDrag(): Void {
        isDragging = true;
        currentDragX = Std.int(this.parent.getAbsPos().x);
        currentDragY = Std.int(this.parent.getAbsPos().y);
        currentAbsX = Std.int(this.parent.getAbsPos().x);
        currentAbsY = Std.int(this.parent.getAbsPos().y);
        var bmp = captureParentTexture();
        bmp.alpha = 0.5;
        interactive.startCapture((e) -> {
            this.currentDragX += Std.int(e.relX) - currentDragX ;
            this.currentDragY += Std.int(e.relY) - currentDragY;
            this.currentAbsX  = Std.int(e.relX) + Std.int(this.parent.getAbsPos().x);
            this.currentAbsY  = Std.int(e.relY) + Std.int(this.parent.getAbsPos().y);
            bmp.x = this.currentAbsX;
            bmp.y = this.currentAbsY;
        }, () -> {
            bmp.remove();
            if(dropValue != null){
                DropZones.drop(currentAbsX, currentAbsY, dropValue);
            }
        });
    }

    public function stopDrag(): Void {
        isDragging = false;
        interactive.stopCapture();
    }

    public function captureParentTexture(): Bitmap {        
        var bmp = new Bitmap(HeapsUtil.objectToTile(this.parent));

        this.parent.getScene().addChild(bmp);
        
        bmp.x = this.parent.getAbsPos().x;
        bmp.y = this.parent.getAbsPos().y;

        return bmp;
    }



}

typedef DropValue = {
    type: String,
    val: Dynamic
};

class DropZones {
    public static var registry: Array<DropZone> = new Array<DropZone>();
    
    public static function register(dropZone: DropZone) {
        registry.push(dropZone);
    }
    
    public static function unregister(dropZone: DropZone) {
        registry.remove(dropZone);
    }

    public static function drop(x: Int, y: Int, dropValue: DropValue){
        for (dropZone in registry) {
            var abPos = dropZone.getAbsPos();
            if (dropZone.containsPoint(x, y)) {
                dropZone.onDrop(dropValue, x, y);
            }
        }
    }
}

class DropZone extends h2d.Object {
    public var width: Float;
    public var height: Float;

    public function new(width: Float, height: Float) {
        super();
        this.width = width;
        this.height = height;
        DropZones.register(this);
    }
    
    public function containsPoint(x: Int, y: Int): Bool {
        var abPos = this.getAbsPos();
        return x >= abPos.x && x <= abPos.x + this.width && y >= abPos.y && y <= abPos.y + this.height;
    }

    public dynamic function onDrop(dropValue: DropValue, dropX: Int, dropY: Int) {}
    
    override public function onRemove() {
        super.onRemove();
        DropZones.unregister(this);
    }
}
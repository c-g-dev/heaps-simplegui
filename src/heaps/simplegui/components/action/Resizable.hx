package heaps.simplegui.components.action;

import heaps.simplegui.components.widget.XPBox;
import h2d.col.Bounds;
import h2d.Interactive;

class Resizable extends h2d.Object {
    public static final ALL_AREAS = [
        TopLeftCorner,
        TopRightCorner,
        BottomLeftCorner,
        BottomRightCorner,
        LeftEdge,
        RightEdge,
        TopEdge,
        BottomEdge,
    ];

    var interactableAreas: Array<ResizeArea>;
    var startX: Float;
    var startY: Float;
    var startWidth: Float;
    var startHeight: Float;
    var resizingArea: ResizeArea;
    var interactiveObj: h2d.Interactive;
    var width: Int;
    var height: Int;
    var xp: XPBox;

    public function new(width: Int, height: Int, interactableAreas: Array<ResizeArea>) {
        super();
        this.width = width;
        this.height = height;
        this.interactableAreas = interactableAreas;
        this.xp = new XPBox(width, height);
        this.addChild(this.xp);
        this.initInteractive();
    }

    private function initInteractive(): Void {
        interactiveObj = new h2d.Interactive(width, height);
        interactiveObj.onPush = this.startResize;
        interactiveObj.onRelease = this.stopResize;
        interactiveObj.onMove = this.handleResize;
        this.addChild(interactiveObj);
    }

    private function startResize(e: hxd.Event): Void {
        startX = e.relX + this.x;
        startY = e.relY + this.y;
        startWidth = this.width;
        startHeight = this.height;

        for (area in interactableAreas) {
            if (isInResizeArea(e.relX, e.relY, area)) {
                resizingArea = area;
                attachInteractiveToScene();
                break;
            }
        }
    }

    private function attachInteractiveToScene() {
        this.getScene().addChild(this.interactiveObj);
        this.interactiveObj.width = this.getScene().width;
        this.interactiveObj.height = this.getScene().height;
    }

    private function detachInteractiveToScene() {
        this.addChild(this.interactiveObj);
        this.interactiveObj.width = this.width;
        this.interactiveObj.height = this.height;
    }

    private function stopResize(e: hxd.Event): Void {
        resizingArea = null;
        detachInteractiveToScene();
    }

    private function handleResize(e: hxd.Event): Void {
        if (resizingArea == null) {
            for (area in interactableAreas) {
                if (isInResizeArea(e.relX, e.relY, area)) {
                    hxd.System.setCursor(Move);
                    return;
                }
            }
            hxd.System.setCursor(Default);
            return;
        }

        var dx = e.relX - startX;
        var dy = e.relY - startY;

        var newBounds = Bounds.fromValues(this.x, this.y, startWidth, startHeight);
        switch (resizingArea) {
            case LeftEdge:
                if (startWidth - dx > 5) {
                    newBounds.x = startX + dx;
                    newBounds.width -= dx;
                }
                else {
                    newBounds.x = startX + 5;
                    newBounds.width = 5;
                }
            case RightEdge:
                if (startWidth + dx > 5) {
                    newBounds.width += dx;
                }
                else {
                    newBounds.width = 5;
                }
            case TopEdge:
                if (startHeight - dy > 5) {
                    newBounds.y = startY + dy;
                    newBounds.height -= dy;
                }
                else {
                    newBounds.y = startY + 5;
                    newBounds.height = 5;
                }
            case BottomEdge:
                if (startHeight + dy > 5) {
                    newBounds.height += dy;
                }
                else {
                    newBounds.height = 5;
                }
            case TopLeftCorner:
                if (startWidth - dx > 5 && startHeight - dy > 5) {
                    newBounds.x = startX + dx;
                    newBounds.y = startY + dy;
                    newBounds.width -= dx;
                    newBounds.height -= dy;
                }
                else {
                    if(startWidth - dx <= 5){
                        newBounds.x = startX + 5;
                        newBounds.width = 5;
                    }
                    if(startHeight - dy <= 5){
                        newBounds.y = startY + 5;
                        newBounds.height = 5;
                    }
                }
            case TopRightCorner:
                if (startWidth + dx > 5 && startHeight - dy > 5) {
                    newBounds.y = startY + dy;
                    newBounds.width += dx;
                    newBounds.height -= dy;
                }
                else {
                    if(startWidth + dx <= 5){
                        newBounds.width = 5;
                    }
                    if(startHeight - dy < 5){
                        newBounds.y = startY + 5;
                        newBounds.height = 5;
                    }
                }
            case BottomLeftCorner:
                if (startWidth - dx > 5 && startHeight + dy > 5) {
                    newBounds.x = startX + dx;
                    newBounds.width -= dx;
                    newBounds.height += dy;
                }
                else {
                    if(startWidth - dx < 5){
                        newBounds.x = startX + 5;
                        newBounds.width = 5;
                    }
                    if(startHeight + dy < 5){
                        newBounds.height = 5;
                    }
                }
            case BottomRightCorner:
                if (startWidth + dx > 5 && startHeight + dy > 5) {
                    newBounds.width += dx;
                    newBounds.height += dy;
                }
                else {
                    if(startWidth + dx < 5) {
                        newBounds.width = 5;
                    }
                    if(startHeight + dy < 5) {
                        newBounds.height = 5;
                    }
                }
        }

        this.setNewBounds_internal(newBounds);
        this.x = newBounds.x;
        this.y = newBounds.y;
        this.width = Std.int(newBounds.width);
        this.height = Std.int(newBounds.height);
    }

    private function isInResizeArea(x: Float, y: Float, area: ResizeArea): Bool {
        x += this.x;
        y += this.y;
        switch(area) {
            case TopLeftCorner:
                return isInResizeArea(x - this.x, y - this.y, LeftEdge) && isInResizeArea(x - this.x, y - this.y, TopEdge);
            case TopRightCorner:
                return isInResizeArea(x - this.x, y - this.y, RightEdge) && isInResizeArea(x - this.x, y - this.y, TopEdge);
            case BottomLeftCorner:
                return isInResizeArea(x - this.x, y - this.y, LeftEdge) && isInResizeArea(x - this.x, y - this.y, BottomEdge);
            case BottomRightCorner:
                return isInResizeArea(x - this.x, y - this.y, RightEdge) && isInResizeArea(x - this.x, y - this.y, BottomEdge);
            case LeftEdge:
                return x >= this.x - 5 && x <= this.x + 5;
            case RightEdge:
                return x >= this.x + this.width - 5 && x <= this.x + this.width + 5;
            case TopEdge:
                return y >= this.y - 5 && y <= this.y + 5;
            case BottomEdge:
                return y >= this.y + this.height - 5 && y <= this.y + this.height + 5;
        }
        return false;
    }

    private function setNewBounds_internal(newBounds: Bounds): Void {
        this.x = Std.int(newBounds.x);
        this.y = Std.int(newBounds.y);
        this.width = Std.int(newBounds.width);
        this.height = Std.int(newBounds.height);
        this.xp.setSize(this.width, this.height);
        setNewBounds(newBounds);
    }

    public dynamic function setNewBounds(newBounds: Bounds): Void {

    }
}

enum ResizeArea {
    LeftEdge;
    RightEdge;
    TopEdge;
    BottomEdge;
    TopLeftCorner;
    TopRightCorner;
    BottomLeftCorner;
    BottomRightCorner;
}



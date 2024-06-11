package heaps.simplegui.components.container;

import h2d.col.Bounds;
import heaps.simplegui.util.LayoutTools.obj;
import hxd.Window;
import h2d.Mask;
import h2d.RenderContext;
import heaps.simplegui.util.LayoutTools.attach;
import h2d.Interactive;
import hxd.Event;
import h2d.Object;
import h2d.Graphics;

using heaps.simplegui.util.Extensions;

class ScrollView extends Viewport {
    public var scrollableContent: h2d.Object;

    var calcHeight: Int;
    var calcWidth: Int;

    var curScrollX: Int;
    var curScrollY: Int;

    var hasLoaded: Bool = false;
    var addChildRerouteSwitch: Bool = false;


    public var layout = {
        scrollableContent: obj(h2d.Object),
        horizontalScroll: obj(HorizontalScrollBar),
        verticalScroll: obj(VerticalScrollBar)
    };

    public function new(width: Int, height: Int) {
        super(width, height);

        attach(this, layout);
        this.hasLoaded = true;

        this.scrollableContent = layout.scrollableContent.obj;
        this.addChildAt(this.scrollableContent, 0);

        addChildRerouteSwitch = true;

        layout.horizontalScroll.obj.onScrollProgressUpdate = (perc, delta) -> {
            curScrollX = Std.int(layout.horizontalScroll.obj.width  * perc);
            this.scrollableContent.x = -1 * Std.int((this.calcWidth - this.width) * perc);
        }

        layout.verticalScroll.obj.onScrollProgressUpdate = (perc, delta) -> {
            curScrollY = Std.int(layout.verticalScroll.obj.height * perc);
            this.scrollableContent.y = -1 * Std.int((this.calcHeight - this.height) * perc);
        }
    }

    public function reflow(){
       
        if(scrollableContent != null){
            var childrenBounds = scrollableContent.getBounds();
            calcWidth = Std.int(childrenBounds.width);
            calcHeight = Std.int(childrenBounds.height);
    
            layout.horizontalScroll.obj.width = this.width - 10;
            layout.verticalScroll.obj.height = this.height - 10;
            layout.horizontalScroll.obj.updateRender();
            layout.verticalScroll.obj.updateRender();
    
            layout.verticalScroll.obj.x = this.width - 10;
            layout.horizontalScroll.obj.y = this.height - 10;
    
            layout.horizontalScroll.obj.visible = (childrenBounds.width > width);
            layout.verticalScroll.obj.visible = (childrenBounds.height > height);
        }
        
       
    }

    public function addOutsideContent( s: h2d.Object, above: Bool ) {
        addChildRerouteSwitch = false;
        if(above){
            this.addChild(s);
        }
        else {
            this.addChildAt(s, 0);
        }
        addChildRerouteSwitch = true;
	}

    override function addChildAt( s: h2d.Object, pos: Int ) {
        if(addChildRerouteSwitch){
            this.scrollableContent.addChild(s);
        }
        else{
            super.addChildAt(s, pos);
        }
        reflow();
	}
}


/*
    There is an issue here, where, if you leave the window while moving the scoll cursor, and come back, the Move event will fire before the Release event
    which causes 1 frame of movement on the scroll.

    One possible avenue is to listen to Window.addEventTarget for Out, which will fire when the mouse leaves the window. However, this introduces another problem
    where the scroll cursor will always release when leaving the screen, which in practice is unsatisfying UX. We need to be able to determine if the mouse is down
    agnostic of window events. But this seems to be impossible, as all mouse info is read as events from SDL/DX/etc, and immediately funneled through the event listeners.
    So there is no way to tell if we have "released" before we have "moved".

    Two other possible avenues:
    1) find a harmless way to change the baked in event read order. I assume this requires  gutting the Window class, which is probably impractical
    2) gather all events in a frame and then sort them before resolution ""at the end of the frame"". While Timer.delay(0) will execute logic next frame,
    I think you would need to mess with the application loop (not even the scene loop) to execute "at the end of the frame". I know that this can be
    done non-invasively, (i.e. not requiring editing or replacing the class), through some kind of reflection, as I have done it with my coroutine library.
    But the implications of adding a "at the end of the frame" listener would need some careful thought.

    so as this is a small issue I will leave it for now
*/


class VerticalScrollBar extends h2d.Object {
    public var height: Int;

    public var layout = {
        interactive: obj(h2d.Interactive),
        background: obj(h2d.Object),
        cursor: obj(h2d.Object)
    };

    public function new(height: Int, ?parent: Object) {
        super(parent);
        this.height = height;
        attach(this, layout);
        layout.background.obj = handleDrawing(RenderBarBackground);
        layout.cursor.obj = handleDrawing(DrawCursor);
        this.addChild(layout.background.obj);
        this.addChild(layout.cursor.obj);
        layout.interactive.obj.cursor = Button;
        layout.interactive.obj.onPush = function(e) {
            var scene = getScene();
            if (scene == null) return;

            /* see comment above*/

            scene.startCapture(function(e) {
                switch (e.kind) {
                    case EventKind.ERelease, EventKind.EReleaseOutside:
                        scene.stopCapture();
                    case EventKind.EPush, EventKind.EMove:
                        setCursorPosition(e);
                    default:
                }
                e.propagate = false;
            });
            setCursorPosition(e);
        };

        updateRender();
    }

    function setCursorPosition(e: Event) {
        var newY = e.relY - (20 / 2);
        newY = Math.max(0, Math.min(height - 20, newY));
        var oldPerc = layout.cursor.obj.y / (this.height - 20);
        layout.cursor.obj.y = newY;
        var newPerc = layout.cursor.obj.y / (this.height - 20);
        onScrollProgressUpdate(newPerc, newPerc - oldPerc);
    }

    public function updateRender() {
        layout.interactive.obj.width = 10;
        layout.interactive.obj.height = height;

        handleDrawing(UpdateBarBackgroundSpan(height));
    }

    public dynamic function onScrollProgressUpdate(perc: Float, delta: Float): Void {}

    public dynamic function handleDrawing<T>(draw: ScrollbarDrawing<T>): T {
        switch draw {
            case RenderBarBackground: {
                var gfx = new h2d.Graphics();
                gfx.beginFill(0xC90707);
                gfx.drawRect(0, 0, 10, this.height);
                gfx.endFill();
                gfx.alpha = 0.5;
                return gfx;
            }
            case UpdateBarBackgroundSpan(span): {
                var gfx = (cast layout.background.obj: h2d.Graphics);
                gfx.clear();
                gfx.beginFill(0xC90707);
                gfx.drawRect(0, 0, 10, span);
                gfx.endFill();
                return;
            }
            case DrawCursor: {
                var gfx = new h2d.Graphics();
                gfx.beginFill(0xCCC3C3);
                gfx.drawRect(0, 0, 10, 20); 
                gfx.endFill(); 
                return gfx;
            }
        }
    }
}

class HorizontalScrollBar extends h2d.Object {
    public var width: Int;

    public var layout = {
        interactive: obj(h2d.Interactive),
        background: obj(h2d.Object),
        cursor: obj(h2d.Object)
    };

    public function new(width: Int, ?parent: Object) {
        super(parent);
        this.width = width;
        attach(this, layout);
        layout.background.obj = handleDrawing(RenderBarBackground);
        layout.cursor.obj = handleDrawing(DrawCursor);
        this.addChild(layout.background.obj);
        this.addChild(layout.cursor.obj);
        layout.interactive.obj.cursor = Button;
        layout.interactive.obj.onPush = function(e) {
            var scene = getScene();
            if (scene == null) return;

            /* see comment above*/

            scene.startCapture(function(e) {
                switch (e.kind) {
                    case EventKind.ERelease, EventKind.EReleaseOutside:
                        scene.stopCapture();
                    case EventKind.EPush, EventKind.EMove:
                        setCursorPosition(e);
                    default:
                }
                e.propagate = false;
            });
            setCursorPosition(e);
        };

        updateRender();
    }

    function setCursorPosition(e: Event) {
        var newX = e.relX - (20 / 2);
        newX = Math.max(0, Math.min(width - 20, newX));
        var oldPerc = layout.cursor.obj.x / (this.width - 20);
        layout.cursor.obj.x = newX;
        var newPerc = layout.cursor.obj.x / (this.width - 20);
        onScrollProgressUpdate(newPerc, newPerc - oldPerc);
    }

    public function updateRender() {
        layout.interactive.obj.width = width;
        layout.interactive.obj.height = 10;

        handleDrawing(UpdateBarBackgroundSpan(width));
    }

    public dynamic function onScrollProgressUpdate(perc: Float, delta: Float): Void {}

    public dynamic function handleDrawing<T>(draw: ScrollbarDrawing<T>): T {
        switch draw {
            case RenderBarBackground: {
                var gfx = new h2d.Graphics();
                return gfx;
            }
            case UpdateBarBackgroundSpan(span): {
                var gfx = (cast layout.background.obj: h2d.Graphics);
                gfx.beginFill(0xC90707);
                gfx.drawRect(0, 0, span, 10);
                gfx.endFill();
                gfx.alpha = 0.5;
                return;
            }
            case DrawCursor: {
                var gfx = new h2d.Graphics();
                gfx.beginFill(0xCCC3C3);
                gfx.drawRect(0, 0, 20, 10); 
                gfx.endFill(); 
                return gfx;
            }
        }
    }

}

enum ScrollbarDrawing<T> {
    RenderBarBackground: ScrollbarDrawing<h2d.Object>;
    UpdateBarBackgroundSpan(span: Int): ScrollbarDrawing<Void>;
    DrawCursor: ScrollbarDrawing<h2d.Object>;
}
package heaps.simplegui.util;

import hxd.Timer;

class DoubleClickListener<T> {
    private var onSingleClick: T -> Void;
    private var onDoubleClick: T -> Void;
    private var lastClickTime: Float = 0;
    private var clickCount: Int = 0;
    private var doubleClickThreshold: Float = 0.2;

    public function new(onSingleClick: T -> Void, onDoubleClick: T -> Void) {
        this.onSingleClick = onSingleClick;
        this.onDoubleClick = onDoubleClick;
    }

    public function consumeClick(arg: T): Void {
        var currentTime = Timer.lastTimeStamp;
        if (currentTime - lastClickTime < doubleClickThreshold) {
            clickCount++;
        } else {
            clickCount = 1;
        }

        lastClickTime = currentTime;

        if (clickCount == 2) {
            onDoubleClick(arg);
            clickCount = 0;
        } else {
            haxe.Timer.delay(function() {
                if (clickCount == 1) {
                    onSingleClick(arg);
                }
                clickCount = 0;
            }, Std.int(doubleClickThreshold * 1000));
        }
    }
}
package heaps.simplegui.util;

import ludi.commons.collections.Set;
import hxd.Window;
import hxd.Event;
import hxd.Key;

typedef ChordCallback = Void -> Void;

class ChordListener {
    private var chords:Map<String, {keys:Array<Int>, callback:ChordCallback}>;
    private var keysDown:Set<Int>;

    public function new() {
        chords = new Map();
        keysDown = new Set();

        Window.getInstance().addEventTarget(onEvent);
    }

    public function addChord(name:String, keys:Array<Int>, callback:ChordCallback):Void {
        chords.set(name, {keys: keys, callback: callback});
    }

    public function removeChord(name:String):Void {
        chords.remove(name);
    }

    public function dispose():Void {
        Window.getInstance().removeEventTarget(onEvent);
    }

    private function onEvent(event:Event):Void {
        switch(event.kind) {
            case EKeyDown:
                keysDown.push(event.keyCode);
                checkChords();
            case EKeyUp:
                keysDown._data.remove(event.keyCode);
            case _:
        }
    }

    private function checkChords():Void {
        for (key => chord in chords) {
            var name = key;
            var keys = chord.keys;
            var callback = chord.callback;

            var allKeysDown = true;
            for (key in keys) {
                if (!keysDown.exists(key)) {
                    allKeysDown = false;
                    break;
                }
            }

            if (allKeysDown) {
                callback();
            }
        }
    }
}
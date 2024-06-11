package heaps.simplegui.util;


import heaps.simplegui.components.widget.ImageButton;
import heaps.simplegui.components.widget.XPBox;
import heaps.simplegui.components.control.ListDropdown;
import heaps.simplegui.components.widget.Button;
import h2d.Object;
import haxe.ds.Option;
import ludi.commons.collections.Stack;

class Make {


    private static var options: Stack<Option<{
        x: Int,
        y: Int
    }>> = new Stack();
    private static var tempOptions: Option<{
        x: Int,
        y: Int
    }> = None;

    public static final text: TextMake = new TextMake();
    public static final box: BoxMake = new BoxMake();
    public static var controls: ControlMake = new ControlMake();

    public static function atPosition(x: Int, y: Int): MakeAccess {
        tempOptions = Some({
            x: x, y: y
        });
        return new MakeAccess();
    }

    private static function handleOptions(o: Object): Void {
        switch options.peek() {
            case Some(v): {
                o.x = v.x;
                o.y = v.y;
            }
            case None:
        }
    }
    
    private static function enrich<T: h2d.Object>(cb: Void -> T): T {
        options.push(tempOptions);
        tempOptions = None;
        var o = cb();
        handleOptions(o);
        options.pop();
        return o;
    }
}

class MakeAccess {
    public function new() {}
    public final text = Make.text;
    public final box = Make.box;
    public final controls = Make.controls;
}

class ControlMake {
    public function new() {}

    public function dropdown(width: Int, values:Array<String>): ListDropdown {
        @:privateAccess return Make.enrich(() -> {
            var d = new ListDropdown(Make.text.black(values[0]), width);
            for (s in values) {
                d.addItem(Make.text.black(s));
            }
            return d;
        }); 
    }

    public function button(label: String, onClick:Void -> Void): Button {
        @:privateAccess return Make.enrich(() -> {
            var b = new Button(label);
            b.onClick = onClick;
            return b;
        }); 
    }

    public function imageButton(tile: h2d.Tile, onClick:Void -> Void): ImageButton {
        @:privateAccess return Make.enrich(() -> {
            var b = new ImageButton(tile);
            b.onClick = onClick;
            return b;
        }); 
    }
}

class TextMake {
    public function new() {}

    public function black(value: String): h2d.Text {
        @:privateAccess return Make.enrich(() -> {
            var text = new h2d.Text(hxd.res.DefaultFont.get());
            text.text = value;
            text.textColor = 0x000000;
            return text;
        });
    }

    public function white(value: String): h2d.Text {
        @:privateAccess return Make.enrich(() -> {
            var text = new h2d.Text(hxd.res.DefaultFont.get());
            text.text = value;
            text.textColor = 0xFFFFFF;
            return text;
        });
    }
    
}

class BoxMake {
    public function new() {}
    public function xp(w: Int, h: Int): XPBox {
        @:privateAccess return Make.enrich(() -> {
            var box = new XPBox(w, h);
            return box;
        });   
    }

}
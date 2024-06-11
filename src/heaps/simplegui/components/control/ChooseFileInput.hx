package heaps.simplegui.components.control;

import js.html.InputElement;
import heaps.simplegui.components.widget.Button;
import haxe.crypto.Base64;
import h2d.Tile;
import haxe.io.Path;
import haxe.ds.Option;
import heaps.simplegui.util.HeapsUtil;
import h2d.Text;

using StringTools;

class ChooseFileInput extends h2d.Object {
    public var button:Button;
    public var label:Text;
    public var chosenPath:String;
    var maxWidth: Int;
    var allottedTextWidth: Int;

    public function new(maxWidth: Int) {
        super();
        
        this.maxWidth = maxWidth;

        button = new Button("Choose File");
        button.onClick = onChooseFile;

        label = HeapsUtil.text("No file chosen");
        label.setPosition(button.getBounds().width + 5, 3);
        
        this.allottedTextWidth = Std.int(Math.max(maxWidth - (button.getBounds().width + 5), 0));

        this.addChild(button);
        this.addChild(label);
    }

    public function getChosenFileRef(): Option<FileRef> {
        if(label.text != "No file chosen"){
            return Some(new FileRef(chosenPath));
        }
        return None;
    }

    public function setValue(path: String) {
        chosenPath = path;
        label.text = Path.withoutDirectory(path);
        HeapsUtil.elipsizeText(this.allottedTextWidth, label);
    }

    function onChooseFile() {
        #if hl
            var file = hl.UI.loadFile({});
            if (file != null) {
                chosenPath = file;
                label.text = Path.withoutDirectory(file);
            } else {
                label.text = "No file chosen";
            }
        #end
        
        #if js
            var input: InputElement = cast js.Browser.document.createElement("input");
            input.type = "file";
            input.onchange = function(event) {
                if (input.files.length > 0) {
                    label.text = input.files[0].name;
                    chosenPath = label.text;
                } else {
                    label.text = "No file chosen";
                }
            };
            input.click();
        #end
        HeapsUtil.elipsizeText(this.allottedTextWidth, label);
    }
}

class FileRef {
    public var path:String;

    public function new(path:String) {
        this.path = path;
    }

    public function hasExtension(exts:Array<String>):Bool {
        for (ext in exts) {
            if (path.toLowerCase().endsWith("." + ext.toLowerCase())) {
                return true;
            }
        }
        return false;
    }

    public function readBase64():String {
        var bytes = hxd.File.getBytes(path);
        return Base64.encode(bytes);
    }

    public function readTile():h2d.Tile {
        var bytes = hxd.File.getBytes(path);
        return hxd.res.Any.fromBytes(path, bytes).toTile();
    }
}
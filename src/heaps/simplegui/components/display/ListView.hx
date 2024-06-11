package heaps.simplegui.components.display;

import heaps.simplegui.components.action.DragDrop.ShadowDrag;
import ludi.commons.util.UUID;
import ludi.commons.util.Styles;
import ludi.commons.messaging.Topic;
import heaps.simplegui.components.action.DragDrop.DropZone;

import h2d.Text;
import h2d.Object;
import h2d.Interactive;
import hxd.res.DefaultFont;

class ListView extends h2d.Object {
    public var displayValues:Array<DisplayValue> = [];
    public var itemContainer:h2d.Object;
    public var styles = { textColor: 0x000000 };
    var uuid: String;
    var dropZone: DropZone;
    public var topic: Topic<ListViewEvent>;

    public function new(?config: Dynamic = null) {
        super();
        this.uuid = UUID.generate();
        this.topic = new Topic<ListViewEvent>();
        Styles.upsert(styles, config);
        this.dropZone = new DropZone(0, 0);
        this.dropZone.onDrop = (dv, x, y) -> {
            if(dv.type == "ListView_" + this.uuid){
                var thisY = y - this.y;
                if(Math.abs((itemContainer.children[dv.val].y - (y - this.absY))) >= 15){
                    var idx = this.getIndexAtY(y) - 1;
                    this.changePlace(dv.val, idx);
                }
            }
        }
        this.itemContainer = new Object();
        this.addChild(dropZone);
        this.addChild(itemContainer);
        redrawList();
    }

    public function addItem(display: String, value: Dynamic) {
        displayValues.push({display: display, val: value});
        redrawList();
    }

    public function redrawList() {
        while (itemContainer.numChildren > 0) {
            itemContainer.removeChild(itemContainer.children[0]);
        }

        var yPos = 0;
        for (i in 0...displayValues.length) {
            var listItem = new h2d.Object();
            listItem.name = "listItem_" + i;

            var index = i;

            var removeButton = new Text(DefaultFont.get());
            removeButton.text = "[-]";

            var removeBtnI = new Interactive(removeButton.calcTextWidth(removeButton.text), removeButton.textHeight);
            removeButton.addChild(removeBtnI);
            removeBtnI.onClick = function(_) {
                displayValues.splice(index, 1);
                redrawList();
            };
            listItem.addChild(removeButton);

            var text = new Text(DefaultFont.get());
            text.text = displayValues[i].display;
            text.textColor = styles.textColor;
            text.x = text.calcTextWidth(removeButton.text) + 5;
            listItem.addChild(text);

            listItem.y = yPos;
            itemContainer.addChild(listItem);

            var interactive = new Interactive(text.getBounds().width, text.getBounds().height);
            text.addChild(interactive);
            interactive.onClick = (e) -> {
                this.topic.notify(Clicked(displayValues[i]));
            }

            var drag = new ShadowDrag(interactive);
            drag.dropValue = {val: i, type: "ListView_" + this.uuid};
            text.addChild(drag);

            yPos += Std.int(Math.max(text.textHeight, removeButton.textHeight) + 5);
        }
        this.dropZone.width = this.getBounds().width;
        this.dropZone.height = this.getBounds().height;
    }

    public function changePlace(currentIdx: Int, newIdx: Int) {
        if (currentIdx < 0 || currentIdx >= displayValues.length || newIdx < 0 || newIdx > displayValues.length) {
            return;
        }
        
        var item = displayValues.splice(currentIdx, 1)[0];
        displayValues.insert(newIdx, item);
        
        redrawList();
    }

    public function getIndexAtY(yCoord: Float): Int {
        var accumY = 0;
        for (i in 0...itemContainer.numChildren) {
            var child = itemContainer.getChildAt(i);
            accumY += Std.int(child.getBounds().height + 5);
            if (yCoord < accumY) {
                return Std.parseInt(child.name.split('_')[1]) - 1;
            }
        }
        return itemContainer.children.length;
    }

}

enum ListViewEvent {
    Clicked(dv: DisplayValue);
}

typedef DisplayValue = {
    display: String,
    val: Dynamic
}
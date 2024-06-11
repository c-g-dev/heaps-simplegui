package heaps.simplegui.components.widget;

import heaps.simplegui.components.display.ListView;
import h2d.Flow.FlowOverflow;
import h2d.Flow.FlowLayout;
import heaps.simplegui.components.action.DragDrop.DropValue;

class DroppableListPanel extends h2d.Object {
    public var panel: Panel;
    public var listView: ListView;

    public function new(width: Int, height: Int, title: String) {
        super();

        panel = new Panel(width, height, {
            header: true,
            headerTitle: title,
            dropzone: true,
            onDrop: (dv, x, y) -> { this.onDrop(dv, x, y); },
        });
        panel.content.layout = FlowLayout.Vertical;
        addChild(panel);
        
        listView = new ListView();
        panel.content.addChild(listView);
    }

    public dynamic function onDrop(dv: DropValue, x: Int, y: Int): Void {}

    public function clear() {
        listView.displayValues = [];
        listView.redrawList();
    }

    public function addItem(display: String, val: Dynamic) { 
        listView.addItem(display, val); 
        
        panel.resize();
        panel.content.contentChanged(listView);
        panel.content.reflow();
    }

    public function getItems<T>(t: Class<T>): Array<T> {
        return (cast (
            [
                for (dv in listView.displayValues) {
                    dv.val;
                }   
            ]
        ): Array<T>);
    }
    
}
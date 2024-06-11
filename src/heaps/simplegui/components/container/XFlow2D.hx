package heaps.simplegui.components.container;

import ludi.commons.model.HorzVert;
import heaps.simplegui.components.container.XFlow.XFlowOption;
import heaps.simplegui.components.util.InvisibleBox;
import h2d.Object;

class XFlow2D extends h2d.Object {

    public function new(elements: Array<XFlow2DElement>) {
        super();
        var vFlow = new XFlow(HorzVert.Vertical);
        
        for (element in elements) {
            switch (element) {
                case Padding(i): {
                    var paddingBox = new InvisibleBox(0, i);
                    vFlow.addChild(paddingBox);
                }
                case Row(items, options): {
                    var hFlowOptions = [];
                    for (option in options) {
                        switch (option) {
                            case Spacing(s):
                                hFlowOptions.push(XFlowOption.Spacing(s));
                            case Padding(p):
                                hFlowOptions.push(XFlowOption.Padding(p));
                        }
                    }
                    var hFlow = new XFlow(HorzVert.Horizontal, hFlowOptions);
                    for (item in items) {
                        hFlow.addChild(item);
                    }
                    vFlow.addChild(hFlow);
                }
            }
        }
        
        addChild(vFlow);
        vFlow.reflow();
    }
}

enum XFlow2DElement {
    Padding(i: Int);
    Row(items: Array<Object>, options: Array<XFlow2DElementRowOption>);
}

enum XFlow2DElementRowOption {
    Spacing(s: Int);
    Padding(p: Int);
}
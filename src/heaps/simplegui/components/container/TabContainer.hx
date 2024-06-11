package heaps.simplegui.components.container;

import heaps.simplegui.util.Make;
import ludi.commons.util.UUID;
import heaps.simplegui.components.widget.Button;
import h2d.Text;
import hxd.res.DefaultFont;
import h2d.Flow;
import h2d.Object;
import h2d.Tile;
import hxd.Res;

import h2d.Flow;
import h2d.Object;
import h2d.Interactive;
import h2d.Text;
import hxd.res.DefaultFont;
import h2d.col.Point;
import h2d.Graphics;

using ludi.commons.extensions.All;

class TabContainer extends Viewport {
    var tabs: Array<{uuid: String, tab: Button, content: h2d.Object}>;
    var tabContainer: XFlow;
    var contentContainer: h2d.Object;
    var selectedIndex: Int = -1;

    public function new(width: Int, height: Int) {
        super(width, height);
        tabs = [];
        tabContainer = new XFlow(Horizontal);
        contentContainer = new h2d.Object();
        contentContainer.y = 30;
        
        addChild(Make.box.xp(width, 30));
        addChild(tabContainer);
        addChild(Make.atPosition(0, 30).box.xp(width, height - 30));
        addChild(contentContainer);
        
    }

    public function addTab(label: String, content: h2d.Object): Void {
        var tab = new Button(label);
        var uuid = UUID.generate();
        tabs.push({uuid: uuid, tab: tab, content: content});
        contentContainer.addChild(content);
        content.visible = false;
        tabContainer.addChild(tab);
        tab.onClick = function() {
            tab.setBackgroundColor(0x5f9bcc);
            selectTab(tabs.indexOf(tabs.findByUUID(uuid)));
            for (eachTab in tabs) {
                if(eachTab.tab != tab){
                    @:privateAccess eachTab.tab.redrawBackground();
                }
            }
        }
        if (selectedIndex == -1) {
            selectTab(0);
        }
    }

    public function getTab(): String {
        @:privateAccess return tabs[selectedIndex].tab.text.text;
    }

    public function selectTab(index: Int): Void {
        if (selectedIndex != -1) {
            tabs[selectedIndex].content.visible = false;
        }
        selectedIndex = index;
        tabs[selectedIndex].content.visible = true;
    }
}
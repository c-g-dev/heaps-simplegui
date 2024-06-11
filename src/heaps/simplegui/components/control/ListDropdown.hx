package heaps.simplegui.components.control;

import heaps.feathericons.FeatherIcon;
import heaps.feathericons.FeatherIcons;
import h2d.Object;
import heaps.simplegui.util.HeapsUtil;
import h2d.Bitmap;
import ludi.commons.macro.Functions;
import h2d.Graphics;
import h2d.Tile;
import heaps.simplegui.components.enhancement.Dropdown;

typedef ListDropdownStyle = {
    backgroundColor: Int,

}

class ListDropdown extends h2d.Object {
    public var dropdown: Dropdown;
    private var selectedItem: h2d.Object;
    public var width: Int;
    private var showingDefault: Bool = true;

    public function new(defaultItem: h2d.Object, width: Int) {
        super();

        this.width = width;

        var graphics = new Graphics();
        graphics.beginFill(0xFFFFFF);
        graphics.drawRect(0, 0, width, 21);
        graphics.endFill();
        graphics.lineStyle(1, 0x000000);
        graphics.drawRect(0, 0, width, 21);

        dropdown = new Dropdown();
        dropdown.backgroundTile = Tile.fromColor(0xFFFFFF, 1, 1, 0);
        dropdown.minWidth = width;
        dropdown.paddingLeft = 0;
        dropdown.dropdownList.padding = 1;
        dropdown.dropdownList.backgroundTile = Tile.fromColor(0x000000);
        dropdown.getItemForLabeling = (idx) -> {
            @:privateAccess return (cast dropdown.getItems()[idx]: ListDropdownItem).obj;
        }

        var tileArrow = FeatherIcon.resolve(FeatherIcons.chevron_down);
        tileArrow.withOptions([LineColor(0x000000)]);
        var t = HeapsUtil.objectToTile(tileArrow.toGraphics(), {x: 0, y: 0, w: 20, h: 20});
        dropdown.tileArrow = t;
        dropdown.tileArrowOpen = t;
        
        selectedItem = defaultItem;
        selectedItem.x = 2;
        selectedItem.y = 2;
        
        addChild(graphics);
        addChild(selectedItem);
        addChild(dropdown);

        dropdown.onOverItem = (item) -> {
            var g = (cast item: ListDropdownItem).graphics;
            g.clear();
            var backgroundColor = 0x69BCDD;

            g.beginFill(backgroundColor);
            g.drawRect(0, 0, width - 2, (cast item: ListDropdownItem).height);
            g.endFill();
        }

        dropdown.onChange = (item) -> {
            if(showingDefault){
                defaultItem.remove();
            }
        }

        dropdown.onOutItem = (item) -> {
            if(item != null){
                (cast item: ListDropdownItem).resetGraphics();
            }
        }

    }

    public function addItem(obj: h2d.Object) {
        var item = new ListDropdownItem(obj, width - 2, dropdown.dropdownList.children.length);
        dropdown.addItem(item);
    }

}

class ListDropdownItem extends h2d.Object {
    public var graphics: h2d.Graphics;
    public var index: Int;
    public var width: Int;
    public var height: Int;
    public var obj: h2d.Object;

    var hasMadeSnapshot: Bool = false;
    var snapshot: Bitmap;

    public function new(obj: h2d.Object, width: Int, index: Int) {
        super();

        this.obj = obj;
        this.index = index;
        this.width = width;
        this.height = Std.int(obj.getBounds().height);

        graphics = new Graphics();
        resetGraphics();

        addChild(graphics);
        addChild(obj);
    }

    public function resetGraphics() {
        var backgroundColor = index % 2 == 0 ? 0xAAAAAA : 0xCCCCCC;
        graphics.clear();
        graphics.beginFill(backgroundColor);
        graphics.drawRect(0, 0, width, height);
        graphics.endFill();
    }
}
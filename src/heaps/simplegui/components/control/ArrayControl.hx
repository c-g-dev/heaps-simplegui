package heaps.simplegui.components.control;

import heaps.simplegui.util.GraphicsUtils;
import heaps.simplegui.util.HeapsUtil;
import heaps.simplegui.components.widget.Background;
import heaps.simplegui.components.container.XFlow;
import heaps.simplegui.components.container.ScrollView;
import h2d.Flow;
import heaps.simplegui.components.widget.Border;
import ludi.commons.messaging.Topic;
import heaps.simplegui.components.widget.Button;
import h2d.Object;
import ludi.commons.util.UUID;
import hxd.res.DefaultFont;

enum ArrayControlEvents {
	RowAdded;
	RowRemoved;
}

typedef ArrayControlStyles = {
	maxHeight:Int
}

class ArrayControl extends ScrollView {
    var cols:Array<String>;
    var addButton: Button;
    var headers: XFlow;
    var rows: Array<{uuid: String, flow: XFlow}> = [];
    var content: XFlow;
    public var events: Topic<ArrayControlEvents> = new Topic();
    

    public function new(cols: Array<String>) {
        super((cols.length * 101) + 30, 300 + 30);
        this.cols = cols;

        content = new XFlow(Vertical);
        this.addChild(content);
		content.x += 3;

        addButton = new Button("Add");
		addButton.setWidth(200);
		addButton.setPosition(1, 0);
		addButton.onClick = () -> addRow();
        content.addChild(addButton);

        headers = new XFlow(Horizontal, [Spacing(1)]);
        for (i in 0...cols.length) {
			var header = createHeader(cols[i]);
			headers.addChild(header);
		}
		headers.x += 2;
        content.addChild(headers);

        var b = new Border({
			thickness: 1,
			color: Single(0x000000),
			size: Absolute(this.width - 1, this.height - 1)
		});
        b.x += 1;
        layout.horizontalScroll.obj.y -= 1;
		addOutsideContent(b, true);

        addOutsideContent(Background.create(Color(0x85FFFFFF), BackgroundBinding.Absolute(width, height), BackgroundFill.Stretch), false);
    }

    function createHeader(text:String):h2d.Interactive {
		var header = new h2d.Interactive(100, 30);
		var headerText = new h2d.Text(DefaultFont.get());
		headerText.textColor = 0x000000;
		headerText.text = text;
		headerText.setPosition(0, 0);
		
		var bg = new h2d.Graphics(header);
		bg.beginFill(0xD4D4D4);
		bg.drawRect(0, 0, 100, 30);
		bg.endFill();
		bg.lineStyle(1, 0x000000);
		GraphicsUtils.drawRectWithLines(bg, 0, 0, 99, 29);
		
		header.addChild(headerText);

        HeapsUtil.centerInParent(headerText);

		return header;
	}

	function addRow():Void {
		var container = new XFlow(Horizontal);
		var inputs = [];

		for (i in 0...cols.length) {
			var input = new InputField(100, 30);
			container.addChild(input);
			inputs.push(input);
		}
		
		var removeButton = new Button("X");
		removeButton.setWidth(20);
		container.addChild(removeButton);
		
		content.addChild(container);
		
		var uuid = UUID.generate();
		rows.push({uuid: uuid, flow: container});
		
		removeButton.onClick = () -> {
			removeRow(uuid);
		};

		events.notify(RowAdded);

        this.reflow();
	}

    function removeRow(uuid:String):Void {
		for (i in 0...rows.length) {
			var row = rows[i];
			if (row != null && row.uuid == uuid){
				content.removeChild(row.flow);
				rows.splice(i, 1);
				content.reflow();
				break;
			}
		}
		events.notify(RowRemoved);
	}

	public function getValues(): Array<Array<String>> {
		var values = [];

		for (row in rows) {
			var rowValues = [];
			var inputs: Array<InputField> = cast row.flow.findAll((eachO) -> {
				if(eachO is InputField){
					return eachO;
				}
				return null;
			});
			for (input in inputs) {
				rowValues.push(input.textInput.text);
			}
			values.push(rowValues);
		}

		return values;
	}
}

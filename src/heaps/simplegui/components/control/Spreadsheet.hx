package heaps.simplegui.components.control;

import ludi.commons.collections.GridMap;
import heaps.simplegui.util.HeapsUtil;
import heaps.simplegui.util.GraphicsUtils;
import heaps.simplegui.components.widget.Background;
import heaps.simplegui.components.widget.Border;
import heaps.simplegui.components.container.XFlow;
import ludi.commons.messaging.Topic;
import heaps.simplegui.components.container.ScrollView;
import heaps.simplegui.components.form.Form.FormFieldValResult;
import h2d.Object;
import ludi.commons.util.UUID;
import hxd.res.DefaultFont;
import heaps.simplegui.components.widget.Button;
import heaps.simplegui.components.form.Form.FormField;

using ludi.commons.extensions.All;

enum SpreadsheetEvents {
    RowAdded;
    RowRemoved;
}

class Spreadsheet extends ScrollView {
	var cols:Array<FormField<Dynamic>>;
	var addButton:Button;
	var headers:XFlow;
	var rows:Array<{uuid:String, flow:XFlow, fields: Array<FormField<Dynamic>>}> = [];
	var content:XFlow;

	public var events:Topic<SpreadsheetEvents> = new Topic();

	public function new(cols: Array<FormField<Dynamic>>) {
        var w = cols.computeInt((c, i) -> {
            return i + c.paramType.getWidth();
        });

		super((w) + 30, 300 + 30);
		this.cols = cols;

		content = new XFlow(Vertical);
		this.addChild(content);
		content.x += 3;

		addButton = new Button("Add");
		addButton.setWidth(200);
		addButton.setPosition(0, 0);
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

	function createHeader(field:FormField<Dynamic>):h2d.Interactive {
		var header = new h2d.Interactive(100, 30);
		var headerText = new h2d.Text(DefaultFont.get());
		headerText.textColor = 0x000000;
		headerText.text = field.label;
		headerText.setPosition(0, 0);

		var bg = new h2d.Graphics(header);
		bg.beginFill(0xD4D4D4);
		bg.drawRect(0, 0, field.paramType.getWidth(), 30);
		bg.endFill();
		bg.lineStyle(1, 0x000000);
		GraphicsUtils.drawRectWithLines(bg, 0, 0, field.paramType.getWidth(), 29);

		header.addChild(headerText);

		HeapsUtil.centerInParent(headerText);

		return header;
	}

	function addRow():Void {
		var container = new XFlow(Horizontal, [Spacing(1)]);
        container.x += 1;

        var fields = [];
		for (i in 0...cols.length) {
            var newFieldObj = cols[i].clone();
            fields.push(newFieldObj);
			var control = newFieldObj.paramType.getRequestControl();
			container.addChild(control);
		}
		
		var removeButton = new Button("X");
		removeButton.setWidth(20);
		container.addChild(removeButton);
		
		content.addChild(container);

		var uuid = UUID.generate();
		rows.push({uuid: uuid, flow: container, fields: fields});
		
		removeButton.onClick = () -> {
			removeRow(uuid);
		};
        this.reflow();
	}

	function removeRow(uuid:String):Void {
		for (i in 0...rows.length) {
			var row = rows[i];
			if (row != null && row.uuid == uuid) {
				content.removeChild(row.flow);
				rows.splice(i, 1);
				content.reflow();
				break;
			}
		}
		events.notify(RowRemoved);
	}


    public function getValues(): SpreadsheetValueState {
		var values = new SpreadsheetValueState();

		for (row in rows) {
			for (eachField in row.fields) {
                values.appendToCurrentRow(eachField.paramType.getFinalValue());
            }
            values.nextRow();
		}

		return values;
	}

}

class SpreadsheetValueState {
	public var grid: GridMap<Dynamic> = new GridMap();
    var currentX = 0;
    var currentY = 0;

	public function new() {

	}

    public function appendToCurrentRow(arg:FormFieldValResult<Dynamic>) {
        switch arg {
            case Some(val): {
                grid.add(currentX, currentY, val);
                currentX++;
            }
            case None: {
                grid.add(currentX, currentY, null);
                currentX++;
            }
            case ValidationError: {
                grid.add(currentX, currentY, null);
                currentX++;
            }
        }
    }

    public function nextRow() {
        currentX = 0;
        currentY++;
    }
}

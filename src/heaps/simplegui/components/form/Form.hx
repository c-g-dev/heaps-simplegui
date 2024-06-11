package heaps.simplegui.components.form;

import h2d.Object;
import heaps.simplegui.components.container.XFlow;
import heaps.simplegui.components.control.Spreadsheet.SpreadsheetValueState;
import heaps.simplegui.components.form.types.FormField_Spreadsheet;
import heaps.simplegui.components.form.types.FormField_Array;
import heaps.simplegui.components.form.types.FormField_File;
import heaps.simplegui.components.form.types.FormField_String;
import heaps.simplegui.components.control.ChooseFileInput.FileRef;
import heaps.simplegui.components.form.types.FormField_Dropdown;
import heaps.simplegui.components.form.types.FormField_Int;
import haxe.ds.Option;

using ludi.commons.extensions.All;

class Form extends h2d.Object {
	public var controls:Array<{
		param:FormField<Dynamic>,
		label:h2d.Text,
		control:h2d.Object,
		background:h2d.Graphics
	}> = [];

    var fields: XFlow;

	public function new(parameters:Array<FormField<Dynamic>>) {
		super();
        fields = new XFlow(Vertical);
        this.addChild(fields);
		setParameters(parameters);
	}

	public function setParameters(parameters:Array<FormField<Dynamic>>):Void {
		this.controls = [];
		for (parameter in parameters) {
            var container = new Object();

			var background = new h2d.Graphics(this);
			background.clear();
			background.beginFill(0xFFFFFF); 
			background.drawRect(0, 0, 300, 30); 
			background.endFill();
			background.alpha = 0;


			var label = new h2d.Text(hxd.res.DefaultFont.get());
			label.textColor = 0x000000;
			label.text = parameter.label + " :";


			var control = parameter.paramType.getRequestControl();
			control.x = label.calcTextWidth(label.text) + 10; 
			parameter.paramType.withOptions(parameter.options);

			container.addChild(background);
			container.addChild(label);
			container.addChild(control);

			
			this.controls.push({
				param: parameter,
				label: label,
				control: control,
				background: background
			});

            fields.addChild(container);
		}
	}

	public function getParamValues():FormValues {
		var values = new FormValues();
		for (entry in controls) {
			var finalValue = entry.param.paramType.getFinalValue();
			switch (finalValue) {
				case Some(val):
					values.set(entry.param, Option.Some(val));
				case None:
					values.set(entry.param, Option.None);
				case ValidationError:
					values.set(entry.param, Option.None);
			}
		}
		return values;
	}

	public function swapParameters(arr:Array<FormField<Dynamic>>) {
		var newControls = new Array<{
			param:FormField<Dynamic>,
			label:h2d.Text,
			control:h2d.Object,
			background:h2d.Graphics
		}>();
		var yPos = 0;

		for (parameter in arr) {
			var existingControl = controls.find(c -> {
				if (c.param != null) {
					return c.param.label == parameter.label;
				}
				return false;
			});

			if (existingControl != null) {
				existingControl.label.y = yPos;
				existingControl.control.y = yPos;
				existingControl.background.clear();
				existingControl.background.beginFill(0xFFFFFF);
				existingControl.background.drawRect(0, yPos, 300, 30);
				existingControl.background.endFill();

				yPos += 30;
				newControls.push(existingControl);
			} else {
				var background = new h2d.Graphics(this);
				background.clear();
				background.beginFill(0xFFFFFF); 
				background.drawRect(0, yPos, 300, 30); 
				background.endFill();
				background.alpha = 0;

				var label = new h2d.Text(hxd.res.DefaultFont.get());
				label.textColor = 0x000000;
				label.text = parameter.label + " :";
				label.y = yPos;

				var control = parameter.paramType.getRequestControl();
				control.y = yPos;
				control.x = label.calcTextWidth(label.text) + 10; 
				parameter.paramType.withOptions(parameter.options);

				yPos += 30; 

				this.addChild(background);
				this.addChild(label);
				this.addChild(control);

				newControls.push({
					param: parameter,
					label: label,
					control: control,
					background: background
				});
			}
		}

		for (entry in controls) {
			if (!newControls.some(nc -> nc.param.label == entry.param.label)) {
				this.removeChild(entry.background);
				this.removeChild(entry.label);
				this.removeChild(entry.control);
			}
		}

		this.controls = newControls;
	}

	public function validateValues():Bool {
		var result = true;
		for (entry in controls) {
			var finalValue = entry.param.paramType.getFinalValue();
			if (finalValue == ValidationError) {
				entry.background.clear();
				entry.background.beginFill(0xFF0000);
				entry.background.alpha = 0.5;
				entry.background.drawRect(0, entry.label.y, 300, 30);
				entry.background.endFill();
				result = false;
			}
		}
		return result;
	}

	public function onValueChanged(paramLabel:String, cb:Dynamic->Void):Void {
		for (entry in controls) {
			if (entry.param.label == paramLabel) {
				entry.param.paramType.subscribeToValueChange((val) -> cb(val));
			}
		}
	}
}

typedef FormValuePair<T> = {field:FormField<T>, value:Option<T>};

class FormValues {
	var values:Array<FormValuePair<Dynamic>> = [];

	public function new() {}

	public function set<T>(field:FormField<T>, value:Option<T>) {
		values.push({field: field, value: value});
	}
}

class FormFields {
	public static function int(label:String):FormField<Int> {
		return new FormField(label, new FormField_Int());
	}

	public static function dropdown(label:String, values:Array<String>):FormField<String> {
		return new FormField(label, new FormField_Dropdown(values));
	}

	public static function string(label:String):FormField<String> {
		return new FormField(label, new FormField_String());
	}

	public static function file(label:String):FormField<FileRef> {
		return new FormField(label, new FormField_File());
	}

	public static function array(label:String, headers:Array<String>):FormField<Array<String>> {
		return new FormField(label, new FormField_Array(headers));
	}

	public static function spreadsheet(label:String, headers:Array<FormField<Dynamic>>):FormField<SpreadsheetValueState> {
		return new FormField(label, new FormField_Spreadsheet(headers));
	}
}

class FormField<T> {
	public var label:String;
	public var paramType:FormFieldType<T>;
	public var options:Array<FormFieldOption<T>> = [];

	public function new(label:String, paramType:FormFieldType<T>) {
		this.label = label;
		this.paramType = paramType;
	}

	public function withOptions(opts:Array<FormFieldOption<T>>):FormField<T> {
		this.options = opts;
		return this;
	}

	public function clone():FormField<T> {
		var f = new FormField(label, paramType.clone());
		f.options = options;
		return f;
	}
}

abstract class FormFieldType<T> {
	public var opts:Array<FormFieldOption<T>> = [];
	public var isRequired:Bool = false;

	public abstract function getRequestControl():h2d.Object;

	public abstract function subscribeToValueChange(cb:(Dynamic) -> Void):Void;

	public abstract function getFinalValue():FormFieldValResult<T>;

	public function getWidth(): Int {
		return 100;
	}

	public abstract function clone():FormFieldType<T>;

	public function withOptions(opts:Array<FormFieldOption<T>>):Void {
		this.opts = opts;

		for (option in opts) {
			switch option {
				case Required:
					{
						isRequired = true;
					}
				default:
			}
		}

		handleOptions(opts);
	}

	public abstract function handleOptions(opts:Array<FormFieldOption<T>>):Void;
}

enum FormFieldOption<T> {
	SetValue(val:T);
	Disable;
	Validation(cb:T->Bool);
	Required;
}

enum FormFieldValResult<T> {
	Some(val:T);
	None;
	ValidationError;
}

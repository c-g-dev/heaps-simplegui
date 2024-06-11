package heaps.simplegui.components.form.types;

import heaps.simplegui.components.control.ArrayControl;
import heaps.simplegui.components.form.Form.FormFieldOption;
import heaps.simplegui.components.form.Form.FormFieldValResult;
import heaps.simplegui.components.control.InputField;
import heaps.simplegui.components.form.Form.FormFieldType;

using ludi.commons.extensions.Extensions_Collections;

class FormField_Array extends FormFieldType<Array<String>> {
	var arrayControl:ArrayControl;
	var cols:Array<String>;

	public function new(cols:Array<String>) {
		this.cols = cols;
	}

	public function getRequestControl():h2d.Object {
		arrayControl = new ArrayControl(cols);
		return arrayControl;
	}

	public function getFinalValue():FormFieldValResult<Array<String>> {
		if (isRequired && (arrayControl.getValues().length == 0)) {
			return ValidationError;
		}
		return Some(arrayControl.getValues().verticalCut(0));
	}

	public function subscribeToValueChange(cb:Dynamic->Void) {
		// todo
	}

	public function handleOptions(opts:Array<FormFieldOption<Array<String>>>):Void {
		for (option in opts) {
			switch option {
				case SetValue(val):
					{}
				case Disable:
					{}
				default:
			}
		}
	}

	public function clone(): FormField_Array {
		return new FormField_Array(this.cols);
	}
}

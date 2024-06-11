package heaps.simplegui.components.form.types;

import heaps.simplegui.components.form.Form.FormFieldOption;
import heaps.simplegui.components.form.Form.FormFieldValResult;
import heaps.simplegui.components.control.InputField;
import heaps.simplegui.components.form.Form.FormFieldType;

class FormField_Int extends FormFieldType<Int> {
	var input:InputField;
    var cb: Dynamic -> Void = (_) -> {};

	public function new() {}

	public function getRequestControl():h2d.Object {
		input = new InputField(100, 21);
		input.textInput.text = "0";
        input.textInput.onChange = () -> {
            cb(input.textInput.text);
        }
		return input;
	}

	public function getFinalValue():FormFieldValResult<Int> {
		if (isRequired && (input.textInput.text == null || input.textInput.text == "")) {
			return ValidationError;
		}
		if (!Std.isOfType(Std.parseInt(input.textInput.text), Int)) {
			return ValidationError;
		}
		return Some(Std.parseInt(input.textInput.text));
	}

	public function subscribeToValueChange(cb:Dynamic->Void) {
		this.cb = cb;
	}

	public function handleOptions(opts:Array<FormFieldOption<Int>>):Void {
		for (option in opts) {
			switch option {
				case SetValue(val):
					{
						input.textInput.text = Std.string(val);
					}
				case Disable:
					{
						input.textInput.canEdit = false;
					}
				default:
			}
		}
	}

    public function clone(): FormField_Int {
		return new FormField_Int();
	}
}

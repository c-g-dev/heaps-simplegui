package heaps.simplegui.components.form.types;

import heaps.simplegui.components.form.Form.FormFieldOption;
import heaps.simplegui.components.form.Form.FormFieldValResult;
import heaps.simplegui.components.control.InputField;
import heaps.simplegui.components.form.Form.FormFieldType;

class FormField_String extends FormFieldType<String> {
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

	public function getFinalValue():FormFieldValResult<String> {
        if(isRequired && (input.textInput.text == null || input.textInput.text == "")){
            return ValidationError;
        }
        return Some(input.textInput.text);
	}

	public function subscribeToValueChange(cb:Dynamic->Void) {
		this.cb = cb;
	}

	public function handleOptions(opts:Array<FormFieldOption<String>>):Void {
		for (option in opts) {
			switch option {
				case SetValue(val):
					{
						input.textInput.text = val;
					}
				case Disable:
					{
						input.textInput.canEdit = false;
					}
				default:
			}
		}
	}

	public function clone(): FormField_String {
		return new FormField_String();
	}
}

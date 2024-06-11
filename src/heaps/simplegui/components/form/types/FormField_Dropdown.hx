package heaps.simplegui.components.form.types;

import heaps.simplegui.util.Make;
import heaps.simplegui.util.HeapsUtil;
import heaps.simplegui.components.control.ListDropdown;
import ludi.commons.macro.Functions;
import heaps.simplegui.components.form.Form.FormFieldOption;
import heaps.simplegui.components.form.Form.FormFieldValResult;
import heaps.simplegui.components.control.InputField;
import heaps.simplegui.components.form.Form.FormFieldType;

class FormField_Dropdown extends FormFieldType<String> {
	var dropdown: ListDropdown;
	var values: Array<String>;
    public function new(values: Array<String>) {
		this.values = values;
        dropdown = Make.controls.dropdown(100, values);
    }

    public function getRequestControl(): h2d.Object {
        return dropdown;
    }

    public function getFinalValue(): FormFieldValResult<String> {
        if(isRequired){
            if(dropdown.dropdown.selectedItem == -1){
                return ValidationError;
            }
        }

        if (dropdown.dropdown.selectedItem != -1) {
            return FormFieldValResult.Some((cast dropdown.dropdown.dropdownList.getChildAt(dropdown.dropdown.selectedItem + 3).getChildAt(1): h2d.Text).text);
        } else {
            return FormFieldValResult.None;
        }
    }

    public function subscribeToValueChange(cb: Dynamic -> Void) {
        Functions.attach(dropdown.dropdown.onChange, (item) -> {
            @:privateAccess cb(dropdown.dropdown.selectedItem != -1 ? (cast dropdown.dropdown.getItem(dropdown.dropdown.selectedItem).getChildAt(1): h2d.Text).text : null);
        });
    }

    public function handleOptions(opts:Array<FormFieldOption<String>>):Void {
        for (option in opts) {
            switch option {
                case SetValue(val): {}
                case Disable:
                default:
            }
        }
    }

	public function clone(): FormField_Dropdown {
		return new FormField_Dropdown(this.values);
	}
}

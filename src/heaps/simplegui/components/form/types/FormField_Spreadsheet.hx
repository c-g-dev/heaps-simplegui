package heaps.simplegui.components.form.types;

import heaps.simplegui.components.form.Form.FormField;
import heaps.simplegui.components.control.Spreadsheet;
import heaps.simplegui.components.form.Form.FormFieldOption;
import heaps.simplegui.components.form.Form.FormFieldValResult;
import heaps.simplegui.components.control.InputField;
import heaps.simplegui.components.form.Form.FormFieldType;

class FormField_Spreadsheet extends FormFieldType<SpreadsheetValueState> {
	var spreadsheet: Spreadsheet;
    var headers: Array<FormField<Dynamic>>;

    public function new(headers: Array<FormField<Dynamic>>) {
        this.headers = headers;
    }

    public function getRequestControl():h2d.Object {
        spreadsheet = new Spreadsheet(this.headers);
        return spreadsheet;
    }

    public function getFinalValue():FormFieldValResult<SpreadsheetValueState> {
        return Some(spreadsheet.getValues());
    }


    public function subscribeToValueChange(cb:Dynamic -> Void) {
        
    }

    public function handleOptions(opts:Array<FormFieldOption<SpreadsheetValueState>>):Void {
        for (option in opts) {
            switch option {
                case SetValue(val): {

                }
                case Disable: {
                    
                }
                default:
            }
        }
    }

	public function clone(): FormField_Spreadsheet {
		return new FormField_Spreadsheet(this.headers);
	}
}

package heaps.simplegui.components.form.types;

import h2d.Object;
import heaps.simplegui.components.control.ChooseFileInput;
import heaps.simplegui.components.form.Form.FormFieldOption;
import heaps.simplegui.components.form.Form.FormFieldValResult;
import heaps.simplegui.components.control.InputField;
import heaps.simplegui.components.form.Form.FormFieldType;

class FormField_File extends FormFieldType<FileRef> {
	
    var input: ChooseFileInput;

    public function new() {
        
    }
    
    public function getRequestControl():Object {
        input = new ChooseFileInput(200);
        return input;
    }

    public function subscribeToValueChange(cb:Dynamic -> Void) {
        //todo
    }

    public function getFinalValue():FormFieldValResult<FileRef> {


        return switch input.getChosenFileRef() {
            case Some(v): return Some(v);
            case None: {
                if(isRequired){
                    return ValidationError;
                }
                return None;
            }
        }
    }

    public function handleOptions(opts:Array<FormFieldOption<FileRef>>):Void {
        for (option in opts) {
            switch option {
                case SetValue(val): {
                    input.setValue((cast val: FileRef).path);
                }
                case Disable: {
                    input.button.disable();
                }
                default:
            }
        }
    }

	public override function getWidth(): Int {
		return 205;
	}


	public function clone(): FormField_File {
		return new FormField_File();
	}
}

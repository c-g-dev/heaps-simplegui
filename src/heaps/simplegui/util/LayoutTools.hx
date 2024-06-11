package heaps.simplegui.util;


function obj<T: h2d.Object, C, D: C & {obj: T}>(c: Class<T>, ?d: C): D {
    var o = Type.createInstance(c, []);
    attach(o, d);
    var r: Dynamic = {obj: o};
    if(d != null){
        for (field in Reflect.fields(d)) {
            Reflect.setField(r, field, Reflect.field(d, field));
        }
    }
    return cast r;
}

function attach<T>(parent: h2d.Object, layout: Dynamic): Void {
    if(layout != null){
        for (field in Reflect.fields(layout)) {
            parent.addChild(Reflect.field(layout, field).obj);
        }
    }
}

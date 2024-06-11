package heaps.simplegui.components.util;

import ludi.commons.math.IVec2;
import h2d.RenderContext;

class DimensionBinder extends GhostObject {
    var resolver: DimensionBindingResolver;
    public var autoUpdate: Bool = true;

    public function new(parent: h2d.Object, binding: DimensionBinding, ?applier: DimensionApplier) {
        super(parent);
        if(applier == null){
            applier = Scale(parent);
        }
        resolver = new DimensionBindingResolver(applier, binding);
        resolver.checkDimsChanged();
        resolver.apply();
    }

    public function update(): Void {
        if(resolver.checkDimsChanged()){
            resolver.apply();
        }
    }
    
    public function setApplier(applier: DimensionApplier) {
        @:privateAccess resolver.applier = applier;
    }
    
    override function sync(ctx: RenderContext) {
        super.sync(ctx);
        if(autoUpdate && resolver.checkDimsChanged()){
            resolver.apply();
        }
    }
}

typedef Concrete = {width: Float, height: Float};

enum DimensionBinding {
    Absolute(width: Int, height: Int);
    BindToWindow;
    BindToParentBounds(child: h2d.Object);
    BindToBounds(obj: h2d.Object);
    BindToWidthHeight<T: Concrete>(obj: T);
    Custom(cb: () -> IVec2);
}

enum DimensionApplier {
    Set<T: Concrete>(obj: T);
    Scale(obj: h2d.Object);
    Custom(cb: (Int, Int) -> Void);
}

class DimensionBindingResolver {
    private var applier: DimensionApplier;
    private var binding: DimensionBinding;
    public var currentWidth: Int;
    public var currentHeight: Int;
    
    public function new(applier: DimensionApplier, binding: DimensionBinding) {
        this.applier = applier;
        this.binding = binding;
    }
    
    public function checkDimsChanged(): Bool {
        var newWidth: Int;
        var newHeight: Int;

        switch (binding) {
            case Absolute(width, height): {
                newWidth = width;
                newHeight = height;
            }
            case BindToWindow: {
                var window = hxd.Window.getInstance();
                newWidth = window.width;
                newHeight = window.height;
            }
            case BindToBounds(obj): {
                var bounds = obj.getBounds();
                newWidth = Std.int(bounds.width);
                newHeight = Std.int(bounds.height);
            }
            case BindToWidthHeight(obj): {
                newWidth = Std.int(obj.width);
                newHeight = Std.int(obj.height);
            }
            case BindToParentBounds(child): {
                if (child.parent != null) {
                    var parent = child.parent;
                    child.getScene().addChild(child);
                    var parentBounds = parent.getBounds();
                    newWidth = Std.int(parentBounds.width);
                    newHeight = Std.int(parentBounds.height);
                    parent.addChild(child);
                } else {
                    newWidth = this.currentWidth;
                    newHeight = this.currentHeight;
                }
            }
            case Custom(cb): {
                var size = cb();
                newWidth = size.x;
                newHeight = size.y;
            }
        }

        if (newWidth != currentWidth || newHeight != currentHeight) {
            currentWidth = newWidth;
            currentHeight = newHeight;
            return true;
        }
        return false;
    }

    public function apply(): Void {
        switch (applier) {
            case Set(obj): {
                obj.width = this.currentWidth;
                obj.height = this.currentHeight;
            }
            case Scale(obj): {
                obj.scaleX = this.currentWidth / obj.getBounds().width;
                obj.scaleY = this.currentHeight / obj.getBounds().height;
            }
            case Custom(cb): {
                cb(this.currentWidth, this.currentHeight);
            }
        }
    }
}
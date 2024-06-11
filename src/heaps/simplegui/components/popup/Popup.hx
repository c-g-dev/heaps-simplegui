package heaps.simplegui.components.popup;

import h2d.Scene;
import hxd.Window;
import heaps.simplegui.components.widget.Button;

class Popup extends h2d.Object {
    private var background: h2d.Graphics;
    private var mainContainer: h2d.Flow;
    private var buttonContainer: h2d.Flow;
    private var contentContainer: h2d.Flow;
    private var system: PopupSystem = PopupSystem.DEFAULT;
    var width: Int;
    var height: Int;
    var didRender: Bool = false;

    public function new(width: Int, height: Int) {
        super();

        this.width = width;
        this.height = height;

        background = new h2d.Graphics(this);
        drawBackground(width, height);

        mainContainer = new h2d.Flow(this);
        mainContainer.x = 5;
        mainContainer.y = 5;
        mainContainer.minWidth = width - 10;
        mainContainer.minHeight = height - 10;
        mainContainer.layout = Vertical;

        contentContainer = new h2d.Flow(mainContainer);

        buttonContainer = new h2d.Flow(mainContainer);
        buttonContainer.layout = Horizontal;
        buttonContainer.horizontalSpacing = 20;

        var okButton = new Button("Ok");
        buttonContainer.addChild(okButton);
        okButton.onClick = function() {
            onOk();
            this.close();
        };

        var cancelButton = new Button("Cancel");
        buttonContainer.addChild(cancelButton);
        cancelButton.onClick = function() {
            this.close();
        };

        var p = mainContainer.getProperties(buttonContainer);
        p.verticalAlign = Bottom;
        p.horizontalAlign = Middle;
        p.paddingTop = 20;
        p.paddingBottom = 20;
    }

    public function render() {
        populate(this.contentContainer);
        resizeToContent();
        didRender = true;
    }

    private function drawBackground(width: Int, height: Int): Void {
        background.clear();
        background.beginFill(0xD3D3D3);
        background.drawRect(0, 0, width, height);
        background.endFill();

        background.beginFill(0x000000, 0);
        background.lineStyle(2, 0x000000);
        background.drawRect(0, 0, width, height);
    }

    public function resize(width: Int, height: Int) {
        this.width = width;
        this.height = height;
        drawBackground(width + 10, height + 10);

        mainContainer.minWidth = width - 10;
        mainContainer.minHeight = height - 10;
        centerInScreen(width, height);
    }

    public function resizeToContent() {
        var dims = mainContainer.getBounds();
        resize(Std.int(dims.width), Std.int(dims.height));
    }

    public function centerInScreen(width: Int, height: Int) {
        if(this.getScene() != null){

            var screenWidth = this.getScene().width;
            var screenHeight = this.getScene().height;
    
            this.x = Std.int((screenWidth - width) / 2);
            this.y = Std.int((screenHeight - height) / 2);
        }
    }

    public dynamic function populate(container: h2d.Flow): Void {}

    public dynamic function onOk(): Void {}

    public function show(scene: Scene) {
        if(!didRender){
            render();
        }
        system.show(this, scene);
    }

    public function close() {
        system.clear();
    }
}

class PopupSystem {

    public static var DEFAULT: PopupSystem = new PopupSystem();
    var currentPopup: Popup;

    public function new() {}

    public function show(popup: Popup, scene: h2d.Scene) {
        clear();
        currentPopup = popup;
        scene.add(popup);
        alignPopup();
    }

    public function alignPopup() {
        if (currentPopup != null) {
            var window = Window.getInstance();
            @:privateAccess currentPopup.x = Std.int((window.width - currentPopup.width) / 2);
            @:privateAccess currentPopup.y = Std.int((window.height - currentPopup.height) / 2);
        }
    }

    public function clear() {
        currentPopup.remove();
        currentPopup = null;
    }

}

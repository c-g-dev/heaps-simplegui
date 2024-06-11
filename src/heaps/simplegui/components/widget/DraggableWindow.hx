package heaps.simplegui.components.widget;

import h2d.Flow;
import h2d.Interactive;
import hxd.res.DefaultFont;
import h2d.Object;
import h2d.Graphics;

class DraggableWindow extends h2d.Object {
    public var width:Float;
    public var height:Float;
    private var title:String;
    private var dragging:Bool = false;
    private var dragOffsetX:Float = 0;
    private var dragOffsetY:Float = 0;

    public function new(width:Float, height:Float, title:String) {
        super();
        this.width = width;
        this.height = height;
        this.title = title;

        var bg = new h2d.Graphics();
        bg.beginFill(0xE0E0E0);
        bg.drawRect(0, 0, width, height);
        bg.endFill();
        addChild(bg);

        var topBar = new h2d.Graphics();
        topBar.beginFill(0xA09E9E);
        topBar.drawRect(0, 0, width, 20);
        topBar.endFill();
        addChild(topBar);

        var bgContainer = new Flow();
        bgContainer.maxHeight = Std.int(height - 20);
        bgContainer.maxWidth = Std.int(width);
        bgContainer.y = 20;
        bg.addChild(bgContainer);

        var titleText = new h2d.Text(hxd.res.DefaultFont.get(), topBar);
        titleText.text = title;
        titleText.x = 10;
        titleText.y = 2;
        titleText.textColor = 0x000000;

        var closeButton = new h2d.Text(hxd.res.DefaultFont.get());
        closeButton.text = "[x]";
        closeButton.x = width - (closeButton.calcTextWidth("[x]") + 5);
        closeButton.textColor = 0xe93333;

        var iCloseButton = new h2d.Interactive(20, 20, closeButton);
        closeButton.addChild(iCloseButton);

        iCloseButton.onRelease = (e) -> {
            this.parent.removeChild(this);
        };

       var restoreButton = new h2d.Text(hxd.res.DefaultFont.get());
       restoreButton.text = "[+]";
       restoreButton.x = closeButton.x - (restoreButton.calcTextWidth("[+]") + 5);
       restoreButton.textColor = 0xc5f557;

       var iRestoreButton = new h2d.Interactive(20, 20, restoreButton);
       restoreButton.addChild(iRestoreButton);

       iRestoreButton.onRelease = (e) -> {
           bg.alpha = 1;
           bgContainer.alpha = 1;
       };

       var minimizeButton = new h2d.Text(hxd.res.DefaultFont.get());
       minimizeButton.text = "[-]";
       minimizeButton.x = restoreButton.x - (minimizeButton.calcTextWidth("[-]") + 5);
       minimizeButton.textColor = 0x876c1b;

       var iMinimizeButton = new h2d.Interactive(20, 20, minimizeButton);
       minimizeButton.addChild(iMinimizeButton);

       iMinimizeButton.onRelease = (e) -> {
           bg.alpha = 0;
           bgContainer.alpha = 0;
       };



       topBar.addChild(closeButton);
       topBar.addChild(minimizeButton);
       topBar.addChild(restoreButton);

        var iTopBar = new h2d.Interactive(width - 30, 20, topBar);
        topBar.addChild(iTopBar);

        iTopBar.onPush = function(e) {
            dragging = true;
            dragOffsetX = e.relX;
            dragOffsetY = e.relY;
            iTopBar.startCapture((e) -> {
                if (dragging) {
                    this.x += e.relX - dragOffsetX;
                    this.y += e.relY - dragOffsetY;
                }
            });
        };
        iTopBar.onRelease = function(e) {
            dragging = false;
            iTopBar.stopCapture();
        };

    }
}
package heaps.simplegui.components.widget;

import heaps.simplegui.components.action.DragDrop.DropZone;
import ludi.commons.util.Styles;
import h2d.Flow;
import hxd.res.DefaultFont;
import h2d.Graphics;
import h2d.Object;
import h2d.Text;


class Panel extends h2d.Object {
    public var border:Graphics;
    public var background:Graphics;
    
    public var header:Graphics;
    public var content:Flow;
    public var footer:Graphics;

    public var headerContainer:Flow;
    public var headerTitle:Text;

    public var footerContainer:Flow;

    public var width: Int;
    public var height: Int;

    public var styles = {
        header: false,
        headerTitle: "",
        headerHeight: 20,
        footer: false,
        footerHeight: 20,
        dropzone: false,
        onDrop: (_, _, _) -> {},
        borderWidth: 2 
    }

    public function new(width: Int, height: Int, ?config: Dynamic = null) {
        super();

        this.width = width;
        this.height = height;
        Styles.upsert(styles, config);

        border = new Graphics(this);
        background = new Graphics(this);
        content = new Flow();
        content.layout = Horizontal;
        content.overflow = FlowOverflow.Scroll;

        this.addChild(border);
        this.addChild(background);
        this.addChild(content);

        if(styles.dropzone){
            var dropzone = new DropZone(width, height);
            dropzone.onDrop = styles.onDrop;
            this.addChild(dropzone);
        }

        if(styles.header) {
            header = new Graphics(this);
            headerContainer = new Flow();
            headerContainer.layout = Horizontal;
            headerTitle = new Text(DefaultFont.get());
            headerTitle.text = styles.headerTitle;
            headerTitle.textColor = 0x000000;

            this.addChild(header);
            this.addChild(headerContainer);
            headerContainer.addChild(headerTitle);
            headerContainer.horizontalSpacing = 3;
            headerContainer.paddingTop = 5;
            headerContainer.verticalAlign = Middle;
        }

        if(styles.footer) {
            footer = new Graphics(this);
            footerContainer = new Flow();
            footerContainer.layout = Horizontal;
            footerContainer.horizontalSpacing = 3;
            this.addChild(footer);
            this.addChild(footerContainer);
            footerContainer.paddingTop = 3;
        }

        resize();

    }

    
    public function resize():Void {
        var headerHeight = styles.header ? styles.headerHeight : 0;
        var footerHeight = styles.footer ? styles.footerHeight : 0;

        border.clear();
        border.beginFill(0x854344);
        border.drawRect(0, 0, width, height);
        border.endFill();

        background.clear();
        background.beginFill(0xE0E0E0);
        background.drawRect(styles.borderWidth, headerHeight + (styles.borderWidth), width - (styles.borderWidth * 2), height - headerHeight - footerHeight - (styles.borderWidth * 2));
        background.endFill();

        content.maxHeight = height - headerHeight - footerHeight - (styles.borderWidth * 2);
        content.maxWidth = width - (styles.borderWidth * 2);
        content.y = headerHeight;

        if(styles.header) {
            header.clear();
            header.beginFill(0xCCCCCC);
            header.drawRect(styles.borderWidth, styles.borderWidth, width - (styles.borderWidth * 2), headerHeight - styles.borderWidth);
            header.endFill();
            headerContainer.paddingLeft = styles.borderWidth + 3;
            headerTitle.text = styles.headerTitle;
        }
        if(styles.footer) {
            var footerY = height - footerHeight - (styles.borderWidth * 2);
            footer.clear();
            footer.beginFill(0xCCCCCC);
            footer.drawRect(0, footerY, width, footerHeight);
            footer.endFill();
            footerContainer.paddingLeft = 5;
            footerContainer.y = footerY;
        }

    }
}
package heaps.simplegui.components.hl;

import heaps.simplegui.components.widget.Button;
import heaps.simplegui.components.display.LazyTreeView;
import heaps.simplegui.components.widget.Panel;
import h2d.filter.DropShadow;
import haxe.io.Path;
import heaps.simplegui.components.display.TreeView.FileNode;
import haxe.ds.Option;

class FileChooser extends h2d.Object {
    var isShowing: Bool = false;

    public function new(?parent: h2d.Object) {
        super(parent);
    }

    public function showAndChoose(directory: String, cb: (Option<String>) -> Void) {
        if(isShowing){
            return;
        }

        isShowing = true;
        var panel = new Panel(200, 400,  {header: true, footer: true, footerHeight: 40});
        addChild(panel);

        var generateNodesFromPath: (String) -> FileNode = (path) -> {
            var root = new FileNode("root", "", true);
            var newPath = new Path(path);
            var parentNode = new FileNode("/..", newPath.dir, true);
            parentNode.expanded = true;
            var filesAndDirs = sys.FileSystem.readDirectory(path);
            for (name in filesAndDirs) {
                var childPath = haxe.io.Path.join([path, name]); 
                var isDir = sys.FileSystem.isDirectory(childPath);
                parentNode.addChild(new FileNode(name, childPath, isDir));
            }
            root.addChild(parentNode);
            return root;
        }

        var ltv = new LazyTreeView(generateNodesFromPath(directory), (node) -> {
            return generateNodesFromPath(node.val);
        });

        ltv.styles.textColor = 0x000000;
        ltv.updateTree(false);

        ltv.topic.subscribe((e) -> {
            switch e {
                case TreeRebuilt: {
                    panel.content.scrollPosY = 0;
                    panel.content.contentChanged(ltv);      
                }
                default:
            }
        });

        panel.content.addChild(ltv);
        panel.footerContainer.paddingTop = 3;

        var button = new Button("Select");
        button.onClick = () -> {
            cb(switch ltv.selected {
                case Some(v): Some(v.val);
                case None: None;
            });
            while (numChildren > 0) {
                this.removeChild(this.children[0]);
            }
        };
        panel.footerContainer.addChild(button);

        var exitbutton = new Button("Exit");
        exitbutton.onClick = () -> {
            cb(None);
            while (numChildren > 0) {
                this.removeChild(this.children[0]);
            }
        };
        panel.footerContainer.addChild(exitbutton);

    }
}
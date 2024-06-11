package heaps.simplegui.components.display;

import ludi.commons.util.Styles;
import heaps.simplegui.components.action.DragDrop.ShadowDrag;
import ludi.commons.messaging.Topic;
import haxe.ds.Option;
import h2d.Graphics;
import h2d.Interactive;
import hxd.res.DefaultFont;
import h2d.Scene;
import h2d.Object;
import h2d.TextInput;
import h2d.Text;

class TreeNode {
    public var name:String;
    public var val: Dynamic;
    public var children:Array<TreeNode>;
    public var isDirectory:Bool;
    public var isRoot:Bool = false;
    public var selected:Bool = false;
    public var expanded:Bool = false;
    
    public function new(name:String, val: Dynamic, isDirectory:Bool) {
        this.name = name;
        this.val = val;
        this.isDirectory = isDirectory;
        children = new Array<TreeNode>();
    }
    
    public function addChild(child:TreeNode):Void {
        children.push(child);
    }
}

class TreeView extends Object {
    public var rootNode:TreeNode;
    public var allNodes: Array<TreeNode> = [];
    public var selected: Option<TreeNode> = None;
    public var topic: Topic<TreeViewEvent> = new Topic();

    public var styles = {
        textColor: 0xFFFFFF,
        itemDrag: false
    }

    public function new(rootNode:TreeNode, ?styles: Dynamic) {
        super();
        Styles.upsert(this.styles, styles);
        this.rootNode = rootNode;
        if(rootNode != null){
            this.rootNode.isRoot = true;
            buildTree(rootNode, 0);
            updateTree(true);
        }
    }

    public function setRoot(root: TreeNode) {
        clearTree();
        this.rootNode = root;
        root.isRoot = true;
        buildTree(rootNode, 0);
    }
    
    public function buildTree(node:TreeNode, depth:Int):Void {

        if(node.isRoot){
            for (child in node.children) {
                buildTree(child, 0);
            }
            return;
        }

        allNodes.push(node);

        var label = new Text(DefaultFont.get());
        var iconTxt = node.expanded ? "[-]" : "[+]";
        label.text = node.isDirectory ? iconTxt + " " + node.name : node.name;
        label.textColor = styles.textColor;
        
        var labelContainer = new Graphics();

        addChild(labelContainer);
        addChild(label);



        if(node.isDirectory){
            var expanderInteractive = new Interactive(label.calcTextWidth(iconTxt), label.textHeight);
            expanderInteractive.onClick = function(e) {
                onItemExpanded(node);
            };
            label.addChild(expanderInteractive);

            var labelInteractive = new Interactive(label.calcTextWidth(" " + node.name), label.textHeight);
            labelInteractive.x = label.calcTextWidth(iconTxt);
            labelInteractive.onClick = function(e) {
                onItemClicked(node);
            };
            label.addChild(labelInteractive);
            handleDrag(node, label, labelContainer, labelInteractive);
        }
        else{
            var labelInteractive = new Interactive(label.calcTextWidth(node.name), label.textHeight);
            labelInteractive.onClick = function(e) {
                onItemClicked(node);
            };
            label.addChild(labelInteractive);
            handleDrag(node, label, labelContainer, labelInteractive);
        }

        labelContainer.beginFill(0x37BCD3); 
        labelContainer.drawRect(0, 0, label.calcTextWidth(label.text), 20);
        labelContainer.endFill();
        labelContainer.x = depth * 20;
        labelContainer.y = (allNodes.length - 1) * 20;
        

        labelContainer.alpha = node.selected ? 0.5 : 0;

        label.x = labelContainer.x;
        label.y = labelContainer.y;

        if (node.expanded && node.isDirectory) {
            for (child in node.children) {
                buildTree(child, depth + 1);
            }
        }

                

        
    }

    static var counter: Int= 0;
    private function handleDrag(node: TreeNode, label: Text, labelContainer: Graphics, interactive: Interactive){
        
        if(this.styles.itemDrag){
            var shadowDrag = new ShadowDrag(interactive, {autowireToInteractive: false});
            interactive.onPush = (e) -> {
                shadowDrag.startDrag();
            }
            interactive.onRelease = (e) -> {
                shadowDrag.stopDrag();
            }
            shadowDrag.dropValue = {type: "TreeViewNode", val: node.val};
            shadowDrag.visible = false;
            label.addChild(shadowDrag);
        } 
    }

    private function onItemExpanded(node: TreeNode) {
        if (node.isDirectory) {
            node.expanded = !node.expanded;
        }
        if(!node.expanded){
            traverseAllChildren(node, (child) -> {
                child.selected = false;
            });
        }
        updateTree(true);
    }

    private function onItemClicked(node: TreeNode) {
        select(node);
        updateTree(false);
    }

    private function traverseAllChildren(node: TreeNode, cb: TreeNode -> Void){
        for (child in node.children) {
            cb(child);
            traverseAllChildren(child, cb);
        }
    }

    private function select(node: TreeNode) {
        for (node in allNodes) {
            node.selected = false;
        }
        node.selected = true;
        selected = Some(node);
        topic.notify(Selected(node));
    }
    
    private function clearTree():Void {
        this.allNodes = [];
        while (numChildren > 0) {
            this.removeChild(this.children[0]);
        }
    }
    
    public function updateTree(nodesChanged: Bool):Void {
        clearTree();
        buildTree(rootNode, 0);
        if(nodesChanged){
            topic.notify(TreeRebuilt);
        }
    }
}

enum TreeViewEvent {
    Selected(node: TreeNode);
    TreeRebuilt;
}
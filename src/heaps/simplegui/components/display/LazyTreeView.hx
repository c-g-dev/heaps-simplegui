package heaps.simplegui.components.display;

import heaps.simplegui.components.display.TreeView.TreeNode;


class LazyTreeView extends TreeView {
    public var onExpand: (TreeNode) -> TreeNode;

    public function new(rootNode:TreeNode, onExpand: (TreeNode) -> TreeNode, ?newConfig: Dynamic) {
        super(rootNode, newConfig);
        this.onExpand = onExpand;
    }
    
    public override function onItemExpanded(node: TreeNode) {
        var newRoot = onExpand(node);
        this.rootNode = newRoot;
        newRoot.isRoot = true;
        buildTree(newRoot, 0);
        updateTree(true);
    }
}
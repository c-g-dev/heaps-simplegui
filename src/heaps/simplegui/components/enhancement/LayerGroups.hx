package heaps.simplegui.components.enhancement;

import ludi.commons.util.PrioritySorter.Priority;
import ludi.commons.util.PrioritySorter;
import ludi.commons.math.MaxIntFinder;
import ludi.commons.collections.Set;
import h2d.RenderContext;
import h2d.Layers;
import h2d.Object;

typedef GroupDef = {groupName: String, groupId: Int, groupPriority: Priority, currentRealLayer: Int, layers: Layers};

class LayerGroups extends Layers {
	var groups: Array<GroupDef> = [];
	var groupIds: Int = 0;

	public function new(?parent) {
		super(parent);
	}

	public function deepRemove(child: h2d.Object){
		for (group in groups) {
			group.layers.removeChild(child);
		}
	}

	public function hasGroup(groupName: String): Bool {
		for (group in groups) {
			if (group.groupName == groupName) {
				return true;
			}
		}
		return false;
	}

	public function getGroupLayers(groupName: String): Layers {
		for (group in groups) {
			if (group.groupName == groupName) {
				return group.layers;
			}
		}
		return null;
	}

	public function getGroupId(groupName: String): Null<Int> {
		for (group in groups) {
			if (group.groupName == groupName) {
				return group.groupId;
			}
		}
		return null;
	}

	
	public function getGroupById(id: Int): String {
		for (group in groups) {
			if (group.groupId == id) {
				return group.groupName;
			}
		}
		return null;
	}

	public function getGroupPriority(groupName: String): Priority {
		for (group in groups) {
			if (group.groupName == groupName) {
				return group.groupPriority;
			}
		}
		return null;
	}

	public function addChildToGroup( obj: h2d.Object, groupName: String, layerIdx: Int): Void {
		var layers = getGroupLayers(groupName);
		if (layers != null) {
			layers.add(obj, layerIdx);
		}
	}

	public function addGroup(groupName: String, groupPriority: Priority): Void {
		var newGroup = {groupName: groupName, groupId: groupIds++, groupPriority: groupPriority, currentRealLayer: -1, layers: new Layers()};
		groups.push(newGroup);
		rebalanceGroups();
	}


	private function rebalanceGroups(): Void {
		var sorter: PrioritySorter<GroupDef> = new PrioritySorter();
		for (group in groups) {
			sorter.consume(group.groupName, group, group.groupPriority);
		}

		var sorted = sorter.getItemsInOrder();
		for (i in 0...sorted.length) {
			sorted[i].currentRealLayer = i;
		}

		for (group in groups) {
			this.add(group.layers, group.currentRealLayer, 0);
		}
	}
}
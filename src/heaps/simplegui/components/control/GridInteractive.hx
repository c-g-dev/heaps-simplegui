package heaps.simplegui.components.control;

import heaps.simplegui.util.HeapsUtil;
import ludi.commons.util.Options;
import ludi.commons.util.Nulls;
import ludi.commons.math.IVec4;
import haxe.Json;
import ludi.commons.math.IVec2;
import ludi.commons.util.Styles;
import ludi.commons.collections.I4Map;
import ludi.commons.pattern.SyncPair;
import haxe.ds.Option;
import heaps.simplegui.components.enhancement.LayerGroups;

typedef GridInteractiveSyle = {
	?margin:Int,
	?cellSize:Int,
	?renderGridLines:Bool,
	?minGridWidth:Int,
	?minGridHeight:Int,
	?maxGridWidth:Option<Int>,
	?maxGridHeight:Option<Int>,
	?initLayerGroups:Array<String>,
}

class GridInteractive extends LayerGroups {
	private var content:SyncPair<I4Map<h2d.Object>>;
	private var style:GridInteractiveSyle = {
		margin: 0,
		cellSize: 50,
		renderGridLines: true,
		minGridWidth: 0,
		minGridHeight: 0,
		maxGridWidth: None,
		maxGridHeight: None,
		initLayerGroups: null
	}

	private var interactive:h2d.Interactive;
	private var handlers:Array<(GridInteractiveEvent) -> Void> = [];
	private var gridLines:h2d.Graphics;

	public function new(?styleArg:GridInteractiveSyle) {
		super();

		Styles.upsert(this.style, styleArg);
		if (this.style.initLayerGroups != null) {
			for (lg in this.style.initLayerGroups) {
				addGroup(lg, Normal);
			}
		}

		this.content = new SyncPair<I4Map<h2d.Object>>(new I4Map<h2d.Object>(), (toClone) -> {
			return toClone.clone();
		});

		this.interactive = new h2d.Interactive(0, 0);
		this.addChild(interactive);

		initializeInteraction();
		drawGrid(new IVec2(style.minGridWidth, style.minGridHeight));
		rerender(Full);
	}

	public function updateStyle(styleArg:GridInteractiveSyle) {
		Styles.upsert(this.style, styleArg);
		drawGrid(new IVec2(style.minGridWidth, style.minGridHeight));
	}

	public function rerender(scope:GridRerenderScope) {
		if (batchUpdating)
			return;
		switch scope {
			case Coord(x, y, z, group):
				{
					if (content.readExisting().has(x, y, z, getGroupId(group))) {
						this.deepRemove(content.readExisting().get(x, y, z, getGroupId(group)));
					}
					var newObj = content.smudge().get(x, y, z, getGroupId(group));
					if (newObj != null) {
						newObj.setPosition(x * (style.cellSize + style.margin), y * (style.cellSize + style.margin));
						this.addChildToGroup(newObj, group, zToDepth(z));
					}
				}
			case Coords(posArr):
				{
					for (vec4 in posArr) {
						if (content.readExisting().has(vec4.x, vec4.y, vec4.z, vec4.w)) {
							this.deepRemove(content.readExisting().get(vec4.x, vec4.y, vec4.z, vec4.w));
						}
						var newObj = content.smudge().get(vec4.x, vec4.y, vec4.z, vec4.w);
						if (newObj != null) {
							newObj.setPosition(vec4.x * (style.cellSize + style.margin), vec4.y * (style.cellSize + style.margin));
							this.addChildToGroup(newObj, getGroupById(vec4.w), zToDepth(vec4.z));
						}
					}
				}
			case Layer(layerZ, group):
				{
					content.readExisting().forEach((x, y, z, g, item) -> {
						if (z == layerZ && getGroupById(g) == group) {
							this.deepRemove(item);
							var newObj = content.smudge().get(x, y, z, g);
							if (newObj != null) {
								newObj.setPosition(x * (style.cellSize + style.margin), y * (style.cellSize + style.margin));
								this.addChildToGroup(newObj, group, zToDepth(z));
							}
						}
					});
				}
			case Layers(zs, group):
				{
					content.readExisting().forEach((x, y, z, g, item) -> {
						if (zs.contains(z) && getGroupById(g) == group) {
							this.deepRemove(item);
							var newObj = content.smudge().get(x, y, z, g);
							if (newObj != null) {
								newObj.setPosition(x * (style.cellSize + style.margin), y * (style.cellSize + style.margin));
								this.addChildToGroup(newObj, group, zToDepth(z));
							}
						}
					});
				}
			case Group(group):
				{
					content.readExisting().forEach((x, y, z, g, item) -> {
						if (getGroupById(g) == group) {
							this.deepRemove(item);
							var newObj = content.smudge().get(x, y, z, g);
							if (newObj != null) {
								newObj.setPosition(x * (style.cellSize + style.margin), y * (style.cellSize + style.margin));
								this.addChildToGroup(newObj, group, zToDepth(z));
							}
						}
					});
				}
			case Full:
				{
					content.readExisting().forEach((x, y, z, g, item) -> {
						this.deepRemove(item);
						var newObj = content.smudge().get(x, y, z, g);
						if (newObj != null) {
							newObj.setPosition(x * (style.cellSize + style.margin), y * (style.cellSize + style.margin));
							this.addChildToGroup(newObj, getGroupById(g), zToDepth(z));
						}
					});
				}
		}

		var bounds = this.getBounds();
		interactive.width = bounds.width;
		interactive.height = bounds.height;

		content.commit();
	}

	public function getAllObjects(cb:(x:Int, y:Int, z:Int, group:String, obj:h2d.Object) -> Void) {
		content.readExisting().forEach((x, y, z, g, item) -> {
			var group = getGroupById(g);
			cb(x, y, z, group, item);
		});
	}

	private function drawGrid(currentGridDims:IVec2):Void {
		if (gridLines == null) {
			gridLines = new h2d.Graphics();
			addGroup("gridLines", Highest);
			this.setCellObject(0, 0, 0, "gridLines", gridLines);
		}

		gridLines.clear();
		gridLines.lineStyle(1, 0x000000);

		var currentX:Int = 0;
		var currentY:Int = 0;

		currentGridDims = currentGridDims.clone();
		currentGridDims.x = Std.int(Math.max(currentGridDims.x, style.minGridWidth));
		currentGridDims.y = Std.int(Math.max(currentGridDims.y, style.minGridHeight));

		for (i in 0...currentGridDims.x) {
			currentX = i * (style.cellSize + style.margin);

			for (j in 0...currentGridDims.y) {
				currentY = j * (style.cellSize + style.margin);

				gridLines.moveTo(currentX, currentY);
				gridLines.lineTo(currentX + style.cellSize, currentY);

				gridLines.moveTo(currentX, currentY);
				gridLines.lineTo(currentX, currentY + style.cellSize);

				gridLines.moveTo(currentX, currentY + style.cellSize);
				gridLines.lineTo(currentX + style.cellSize, currentY + style.cellSize);

				gridLines.moveTo(currentX + style.cellSize, currentY);
				gridLines.lineTo(currentX + style.cellSize, currentY + style.cellSize);
			}
		}

		gridLines.endFill();
	}

	var batchUpdating:Bool = false;

	public function batchUpdate(cb:() -> Void) {
		batchUpdating = true;
		cb();
		batchUpdating = false;
		var changes:Array<IVec4> = Nulls.mapGetDefault(content.changesContext, "Changed", []);
		rerender(Coords(Nulls.mapGetDefault(content.changesContext, "Changed", [])));
	}

	public function clear(scope:GridRerenderScope):Void {
		switch scope {
			case Coord(x, y, z, group):
				if (content.readExisting().has(x, y, z, getGroupId(group))) {
					var obj = content.readExisting().get(x, y, z, getGroupId(group));
					this.removeChild(obj);
					content.smudge().remove(x, y, z, getGroupId(group));
				}
			case Coords(posArr):
				for (vec4 in posArr) {
					if (content.readExisting().has(vec4.x, vec4.y, vec4.z, vec4.w)) {
						var obj = content.readExisting().get(vec4.x, vec4.y, vec4.z, vec4.w);
						this.removeChild(obj);
						content.smudge().remove(vec4.x, vec4.y, vec4.z, vec4.w);
					}
				}
			case Layer(z, group):
				content.readExisting().forEach((x, y, layerZ, w, item) -> {
					if (layerZ == z && w == getGroupId(group)) {
						this.removeChild(item);
						content.smudge().remove(x, y, layerZ, getGroupId(group));
					}
				});
			case Layers(zs, group):
				content.readExisting().forEach((x, y, layerZ, w, item) -> {
					if (zs.contains(layerZ) && w == getGroupId(group)) {
						this.removeChild(item);
						content.smudge().remove(x, y, layerZ, w);
					}
				});
			case Group(g):
				{
					content.readExisting().forEach((x, y, layerZ, w, item) -> {
						if (w == getGroupId(g)) {
							this.removeChild(item);
							content.smudge().remove(x, y, layerZ, w);
						}
					});
				}
			case Full:
				content.readExisting().forEach((x, y, z, g, item) -> {
					this.removeChild(item);
				});
				content.smudge().clear();
		}
		rerender(scope);
	}

	public function setCellObject(x:Int, y:Int, z:Int, group:String, obj:h2d.Object):Void {

		switch getMaxDimensions() {
			case Some(v):
				{
					if (x >= v.x || y >= v.y) {
						return;
					}
				}
			case None:
		}

		content.smudge().add(x, y, z, getGroupId(group), obj);
		Nulls.mapGetDefault(content.changesContext, "Changed", []).push(new IVec4(x, y, z, getGroupId(group)));
		rerender(Coord(x, y, z, group));
	}

	private function getMaxDimensions():Option<IVec2> {
		if (this.style.maxGridHeight != null && this.style.maxGridHeight != None && Options.get(this.style.maxGridHeight) > 0) {
			if (this.style.maxGridWidth != null && this.style.maxGridWidth != None && Options.get(this.style.maxGridWidth) > 0) {
				return Some(new IVec2(Options.get(this.style.maxGridWidth), Options.get(this.style.maxGridHeight)));
			}
		}
		return None;
	}

	private function zToDepth(z:Int):Int {
		// used to determine what layer the object will be on, for now it is just z
		return z;
	}

	public function onGridEvent(handler:(GridInteractiveEvent) -> Void):Void {
		handlers.push(handler);
	}

	private function initializeInteraction() {
		var isHovering = false;
		var lastX:Int = -1;
		var lastY:Int = -1;

		interactive.onPush = function(e:hxd.Event):Void {
			var col = Std.int(e.relX / style.cellSize);
			var row = Std.int(e.relY / style.cellSize);
			dispatchEvent(MouseDown(col, row));
		}

		interactive.onRelease = function(e:hxd.Event):Void {
			var col = Std.int(e.relX / style.cellSize);
			var row = Std.int(e.relY / style.cellSize);
			dispatchEvent(MouseUp(col, row));
		}

		interactive.onMove = function(e:hxd.Event):Void {
			var col = Std.int(e.relX / style.cellSize);
			var row = Std.int(e.relY / style.cellSize);
			if (col != lastX || row != lastY) {
				dispatchEvent(MouseOut(lastX, lastY));
				lastX = col;
				lastY = row;
				dispatchEvent(MouseOver(col, row));
			}
		}

		interactive.onOut = function(e:hxd.Event):Void {
			if (lastX != -1 && lastY != -1) {
				dispatchEvent(MouseOut(lastX, lastY));
			}
		}
	}

	private function dispatchEvent(event:GridInteractiveEvent) {
		for (handler in handlers) {
			handler(event);
		}
	}
}

enum GridInteractiveEvent {
	MouseOver(x:Int, y:Int);
	MouseOut(x:Int, y:Int);
	MouseUp(x:Int, y:Int);
	MouseDown(x:Int, y:Int);
}

enum GridRerenderScope {
	Coord(x:Int, y:Int, z:Int, group:String);
	Coords(posArr:Array<IVec4>);
	Layer(z:Int, group:String);
	Layers(zs:Array<Int>, group:String);
	Group(group:String);
	Full;
}

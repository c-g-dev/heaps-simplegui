
import heaps.simplegui.components.widget.DraggableWindow;
import heaps.simplegui.components.display.ListView;
import heaps.simplegui.components.display.TreeView;
import heaps.simplegui.components.control.GridInteractive;
import heaps.simplegui.components.control.GridInteractive;
import heaps.simplegui.util.ChordListener;
import heaps.simplegui.util.DoubleClickListener;
import heaps.simplegui.components.container.ScrollView;
import heaps.simplegui.components.form.Form;
import heaps.simplegui.components.action.Resizable;
import heaps.simplegui.components.container.XFlow;
import heaps.simplegui.components.action.DragDrop.ShadowDrag;
import heaps.simplegui.components.util.InvisibleBox;
import heaps.simplegui.components.action.DragDrop.MoveDrag;
import h2d.Interactive;
import heaps.simplegui.components.widget.Border;
import heaps.simplegui.components.action.DragDrop.DropZone;
import heaps.simplegui.util.Make;
import heaps.simplegui.components.container.TabContainer;
import heaps.simplegui.components.container.XFlow2D;
import heaps.simplegui.components.util.Toast;
import hxd.Window;
import h2d.Bitmap;
import hxd.Res;

class TestDisplay extends hxd.App {
	public override function init() {
		Res.initEmbed();

		var tabContainer = new TabContainer(Window.getInstance().width, Window.getInstance().height);
		s2d.addChild(tabContainer);

		function addTab(label:String, cb:() -> h2d.Object) {
			tabContainer.addTab(label, cb());
		}

		addTab("Buttons", () -> {
			return new XFlow2D([
				Padding(10),
				Row([
					Make.text.black("Button: "),
					Make.controls.button("Click Me", () -> {
						Toast.make("Clicked", 500, s2d);
					})
				], [Spacing(2), Padding(2)]),
				Padding(10),
				Row([
					Make.text.black("Image Button: "),
					Make.controls.imageButton(Res.sunflower.toTile(), () -> {
						Toast.make("Sunflower clicked", 500, s2d);
					})
				], [Spacing(2), Padding(2)])
			]);
		});

		function obj(cb:Void->h2d.Object):h2d.Object {
			return cb();
		}

		addTab("Drag", () -> {
			return new XFlow2D([
				Padding(10),
				Row([
					Make.text.black("Drop zone: "),
					obj(() -> {
						var bmp = new Bitmap(Res.eva.toTile());
						bmp.width = 200;
						bmp.height = 200;
						var drop = new DropZone(200, 200);
						drop.addChild(new Border({
							thickness: 1,
							size: Absolute(200, 200),
							color: Single(0x000000)
						}));
						drop.onDrop = (v, x, y) -> {
                            if(tabContainer.getTab() == "Drag"){
                                Toast.make("your dad loves you!", 500, s2d);
                            }
						}
						bmp.addChild(drop);
						return bmp;
					}),
					new InvisibleBox(100, 1),
					obj(() -> {
						var v = new XFlow(Vertical);
						var img = new Bitmap(Res.shinji.toTile());
						img.width = 100;
						img.height = 100;
						var i = new Interactive(100, 100);
						img.addChild(i);
						var drag = new MoveDrag(i);
						drag.dropValue = {
							type: "shinji",
							val: "x"
						};
						img.addChild(drag);
						v.addChild(Make.text.black("Move drag:"));
						v.addChild(img);
						return v;
					}),
					new InvisibleBox(100, 1),
					obj(() -> {
						var v = new XFlow(Vertical);
						var img = new Bitmap(Res.shinji.toTile());
						img.width = 100;
						img.height = 100;
						var i = new Interactive(100, 100);
						img.addChild(i);
						var drag = new ShadowDrag(i);
						drag.dropValue = {
							type: "shinji",
							val: "x"
						};
						img.addChild(drag);
						v.addChild(Make.text.black("Shadow drag:"));
						v.addChild(img);
						return v;
					})
				], [Spacing(2), Padding(2)])
			]);
		});

        addTab("Panel", () -> {
			return new XFlow2D([
				Padding(10),
				Row([
					obj(() -> {
                        var dw = new DraggableWindow(500, 300, "Drag me");
                        return dw;
                    })
				], [Spacing(2), Padding(2)])
			]);
		});

		addTab("Resize", () -> {
			return new XFlow2D([
				Padding(10),
				Row([
					Make.text.black("    Try resizing:"),
					new InvisibleBox(200, 100),
					obj(() -> {
						var r = new Resizable(100, 100, Resizable.ALL_AREAS);
						var b = new Bitmap(Res.car.toTile());
						b.width = 100;
						b.height = 100;
						r.setNewBounds = (newBounds) -> {
							b.width = newBounds.width;
							b.height = newBounds.height;
						};
						r.alpha = 0.5;
						r.addChild(b);
						return r;
					})
				], []),

			]);
		});

		addTab("Form", () -> {
			return new XFlow2D([
				Padding(10),
				Row([
					obj(() -> {
						var scroll = new ScrollView(Window.getInstance().width - 2, Window.getInstance().height - 30);
						var vert = new XFlow(Vertical);
						vert.addChild(new Form([
							FormFields.string("Test string"),
							FormFields.int("Test int"),
							FormFields.file("Test file"),
							FormFields.spreadsheet("Test spreadsheet", [FormFields.string("Col 1"), FormFields.string("Col 2")]),
							FormFields.array("Test array", ["Field"]),
							FormFields.dropdown("Test dropdown", ["Val 1", "Val 2", "Val 3"]),
						]));
						vert.addChild(new InvisibleBox(2, 50));
						scroll.addChild(vert);
						return scroll;
					})
				], [])
			]);
		});

		addTab("Grid", () -> {
			return new XFlow2D([
				Padding(10),
				Row([
                    new InvisibleBox(100, 100),
					obj(() -> {
						var grid = new GridInteractive({
                            minGridHeight: 5,
                            minGridWidth: 5,
                            maxGridHeight:  Some(5),
                            maxGridWidth:  Some(5)
                        });
                        grid.addGroup("content", Normal);
                        
                        var bmp = new Bitmap(Res.shinji.toTile());
                        bmp.width = 50;
                        bmp.height = 50;
                        grid.setCellObject(2,2,0, "content", bmp);

                        var bmp2 = new Bitmap(Res.shinji.toTile());
                        bmp2.width = 50;
                        bmp2.height = 50;
                        grid.setCellObject(4,4,0, "content", bmp2);

                        grid.onGridEvent((e) -> {
                            switch e {
                                case MouseDown(x, y): {
                                    Toast.make(x + ", " + y + " clicked", 500, s2d);
                                }
                                default:
                            }
                        });

                        return grid;
					})
				], [])
			]);
		});

        addTab("Tree", () -> {
			return new XFlow2D([
				Padding(10),
				Row([
					obj(() -> {
                        var root = new TreeNode("tree d1", "", true);
                        var d1 = new TreeNode("tree d2", "", true);
                        d1.addChild(new TreeNode("tree d3", "", false));
                        d1.addChild(new TreeNode("tree d3 2", "", false));
                        root.addChild(d1);
                        root.addChild(new TreeNode("tree d2 2", "", false));
                        var tree = new TreeView(root, {
                            textColor: 0x000000
                        });
                        return tree;
                    })
				], [Spacing(2), Padding(2)])
			]);
		});

        addTab("List", () -> {
			return new XFlow2D([
				Padding(10),
				Row([
					obj(() -> {
                        var listView = new ListView();
                        listView.addItem("item 1", null);
                        listView.addItem("item 2", null);
                        listView.addItem("try deleting me", null);
                        listView.addItem("item 4", null);
                        listView.addItem("item 5", null);
                        listView.addItem("you can also", null);
                        listView.addItem("drag to change order", null);
                        return listView;
                    })
				], [Spacing(2), Padding(2)])
			]);
		});

		addTab("Util", () -> {
			return new XFlow2D([
				Padding(10),
				Row([
					obj(() -> {
						var chords = new ChordListener();
						chords.addChord("testchord", [hxd.Key.CTRL, hxd.Key.V], () -> {
							if (tabContainer.getTab() == "Util") {
								Toast.make("Chord activated", 500, s2d);
							}
						});
						return Make.text.black("Try CTRL+V");
					})
				], []),
				Row([
					obj(() -> {
						var dcl = new DoubleClickListener<Dynamic>((_) -> {
							Toast.make("Single click", 500, s2d);
						}, (_) -> {
							Toast.make("Double click", 500, s2d);
						});
						return Make.controls.button("Single/Double click", () -> {
							dcl.consumeClick(null);
						});
					})
				], []),
			]);
		});

	}

	public static function main() {
		new TestDisplay();
	}
}

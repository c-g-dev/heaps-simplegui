# heaps-simplegui

A kit of simple, portable Heaps.io gui components.

These components are not meant to be aesthetic and are largely not stylable out of the box. They are meant for bootstrapping simple GUIs and easy prototyping. The most important goal of these components is *portability*. As far as I know, everything in this library can be easily copy pasted into any existing Heaps project. They are built on simple standard Heaps building blocks and don't do any voodoo.

## Why not just use HaxeUI?
I love HaxeUI but it has a major integration requirements to use in Heaps. You can't even bring your own App class, you have to use the HaxeUI packaged App. The API of the components clashes confusingly with the Heaps Object API. Also using the HaxeUI elements is surprisingly complicated and somewhat under documented. It is a lot of hurdles to jump through just to render a *Button*.

Like I said, these components are meant for simple bootstrapping and prototyping. If you are making a serious GUI that you actually want to look nice, use HaxeUI.

## Components

- `heaps.simplegui.components.action.DragDrop`
  
        Component for dragging and dropping. Can drag with movement or drag with shadow.

- `heaps.simplegui.components.action.Resizable`
  
        Drag the edges to change the bounds, listen to the bounds change.

- `heaps.simplegui.components.container.ScrollView`
  
        Custom implementation of a scrolling overflow container. It seems like the standard Heaps lib's Flow class doesn't actually allow for horizontal scrolling. This one will scroll overflow in both directions. Check the code to see how to change the scrollbar graphics.

- `heaps.simplegui.components.container.TabContainer`
  
        Tabs at the top, content at the bottom. Self explanitory.

- `heaps.simplegui.components.container.Viewport`
  
        Masks its content to a specific width/height AND overloads getBounds() to not report child bounds beyond that width/height.

- `heaps.simplegui.components.container.XFlow`
  
        A simpler implementation of h2d.Flow which just aligns its children either vertically or horizontally. 

- `heaps.simplegui.components.container.XFlow2D`
  
        A way to easily align stacked rows of content.

- `heaps.simplegui.components.container.Zoomable`
  
        A container that lets you zoom in and out of its children.

- `heaps.simplegui.components.container.ZoomableScrollView`
  
        Zoom AND scroll on content. You'd think it would be trivial to combine the two functionalities but it needed its own specific implementation.

- `heaps.simplegui.components.control.ArrayControl`
  
        Simple control to define a list of string inputs. Any number of columns.

- `heaps.simplegui.components.control.ChooseFileInput`
  
        Behaves like the the HTML file input element.

- `heaps.simplegui.components.control.GridInteractive`
  
        This is an advanced control that lets you create a grid and listen to inputs on the cells. This is a 4-D container: you define the x/y cell positions, the z layer index, AND the "layer group". 

- `heaps.simplegui.components.control.InputField`
  
        Simple wrapper for the Heaps TextInput class which can be used without extra configuration.

- `heaps.simplegui.components.control.ListDropdown`
  
        A choosable dropdown list of strings.

- `heaps.simplegui.components.control.Spreadsheet`
  
        This is like ArrayControl except you can use different controls as the cell inputs.

- `heaps.simplegui.components.display.TreeView`

        Display a collapsable tree of nodes. Optional drag/drop integration built in.

- `heaps.simplegui.components.display.LazyTreeView`
  
        Like TreeView, except the child nodes of an expandable directory are not created until requested.

- `heaps.simplegui.components.display.ListView`
  
        A list of labels which can be removed or dragged.

- `heaps.simplegui.components.enhancement.Dropdown`
  
        An enhancement of the built-in Dropdown which seems to have bugs/is missing core functionality.

- `heaps.simplegui.components.enhancement.LayerGroups`
  
        An advanced container that allows you to define "layer groups", i.e. a map of String->Layers with configured rendered priorities.

- `heaps.simplegui.components.form.Form`
  
        Create a form with a set of fields. Supports optional validation on the values.

- `heaps.simplegui.components.hl.FileChooser`
  
        HL target only. A barebones file browser. Define the directory and it displays a LazyTreeView of the files, which can be manually traversed up and down the file system. Why make this when there is a better native solution? Because the build in Hashlink file dialog at hl.UI *does not let you select folders on Windows*. This is due to the core Hashlink code calling a specific Windows API which does not allow folder selection. This also has drag/drop integration built in, so you could just use it in a GUI for that.

- `heaps.simplegui.components.hl.ImagePreview`
  
        HL target only. Given a path to an image file, display that image.

- `heaps.simplegui.components.popup.Popup`
  
        Display popup with Ok/Cancel buttons in the center of the window.

- `heaps.simplegui.components.util.DimensionBinder`
  
        An attachable non-graphics component which lets you listen to dimension changes of different entities and bind them to this object's parent.

- `heaps.simplegui.components.util.GhostObject`
  
        Base class for non-graphics components.

- `heaps.simplegui.components.util.InvisibleBox`
  
        Just dead space. Useful for adding spacing when calculating bounds.

- `heaps.simplegui.components.util.Toast`
  
        Fade in/Fade out a Toast in the center of the screen.

- `heaps.simplegui.components.widget.Background`
  
        Configure a background and bind it to an element/scene.

- `heaps.simplegui.components.widget.Border`
  
        Configure a border and bind it to an element.

- `heaps.simplegui.components.widget.Button`
  
        A simple button with an onClick callback. Works exactkt how you would expect it to.

- `heaps.simplegui.components.widget.DraggableWindow`
  
        A panel that can be dragged/minimized/normalized/deleted.

- `heaps.simplegui.components.widget.DroppableListPanel`
  
        A panel holding a ListView with drag/drop integration. Drop items to add to the list.

- `heaps.simplegui.components.widget.ImageButton`
  
        A simple button, but instead of text, supply a Tile.

- `heaps.simplegui.components.widget.LineBreak`
  
        A line of bindable length.

- `heaps.simplegui.components.widget.Panel`
  
        A configurable box. Optional headers/footers, among other things.

- `heaps.simplegui.components.widget.XPBox`
  
        An even simpler box. Just a simple way to create a grey box with a black border.

- `heaps.simplegui.util.ChordListener`
  
        Listen to multiple keys pressed at once.

- `heaps.simplegui.util.DoubleClickListener`
  
        Listen for double clicks.

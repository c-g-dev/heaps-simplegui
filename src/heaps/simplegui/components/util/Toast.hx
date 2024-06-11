package heaps.simplegui.components.util;

import ludi.commons.collections.Queue;
import hxd.res.DefaultFont;

class Toast extends h2d.Object {
	private static var queuedToasts:Queue<Toast> = new Queue();
	private static var isShowing:Bool = false;

	private var message:String;
	private var duration:Int;
	private var text:h2d.Text;
	private var background:h2d.Graphics;

	public function new(message:String, duration:Int) {
		super();
		this.message = message;
		this.duration = duration;

		text = new h2d.Text(DefaultFont.get());
		text.textColor = 0xffffff;
		text.text = message;
		text.setPosition(10, 10);

		var textWidth = text.calcTextWidth(text.text);
		var textHeight = text.textHeight;

		background = new h2d.Graphics();
		background.beginFill(0x000000, 0.7);
		background.drawRect(0, 0, textWidth + 20, textHeight + 20);
		background.endFill();

		addChild(background);
		addChild(text);
	}

	public static function make(message:String, duration:Int, parent:h2d.Object) {
		var toast = new Toast(message, duration);
        toast.visible = false;
		parent.addChild(toast);
		queuedToasts.push(toast);

		if (!isShowing) {
			showNextToast();
		}
	}

	private static function showNextToast():Void {
		if (!queuedToasts.isEmpty()) {
			isShowing = true;
			var toast = queuedToasts.pop();
			toast.show();
		} else {
			isShowing = false;
		}
	}

	public function show() {
		var parentBounds = this.parent.getBounds();
		var thisBounds = this.getBounds();

		var parentWidth = parentBounds.width;
		var parentHeight = parentBounds.height;

		this.x = Std.int((parentWidth - thisBounds.width) / 2);
		this.y = Std.int((parentHeight - thisBounds.height) / 2);

		this.alpha = 0;
		this.setVisible(true);

		fadeIn(() -> {
			haxe.Timer.delay(() -> {
				fadeOut(() -> {
					this.setVisible(false);
					this.remove();
					showNextToast();
				});
			}, duration);
		});
	}

	function setVisible(val:Bool) {
		this.visible = val;
	}

	private function fadeIn(callback:Void->Void):Void {
		var steps = 32;
		var stepDuration = Std.int(duration / steps);
		var step = 0;

		function incrementFade():Void {
			step++;
			this.alpha = step / steps;
			if (step < steps) {
				haxe.Timer.delay(incrementFade, stepDuration);
			} else {
				callback();
			}
		}

		incrementFade();
	}

	private function fadeOut(callback:Void->Void):Void {
		var steps = 32;
		var stepDuration = Std.int(duration / steps);
		var step = steps;

		function decrementFade():Void {
			step--;
			this.alpha = step / steps;
			if (step > 0) {
				haxe.Timer.delay(decrementFade, stepDuration);
			} else {
				callback();
			}
		}

		decrementFade();
	}
}
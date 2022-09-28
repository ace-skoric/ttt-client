extends Label

enum Mode {
	NORMAL,
	WARNING,
	ERROR
};

func create(txt, mode=Mode.NORMAL):
	var clone = duplicate();
	get_parent().add_child(clone);
	clone.position = position;
	clone.label.text = txt;
	if mode == Mode.NORMAL:
		clone.label.set("custom_colors/font_color", "#ffffff");
	elif mode == Mode.WARNING:
		clone.label.set("custom_colors/font_color", "#ffff88");
	elif mode == Mode.ERROR:
		clone.label.set("custom_colors/font_color", "#ff8888");
	clone.visible = true;
	clone.start_tween();

func start_tween():
	var tween: Tween = create_tween();
	tween.parallel().tween_property(
		self,
		"position",
		Vector2(position.x, 210),
		1.5
	);
	tween.parallel().tween_property(
		self,
		"scale",
		Vector2(0.8, 0.8),
		1.5
	);
	tween.parallel().tween_property(
		self,
		"modulate",
		Color.TRANSPARENT,
		2
	);
	tween.play();
	await tween.finished;
	queue_free();

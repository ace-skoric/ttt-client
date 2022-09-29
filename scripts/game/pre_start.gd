extends Control

signal finished

@onready var label: Label = $Container/Label;
@onready var sgn: Label = $Container/Sign;

func display(s: int) -> void:
	visible = true;
	match s:
		0: 
			sgn.text = "X";
			sgn.add_theme_color_override("font_color", Color("#8ce2ff"));
		1: 
			sgn.text = "O";
			sgn.add_theme_color_override("font_color", Color("#ff6184"));
	var tween: Tween = create_tween();
	tween.set_trans(Tween.TRANS_QUAD);
	tween.tween_property(
		label,
		"theme_override_font_sizes/font_size",
		94,
		0.7
	);
	tween.tween_property(
		sgn,
		"theme_override_font_sizes/font_size",
		170,
		0.7
	);
	tween.finished.connect(emit_signal.bind("finished"));

func fade_away() -> void:
	var tween: Tween = create_tween();
	tween.set_trans(Tween.TRANS_EXPO);
	tween.tween_property(
		self,
		"modulate",
		Color(0,0,0,0),
		0.3
	);
	tween.finished.connect(queue_free);
	
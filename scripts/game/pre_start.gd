extends Control

signal finished

@onready var label: Label = $Container/Label;
@onready var sgn: Label = $Container/Sign;

func display(s: String) -> void:
	visible = true;
	match s:
		"X": 
			sgn.text = "X";
			sgn.add_theme_color_override("font_color", Color("#74c7ec"));
		"O": 
			sgn.text = "O";
			sgn.add_theme_color_override("font_color", Color("#f2cdcd"));
	sgn.add_theme_font_size_override("font_size", 1);
	var tween: Tween = create_tween();
	tween.set_trans(Tween.TRANS_EXPO);
	tween.tween_property(
		label,
		"theme_override_font_sizes/font_size",
		94,
		0.5
	).from(1);
	tween.tween_property(
		sgn,
		"theme_override_font_sizes/font_size",
		170,
		0.5
	).from(1);
	await tween.finished;
	await get_tree().create_timer(1).timeout;
	finished.emit();

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
	
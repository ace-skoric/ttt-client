extends Panel

@onready var label: Label = $Container/Label;
@onready var ok_btn: Button = $Container/Ok;
var tween: Tween;

func _ready() -> void:
	ok_btn.pressed.connect(MainController.change_scene.bind("main_menu"));

func enter(txt: String) -> void:
	self.visible = true;
	label.text = txt;
	ok_btn.modulate = Color(0,0,0,0);
	match txt:
		"Victory!": label.add_theme_color_override("font_color", Color("#a6e3a1"));
		"Defeat": label.add_theme_color_override("font_color", Color("#f38ba8"));
		_: label.add_theme_color_override("font_color", Color("#b4befe"));
	if tween:
		tween.kill();
	tween = create_tween();
	tween.tween_property(
		label,
		"theme_override_font_sizes/font_size",
		94,
		1.5
	).set_trans(Tween.TRANS_ELASTIC);
	tween.tween_property(
		ok_btn,
		"modulate",
		Color("#b4befe"),
		1
	).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT);
	tween.play();


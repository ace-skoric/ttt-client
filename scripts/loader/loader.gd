@tool
extends TextureRect

var tween: Tween;

func _ready() -> void:
	rotation = 0;
	tween = create_tween();
	tween.set_loops();
	tween.set_trans(Tween.TRANS_EXPO);
	tween.tween_property(
		self,
		"rotation",
		6.28318977355957,
		2.5
	);
	tween.loop_finished.connect(func(_loop): rotation = 0);
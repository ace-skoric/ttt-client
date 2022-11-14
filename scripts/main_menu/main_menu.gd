extends VBoxContainer

@onready var play_btn: Button = $Play;
@onready var profile_btn: Button = $Profile;
@onready var sign_out_btn: Button = $SignOut;
@onready var quit_btn: Button = $Quit;

func _ready() -> void:
	play_btn.pressed.connect(enter_matchmaking);
	sign_out_btn.pressed.connect(HttpController.sign_out);
	profile_btn.pressed.connect(MainController.change_scene.bind("profile"));
	if OS.get_name() == "Web":
		quit_btn.visible = false;
	if OS.get_name() != "Web":
		quit_btn.pressed.connect(get_tree().quit);
	
func enter_matchmaking() -> void:
	var matchmaking: Matchmaking = load("res://scenes/matchmaking.tscn").instantiate(); 
	get_parent().add_child(matchmaking);

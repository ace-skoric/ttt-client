extends Node

signal scene_changed

var username: String = "";
var guest: bool = false;
var admin: bool = false;

var current_scene: Node;
var scene_paths: Dictionary = {
	"login_menu": "res://scenes/login_menu.tscn",
	"login": "res://scenes/login.tscn",
	"sign_up": "res://scenes/sign_up.tscn",
	"main_menu": "res://scenes/main_menu.tscn",
	"profile": "res://scenes/profile.tscn",
	"game": "res://scenes/game.tscn",
}

func _ready():
	current_scene = get_tree().root.get_node("Startup");

func on_sign_out():
	username = "";
	guest = false;
	admin = false;
	HttpRequester.delete_cookie_file();
	change_scene("login_menu");

func on_sign_in():
	get_session_data();
	change_scene("main_menu");

func get_session_data():
	var res: HttpResponse = await HttpController.get_session_data();
	username = res.data["username"];
	guest = res.data["guest"];
	admin = res.data["admin"];

func change_scene(scene: String) -> void:
	var scene_path = scene_paths[scene];
	var emitter: SceneLoader.SignalEmitter = SceneLoader.load_scene(scene_path);
	emitter.scene_loaded.connect(swap_scene, CONNECT_ONE_SHOT);
	
func claim_account() -> void:
	change_scene("sign_up");
	await scene_changed;
	current_scene.claim_account = true;
	current_scene.username.text = username;
	
func swap_scene(new_scene: Node) -> void:
	current_scene.add_sibling(new_scene);
	new_scene.position = current_scene.position;
	current_scene.queue_free();
	current_scene = new_scene;
	scene_changed.emit();

func create_game(game_id: String) -> void:
	change_scene("game");
	await scene_changed;
	var game = current_scene;
	game.game_id = game_id;

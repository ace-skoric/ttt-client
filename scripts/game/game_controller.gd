class_name GameController
extends Control

var game_id: String:
	set(uuid):
		game_id = uuid;
		connect_to_server(uuid);

var game_state: Dictionary = {
	"winner": "none",
	"board": [null, null, null, null, null, null, null, null, null],
	"state": "created",
	"turn_player": "none",
	"your_data": {
		"username": "YourUsername",
		"elo": 1200,
		"sign": "X"
	},
	"opp_data": {
		"username": "OppUsername",
		"elo": 1200,
		"sign": "O"
	}
}:
	set(state):
		game_state = state;
		game_display.display(game_state);

var start_ready: bool = false;

@onready var game_display := $GameDisplay;
@onready var loader: Panel = $Loader;
@onready var endgame: Panel = $Endgame;
@onready var pre_start: Control = $PreStart;
@onready var socket: WebSocketClient;

func _ready() -> void:
	game_display.display(game_state);
	game_display.visible = false;
	endgame.visible = false;
	pre_start.visible = false;
	loader.visible = true;
	
func start() -> void:
	if not start_ready:
		await pre_start.finished;
		start_ready = true;
	pre_start.fade_away();
	game_display.played.connect(play);
	game_display.hovered.connect(hover);
	game_display.unhovered.connect(unhover);
	game_display.resigned.connect(resign);
	endgame.visible = false;
	
func starting() -> void:
	set_process(true);
	loader.queue_free();
	game_display.visible = true;
	pre_start.display(game_state["your_data"]["sign"]);
	pre_start.finished.connect(func(): start_ready = true);

func play(i: int) -> void:
	var msg: String = '{"cmd":"play","msg":%d}' % i;
	socket.send(msg);

func hover(i: int) -> void:
	var msg: String = '{"cmd":"hover","msg":%d}' % i;
	socket.send(msg);

func unhover(i: int) -> void:
	var msg: String = '{"cmd":"unhover","msg":%d}' % i;
	socket.send(msg);

func get_game_state() -> void:
	const msg: String = '{"cmd":"get_game_state"}';
	socket.send(msg);

func resign() -> void:
	const msg: String = '{"cmd":"resign"}';
	socket.send(msg);

func get_timers() -> void:
	const msg: String = '{"cmd":"get_timers"}';
	socket.send(msg);

func connect_to_server(uuid: String) -> void:
	socket = WebSocketController.connect_to_url("game/%s" % uuid);
	socket.message_received.connect(on_command);

func on_command(command) -> void:
	if typeof(command) != TYPE_STRING:
		return
	var cmd = HttpRequester.parse_body(command);
	if typeof(cmd) == TYPE_DICTIONARY:
		match cmd["cmd"]:
			"error": print(cmd["msg"]);
			"game_status": 
				match cmd["msg"]:
					"starting": starting();
					"started": start();
					_: print(cmd["msg"]);
			"game_state": self.game_state = cmd["msg"];
			"you_play": game_display.set_field_text(game_state["your_data"]["sign"], cmd["msg"]);
			"opp_play": game_display.set_field_text(game_state["opp_data"]["sign"], cmd["msg"]);
			"turn_player":
				game_state["turn_player"] = cmd["msg"];
				game_display.set_turn_player(cmd["msg"]);
			"opp_hover": game_display.opp_hover(cmd["msg"]);
			"opp_unhover": game_display.opp_unhover(cmd["msg"]);
			"game_result": end_game(cmd["msg"]);
			"time": game_display.set_timers(cmd["msg"]);
			_: print(cmd);
	else:
		print(cmd);
	
func end_game(msg: String):
	set_process(false);
	socket.message_received.disconnect(on_command);
	await game_display.draw_lines(game_state);
	endgame.enter(msg);

func _process(_delta: float) -> void:
	get_timers();

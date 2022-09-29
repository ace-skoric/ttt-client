class_name GameController
extends Control

enum Winner {
	YOU = 0,
	OPPONENT = 1,
	DRAW = 2,
	NONE = -1
}

enum Player {
	YOU = 0,
	OPPONENT = 1,
	NONE = -1
}

enum Sign {
	X = 0,
	O = 1
}

enum State {
	CREATED = 0,
	STARTING = 1,
	RUNNING = 2,
	ENDED = 3
}

enum Command {
	PLAY,
	HOVER,
	UNHOVER,
	GET_TURN_PLAYER,
	GET_GAME_STATE,
	GET_TIMERS,
	RESIGN
}

var game_id: String:
	set(uuid):
		game_id = uuid;
		connect_to_server(uuid);

var game_state: Dictionary = {
	"winner": Winner.NONE,
	"board": [null, null, null, null, null, null, null, null, null],
	"state": State.CREATED,
	"turn_player": Player.NONE,
	"your_data": {
		"username": "YourUsername",
		"elo": 1200,
		"sign": Sign.X
	},
	"opp_data": {
		"username": "OppUsername",
		"elo": 1200,
		"sign": Sign.O
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
@onready var ws: WsClient = $WsClient;

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
	ws.send("{} {}".format([Command.PLAY, i], "{}"));

func hover(i: int) -> void:
	ws.send("{} {}".format([Command.HOVER, i], "{}"));

func unhover(i: int) -> void:
	ws.send("{} {}".format([Command.UNHOVER, i], "{}"));

func get_gamestate() -> void:
	ws.send(str(Command.GET_GAME_STATE));

func resign() -> void:
	ws.send(str(Command.RESIGN));

func get_timers() -> void:
	ws.send(str(Command.GET_TIMERS));

func connect_to_server(uuid: String) -> void:
	ws.out_of_reconnects.connect(Globals.change_scene.bind("main_menu"));
	ws.on_data.connect(on_command);
	ws.start("game/%s" % uuid);

func on_command(command: String) -> void:
	var cmd = HttpRequester.parse_body(command);
	if typeof(cmd) == TYPE_DICTIONARY:
		match cmd["cmd"]:
			"error": print(cmd["msg"]);
			"starting": starting();
			"started": start();
			"game_state": self.game_state = HttpRequester.parse_body(cmd["msg"]);
			"you_play": game_display.set_field_text(game_state["your_data"]["sign"], cmd["msg"].to_int());
			"opp_play": game_display.set_field_text(game_state["opp_data"]["sign"], cmd["msg"].to_int());
			"turn_player":
				game_state["turn_player"] = cmd["msg"];
				game_display.set_turn_player(cmd["msg"].to_int());
			"opp_hover": game_display.opp_hover(cmd["msg"].to_int());
			"opp_unhover": game_display.opp_unhover(cmd["msg"].to_int());
			"result": end_game(cmd["msg"]);
			"timers": game_display.set_timers(HttpRequester.parse_body(cmd["msg"]));
			_: print(cmd);
	else:
		print(cmd);
	
func end_game(msg: String):
	set_process(false);
	ws.on_data.disconnect(on_command);
	endgame.enter(msg);

func _process(_delta: float) -> void:
	get_timers();

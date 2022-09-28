class_name GameDisplay
extends Control

var Winner = GameController.Winner;
var Player = GameController.Player;
var Sign = GameController.Sign;
var State = GameController.State;

signal played
signal hovered
signal unhovered
signal resigned

var board: Array[Button] = [];

@onready var game_controller: GameController = get_parent();

@onready var opp_name: Label = $OppData/DataContainer/VContainer/HContainer/Name;
@onready var opp_elo: Label = $OppData/DataContainer/VContainer/Elo;
@onready var opp_time: Label = $OppData/DataContainer/Time;
@onready var opp_pen: TextureRect = $OppData/DataContainer/VContainer/HContainer/Pen;

@onready var player_name: Label = $PlayerData/DataContainer/VContainer/HContainer/Name;
@onready var player_elo: Label = $PlayerData/DataContainer/VContainer/Elo;
@onready var player_time: Label = $PlayerData/DataContainer/Time;
@onready var player_pen: TextureRect = $PlayerData/DataContainer/VContainer/HContainer/Pen;

@onready var resign_btn: Button = $Resign;
@onready var board_grid: GridContainer = $Board/Grid;

func _ready() -> void:
	for i in range(9):
		var btn: Button = board_grid.get_node("Button%d" % i);
		btn.pressed.connect(game_controller.play.bind(i));
		btn.mouse_entered.connect(game_controller.hover.bind(i));
		btn.mouse_exited.connect(game_controller.unhover.bind(i));
		board.append(btn);
	resign_btn.pressed.connect(emit_signal.bind("resigned"));
	
func display(game_state: Dictionary) -> void:
	opp_name.text = game_state["opp_data"]["username"];
	opp_elo.text = str(game_state["opp_data"]["elo"]);
	player_name.text = game_state["your_data"]["username"];
	player_elo.text = str(game_state["your_data"]["elo"]);
	for i in range(9):
		set_field_text(game_state["board"][i], i);
	set_turn_player(game_state["turn_player"]);

func play(i: int) -> void:
	played.emit(i);

func hover(i: int) -> void:
	hovered.emit(i);

func unhover(i: int) -> void:
	unhovered.emit(i);

func opp_hover(_i: int) -> void:
	pass;

func opp_unhover(_i: int) -> void:
	pass;

func set_turn_player(turn_player) -> void:
	opp_pen.visible = turn_player == Player.OPPONENT;
	player_pen.visible = turn_player == Player.YOU;
	
func set_field_text(board_sign, i: int) -> void:
	if typeof(board_sign) == TYPE_NIL:
		board[i].text = "";
	elif board_sign == Sign.X:
		board[i].text = "X";
		board[i].add_theme_color_override("font_color", Color("#8ce2ff"));
	elif board_sign == Sign.O:
		board[i].text = "O";
		board[i].add_theme_color_override("font_color", Color("#ff6184"));

func set_timers(timers: Dictionary) -> void:
	if timers["you"] > 10:
		player_time.text = "%.0f" % timers["you"];
	else:
		player_time.text = "%.1f" % timers["you"];
	if timers["opp"] > 10:
		opp_time.text = "%.0f" % timers["opp"];
	else:
		opp_time.text = "%.1f" % timers["opp"];
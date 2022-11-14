class_name GameDisplay
extends Control

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
		set_field_text(game_state["board"][i], i, false);
	set_turn_player(game_state["turn_player"]);

func play(i: int) -> void:
	played.emit(i);

func hover(i: int) -> void:
	hovered.emit(i);

func unhover(i: int) -> void:
	unhovered.emit(i);

func opp_hover(i: int) -> void:
	board[i].theme_type_variation = "OppHover";

func opp_unhover(i: int) -> void:
	board[i].theme_type_variation = "";

func set_turn_player(turn_player) -> void:
	opp_pen.visible = turn_player == "opponent";
	player_pen.visible = turn_player == "you";
	
func set_field_text(board_sign, i: int, animate: bool = true) -> void:
	if typeof(board_sign) == TYPE_NIL:
		board[i].text = "";
	else:
		if animate:
			var tween: Tween = create_tween();
			tween.set_trans(Tween.TRANS_ELASTIC);
			tween.tween_property(
				board[i],
				"theme_override_font_sizes/font_size",
				72,
				0.7
			).from(24);
			tween.finished.connect(func(): tween.kill());
		if board_sign == "X":
			board[i].text = "X";
			board[i].add_theme_color_override("font_color", Color("#74c7ec"));
			board[i].add_theme_color_override("font_pressed_color", Color("#89dceb"));
			board[i].add_theme_color_override("font_hover_color", Color("#89dceb"));
			board[i].add_theme_color_override("font_focus_color", Color("#89dceb"));
			board[i].add_theme_color_override("font_hover_pressed_color", Color("#89dceb"));
		elif board_sign == "O":
			board[i].text = "O";
			board[i].add_theme_color_override("font_color", Color("#f2cdcd"));
			board[i].add_theme_color_override("font_pressed_color", Color("#f5e0dc"));
			board[i].add_theme_color_override("font_hover_color", Color("#f5e0dc"));
			board[i].add_theme_color_override("font_focus_color", Color("#f5e0dc"));
			board[i].add_theme_color_override("font_hover_pressed_color", Color("#f5e0dc"));

func set_timers(timers: Dictionary) -> void:
	if timers["you"] > 10:
		player_time.text = "%.0f" % timers["you"];
	else:
		player_time.text = "%.1f" % timers["you"];
	if timers["opp"] > 10:
		opp_time.text = "%.0f" % timers["opp"];
	else:
		opp_time.text = "%.1f" % timers["opp"];

func draw_lines(game_state: Dictionary) -> void:
	var winner: String = game_state["winner"];
	var winner_sign: String;
	var clr: Color;
	if winner == "you":
		winner_sign = game_state["your_data"]["sign"];
		clr = "#a6e3a1";
	elif winner == "opponent":
		winner_sign = game_state["opp_data"]["sign"];
		clr = "#f38ba8";
	else: 
		return;
	var lines_container: Control = $Board/Lines;
	lines_container.visible = true;
	var lines: Array[Control] = [];
	for i in range(8):
		lines.append(lines_container.get_node("Line%d" % i));
	var rows: Array[Array] = [[0, 1, 2], [3, 4, 5], [6, 7, 8], [0, 3, 6], [1, 4, 7], [2, 5, 8], [0, 4, 8], [2, 4, 6]];
	var b: Array = game_state["board"];
	var lines_val: Array[bool] = rows.map(
		func(x): 
			return x.map(func(i): return b[i]).all(func(y): return y==winner_sign);
	);
	if lines_val.all(func(x): return x==false):
		return
	var tween: Tween = create_tween();
	tween.set_trans(Tween.TRANS_EXPO);
	for i in range(8):
		lines[i].visible = lines_val[i];
		if lines_val[i]:
			var line_len = lines[i].size.x;
			lines[i].size.x = 0;
			lines[i].modulate = clr;
			tween.tween_property(
				lines[i],
				'size:x',
				line_len,
				1.5
			);
	tween.play();

	await tween.finished;
	await get_tree().create_timer(0.5).timeout;

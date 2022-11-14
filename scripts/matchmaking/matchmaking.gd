class_name Matchmaking
extends Panel

var match_found: bool = false;

@onready var label: Label = $Container/Label;
@onready var cancel_btn: Button = $Container/Cancel;
@onready var socket: WebSocketClient = WebSocketController.connect_to_url("matchmaking");

func _ready() -> void:
	cancel_btn.pressed.connect(cancel_queue);
	gui_input.connect(
		func(event): 
			if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed:
				cancel_queue();
	);
	socket.connection_closed.connect(func(): if !match_found: queue_free());
	socket.message_received.connect(on_data);

func cancel_queue() -> void:
	if !match_found:
		socket.close();

func on_data(msg) -> void:
	if typeof(msg) != TYPE_STRING:
		return
	var data: Dictionary = JSON.parse_string(msg);
	if data["msg"] == "Match found":
		match_found = true;
		label.text = data["msg"];
		cancel_btn.disabled = true;
		MainController.create_game(data["match_id"]);
		queue_free();

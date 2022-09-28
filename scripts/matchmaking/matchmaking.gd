class_name Matchmaking
extends Panel

var match_found: bool = false;

@onready var label: Label = $Container/Label;
@onready var cancel_btn: Button = $Container/Cancel;
@onready var ws: WsClient = $WsClient;

func _ready() -> void:
	cancel_btn.pressed.connect(cancel_queue);
	gui_input.connect(
		func(event): 
			if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed:
				cancel_queue();
	);
	ws.closed.connect(func(): if !match_found: queue_free());
	ws.out_of_reconnects.connect(func(): if !match_found: queue_free());
	ws.on_data.connect(on_data);
	ws.start("matchmaking");

func cancel_queue() -> void:
	if !match_found:
		if ws.ws.get_connection_status() != OK:
			ws.send("0");
		else:
			queue_free();

func on_data(msg: String) -> void:
	match_found = true;
	label.text = "Match found";
	cancel_btn.disabled = true;
	Globals.create_game(msg);
	queue_free();
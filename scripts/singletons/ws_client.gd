class_name WsClient
extends Node

signal closed
signal connected
signal on_data
signal out_of_reconnects

var ws: WebSocketClient = WebSocketClient.new();
var last_path: String = "";
var reconnect_attempts: int = 10;

@onready var api_server: String = "wss://" + (ProjectSettings.get_setting("global/%sapi_server" % ("test_" if OS.is_debug_build() else "")))
@onready var api_headers: PackedStringArray = [];
@onready var cookie: String = "": 
	set(c):
		cookie = c;
		api_headers = [];
		if !c.is_empty():
			api_headers.append("Cookie: " + c);

func _ready() -> void:
	ws.verify_tls = false;
	self.cookie = HttpRequester.cookie;
	set_process(false);	

func start(path: String) -> bool:
	last_path = path;
	ws.connection_error.connect(func(): print("Error connecting to server!"));
	
	var err = ws.connect_to_url(api_server + path, PackedStringArray(), false if OS.is_debug_build() else true, api_headers);
	if err != OK:
		print("%d: Unable to connect" % err);
		set_process(false);
		return false;
	else:
		ws.connection_closed.connect(on_closed);
		ws.connection_established.connect(on_connection_established.bind(path));
		ws.data_received.connect(on_data_recieved);
		reconnect_attempts = 10;
		set_process(true);
		return true;

func on_connection_established(_protocol: String, path: String):
	print("Connected to %s" % (api_server + path));
	connected.emit();

func on_closed(was_clean: bool) -> void:
	if was_clean:
		closed.emit();
	else:
		try_reconnect();
		
func try_reconnect() -> bool:
	if reconnect_attempts > 0:
		reconnect_attempts -= 1;
		start(last_path);
		return true;
	else:
		out_of_reconnects.emit();
		set_process(false);
	return false;
	
func send(msg: String) -> bool:
	var peer: WebSocketPeer = ws.get_peer(1);
	if !peer.is_connected_to_host():
		return false;
	peer.set_write_mode(WebSocketPeer.WRITE_MODE_TEXT);
	peer.put_packet(msg.to_utf8_buffer());
	return true;

func on_data_recieved() -> void:
	var peer: WebSocketPeer = ws.get_peer(1);
	var data: String = peer.get_packet().get_string_from_utf8();
	if peer.was_string_packet():
		on_data.emit(data);

func _process(_delta: float) -> void:
	ws.poll();
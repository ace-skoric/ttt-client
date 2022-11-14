extends Node

var tls: bool = !OS.is_debug_build() and ProjectSettings.get_setting("global/use_tls_release");
var protocol: String = "wss://" if tls else "ws://";
var server_setting = "global/api_server_" + ("debug" if OS.is_debug_build() else "release");

var api_server: String = protocol + ProjectSettings.get_setting(server_setting);

func connect_to_url(path) -> WebSocketClient:
	var socket: WebSocketClient = WebSocketClient.new();
	add_child(socket);
	socket.connect_to_url(api_server + path, HttpRequester.api_headers, tls);
	socket.connection_closed.connect(socket.queue_free);
	return socket;
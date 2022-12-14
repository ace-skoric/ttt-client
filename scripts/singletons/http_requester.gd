extends Node

const HttpResponse = preload("res://scripts/custom_types/http_response.gd");

var tls: bool = !OS.is_debug_build() and ProjectSettings.get_setting("global/use_tls_release");
var protocol: String = "https://" if tls else "http://";
var server_setting = "global/api_server_" + ("debug" if OS.is_debug_build() else "release");

var api_server: String = protocol + ProjectSettings.get_setting(server_setting);
var api_headers: PackedStringArray = ProjectSettings.get_setting("global/api_headers").duplicate();
var cookie: String = "": 
	set(c):
		cookie = c;
		api_headers = ProjectSettings.get_setting("global/api_headers").duplicate();
		if !c.is_empty():
			api_headers.append("Cookie: " + c);

func _ready() -> void:
	set_cookie_from_file();

func new_get(path: String, body: String = "") -> HttpResponse:
	return await new_req(path, HTTPClient.METHOD_GET, body);

func new_post(path: String, body: String = "") -> HttpResponse:
	return await new_req(path, HTTPClient.METHOD_POST, body);

func new_delete(path: String, body: String = "") -> HttpResponse:
	return await new_req(path, HTTPClient.METHOD_DELETE, body);

func new_req(path: String, method: int, body: String = "") -> HttpResponse:
	var request := HTTPRequest.new();
	request.timeout = 10.0;
	add_child(request);
	if !request.request(api_server + path, api_headers, tls, method, body):
		var res = callv("get_response", await request.request_completed);
		request.queue_free();
		return res;
	else:
		var res := HttpResponse.new();
		res.data = "Could not establish connection to server.";
		return res;

func get_response(_result: int, status: int, headers: PackedStringArray, data: PackedByteArray) -> HttpResponse:
	var res = HttpResponse.new();
	res.status = status;
	res.headers = headers;
	if status == 0:
		res.data = "Cannot establish connection with the server!"
	else:
		res.data = parse_body(data.get_string_from_utf8());
	return res;

func parse_body(body: String) -> Variant:
	var parser := JSON.new();
	var err := parser.parse(body);
	if err == OK:
		return parser.get_data();
	else:
		printerr("Error parsing string!");
		return "";

func set_cookie_from_headers(headers: PackedStringArray):
	for header in headers:
		if header.begins_with("set-cookie:"):
			var set_cookie := header.trim_prefix("set-cookie: ").get_slice(';', 0);
			self.cookie = set_cookie;
		elif header.begins_with("Set-Cookie:"):
			var set_cookie := header.trim_prefix("Set-Cookie: ").get_slice(';', 0);
			self.cookie = set_cookie;

func set_cookie_from_file() -> bool:
	if FileAccess.file_exists("user://cookie"):
		var f = FileAccess.open_encrypted_with_pass("user://cookie", FileAccess.READ, OS.get_unique_id() + "some_secret");
		if !f:
			print(f);
			print(FileAccess.get_open_error());
		self.cookie = f.get_line();
		return true;
	return false;

func write_cookie_to_file():
	var f: FileAccess = FileAccess.open_encrypted_with_pass("user://cookie", FileAccess.WRITE, OS.get_unique_id() + "some_secret");
	if !f:
		print(f);
		print(FileAccess.get_open_error());
	f.store_line(cookie);

func delete_cookie_file():
	if FileAccess.file_exists("user://cookie"):
		var d: DirAccess = DirAccess.open("user://");
		d.remove("user://cookie");
	self.cookie = "";
	

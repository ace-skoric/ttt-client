extends Node

const HttpResponse = preload("res://scripts/custom_types/http_response.gd");
@onready var api_server: String = "https://" + (ProjectSettings.get_setting("global/%sapi_server" % ("test_" if OS.is_debug_build() else "")))
@onready var api_headers: PackedStringArray = ProjectSettings.get_setting("global/api_headers").duplicate();
@onready var cookie: String = "": 
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
	var request: HTTPRequest = HTTPRequest.new();
	add_child(request);
	if !request.request(api_server + path, api_headers, false if OS.is_debug_build() else true, method, body):
		var res = callv("get_response", await request.request_completed);
		request.queue_free();
		return res;
	else:
		var res = HttpResponse.new();
		res.data = "Could not establish connection to server.";
		return res;

func get_response(_result: int, status: int, headers: PackedStringArray, data: PackedByteArray) -> HttpResponse:
	var res = HttpResponse.new();
	res.status = status;
	res.headers = headers;
	res.data = parse_body(data.get_string_from_utf8());
	return res;

func parse_body(body: String) -> Variant:
	var parser: JSON = JSON.new();
	var err := parser.parse(body);
	if err == OK:
		return parser.get_data();
	else:
		printerr("Error parsing string!");
		printerr(parser.get_error_line());
		return "";

func set_cookie_from_headers(headers: PackedStringArray):
	for header in headers:
		if header.begins_with("set-cookie:"):
			var set_cookie: String = header.trim_prefix("set-cookie: ").get_slice(';', 0);
			self.cookie = set_cookie;
			return;

func set_cookie_from_file() -> bool:
	var f: File = File.new();
	if f.file_exists("user://cookie"):
		f.open_encrypted_with_pass("user://cookie", File.READ, OS.get_unique_id() + "some_secret");
		self.cookie = f.get_line();
		f.close();
		return true;
	return false;

func write_cookie_to_file():
	var f: File = File.new();
	f.open_encrypted_with_pass("user://cookie", File.WRITE, OS.get_unique_id() + "some_secret");
	f.store_line(cookie);
	f.close();

func delete_cookie_file():
	var f: File = File.new();
	if f.file_exists("user://cookie"):
		var d: Directory = Directory.new();
		d.remove("user://cookie");
	self.cookie = "";
	
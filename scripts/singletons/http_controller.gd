extends Node

const HttpResponse = preload("res://scripts/custom_types/http_response.gd");
	
func sign_out() -> void:
	var _res = await HttpRequester.new_post("auth/signout");
	MainController.on_sign_out();
	
func on_session_expired() -> void:
	sign_out();

func session_sign_in() -> HttpResponse:
	var res: HttpResponse = await HttpRequester.new_post("auth");
	match res.status:
		HTTPClient.RESPONSE_FORBIDDEN:
			HttpRequester.delete_cookie_file();
		HTTPClient.RESPONSE_OK:
			HttpRequester.set_cookie_from_headers(res.headers);
			HttpRequester.write_cookie_to_file();
		_:
			pass
	return res;

func sign_in(email: String, password: String, remember_me: bool) -> HttpResponse:
	var body: Dictionary = { "email": email, "password": password };
	var json_body: String = JSON.stringify(body);
	var res: HttpResponse = await HttpRequester.new_post("auth/signin", json_body);
	if res.status == HTTPClient.RESPONSE_CREATED:
		HttpRequester.set_cookie_from_headers(res.headers);
		if remember_me:
			HttpRequester.write_cookie_to_file();
	return res;

func sign_up(username: String, email: String, password: String) -> HttpResponse:
	var body: Dictionary = { "username": username, "email": email, "password": password };
	var json_body: String = JSON.stringify(body);
	var res: HttpResponse = await HttpRequester.new_post("auth/signup", json_body);
	return res;

func claim_account(username: String, email: String, password: String) -> HttpResponse:
	var body: Dictionary = { "username": username, "email": email, "password": password };
	var json_body: String = JSON.stringify(body);
	var res: HttpResponse = await HttpRequester.new_post("user/claim", json_body);
	return res;

func guest_sign_in() -> HttpResponse:
	var res: HttpResponse = await HttpRequester.new_post("auth/guest");
	if res.status == HTTPClient.RESPONSE_CREATED:
		HttpRequester.set_cookie_from_headers(res.headers);
		HttpRequester.write_cookie_to_file();
	return res;

func get_user_stats() -> HttpResponse:
	var res: HttpResponse = await HttpRequester.new_get("data");
	if res.status == HTTPClient.RESPONSE_UNAUTHORIZED:
		HttpRequester.on_session_expired();
	return res;
	
func get_session_data() -> HttpResponse:
	var res: HttpResponse = await HttpRequester.new_get("user");
	return res;

func get_email_verified_status() -> bool:
	var res: HttpResponse = await HttpRequester.new_get("verify/status");
	if res.status:
		return res.data;
	else:
		return false;
		
func resend_verification_email() -> HttpResponse:
	var res: HttpResponse = await HttpRequester.new_post("verify/resend");
	return res;
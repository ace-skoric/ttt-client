extends Control

@onready var error_popup: Panel = $ConnectionErrorPopup;
@onready var retry_button: Button = error_popup.get_node("VBoxContainer/HBoxContainer/Retry");
@onready var quit_button: Button = error_popup.get_node("VBoxContainer/HBoxContainer/Quit");
@onready var popup_text: Label = error_popup.get_node("VBoxContainer/Message");

func _ready():
	retry_button.button_down.connect(attempt_sign_in);
	quit_button.button_down.connect(get_tree().quit);
	attempt_sign_in();

func attempt_sign_in():
	error_popup.visible = false;
	var res: HttpResponse = await HttpController.session_sign_in();
	match res.status:
		HTTPClient.RESPONSE_OK:
			var timer: SceneTreeTimer = get_tree().create_timer(2.5);
			await timer.timeout;
			Globals.on_sign_in();
		HTTPClient.RESPONSE_REQUEST_TIMEOUT:
			popup_text.text = "Cannot establish connection to server";
			error_popup.visible = true;
		HTTPClient.RESPONSE_FORBIDDEN:
			var timer: SceneTreeTimer = get_tree().create_timer(2.5);
			await timer.timeout;
			Globals.change_scene("login_menu");
		_:
			popup_text.text = res.data;
			error_popup.visible = true;

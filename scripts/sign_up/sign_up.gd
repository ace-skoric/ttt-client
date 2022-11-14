extends Control

var claim_account: bool = false:
	set(v):
		claim_account = v;
		back_btn.pressed.disconnect(MainController.change_scene);
		back_btn.pressed.connect(MainController.change_scene.bind("profile"));

@onready var sign_up_panel: Panel = $SignUp;
@onready var message_panel: Panel = $SignUp/SignUpErrorPanel;
@onready var message: Label = $SignUp/SignUpErrorPanel/ErrorMessage;
@onready var username: LineEdit = $SignUp/VBox/Username;
@onready var email: LineEdit = $SignUp/VBox/Email;
@onready var password: LineEdit = $SignUp/VBox/Password;
@onready var sign_up_btn: Button = $SignUp/VBox/SignUpButton;
@onready var loading_icon: TextureRect = $SignUp/VBox/SignUpButton/Icon;
@onready var back_btn: Button = $SignUp/Back;
@onready var message_tween: Tween;
@onready var btn_text: String = "Claim" if claim_account else "Sign up";

func _ready():
	message_panel.custom_minimum_size.y = 0;
	sign_up_panel.size.y = 290;
	sign_up_btn.pressed.connect(sign_up);
	back_btn.pressed.connect(MainController.change_scene.bind("login_menu"));
	sign_up_btn.text = btn_text;
	
func sign_up():
	back_btn.disabled = true;
	sign_up_btn.disabled = true;
	sign_up_btn.text = "";
	loading_icon.visible = true;
	await hide_message();
	var uname: String = username.text;
	var mail: String = email.text;
	var passwd: String = password.text;
	var res: HttpResponse;
	if claim_account:
		res = await HttpController.claim_account(uname, mail, passwd);
	else:
		res = await HttpController.sign_up(uname, mail, passwd);
	match res.status:
		HTTPClient.RESPONSE_CREATED:
			await render_message(res.data, 0);
			var timer = get_tree().create_timer(3);
			await timer.timeout;
			if claim_account:
				MainController.get_session_data();
				MainController.change_scene("profile");
			else:
				MainController.change_scene("login");
		0:
			await render_message(res.data, 2);
			sign_up_btn.disabled = false;
			back_btn.disabled = false;
			sign_up_btn.text = btn_text;
			loading_icon.visible = false;
		_:
			await render_message(res.data, 1);
			sign_up_btn.disabled = false;
			back_btn.disabled = false;
			sign_up_btn.text = btn_text;
			loading_icon.visible = false;

func hide_message():
	if message_tween:
		message_tween.kill();
	message_tween = create_tween();
	message_tween.parallel().tween_property(message_panel, "custom_minimum_size", Vector2(300, 0), 0.5);
	message_tween.parallel().tween_property(sign_up_panel, "size", Vector2(500, 310), 0.5);
	message_tween.play();
	await message_tween.finished;
	await get_tree().create_timer(0.3).timeout;

func render_message(msg: String, type: int):
	if message_tween:
		message_tween.kill();
	message.text = msg;
	match type:
		0: message_panel.theme_type_variation = "SuccessPanel";
		1: message_panel.theme_type_variation = "WarningPanel";
		2: message_panel.theme_type_variation = "ErrorPanel";
	message_panel.visible = true;
	message_tween = create_tween();
	message_tween.parallel().tween_property(sign_up_panel, "size", Vector2(500, 410), 0.5);
	message_tween.parallel().tween_property(message_panel, "custom_minimum_size", Vector2(300, 65), 0.5);
	message_tween.play();
	await message_tween.finished;

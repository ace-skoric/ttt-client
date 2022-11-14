extends Control

@onready var sign_up_panel: Panel = $Login;
@onready var error_panel: Panel = $Login/LoginErrorPanel;
@onready var error_message: Label = $Login/LoginErrorPanel/ErrorMessage;
@onready var email: LineEdit = $Login/VBox/Email;
@onready var password: LineEdit = $Login/VBox/Password;
@onready var remember: CheckBox = $Login/VBox/RememberMe;
@onready var login_btn: Button = $Login/VBox/LoginButton;
@onready var loading_icon: TextureRect = $Login/VBox/LoginButton/Icon;
@onready var back_btn: Button = $Login/Back;
@onready var error_tween: Tween;

func _ready():
	error_panel.custom_minimum_size.y = 0;
	sign_up_panel.size.y = 290;
	login_btn.button_down.connect(sign_in);
	back_btn.button_down.connect(MainController.change_scene.bind("login_menu"));
	
func sign_in():
	login_btn.disabled = true;
	back_btn.disabled = true;
	login_btn.text = "";
	loading_icon.visible = true;
	await hide_error();
	print("Logging in...");
	var mail: String = email.text;
	var passwd: String = password.text;
	var remember_me: bool = remember.button_pressed;
	var res: HttpResponse = await HttpController.sign_in(mail, passwd, remember_me);
	match res.status:
		HTTPClient.RESPONSE_CREATED:
			MainController.on_sign_in();
		_:
			await render_error(res.data);
			login_btn.disabled = false;
			back_btn.disabled = false;
			login_btn.text = "Log in";
			loading_icon.visible = false;

func hide_error():
	if error_tween:
		error_tween.kill();
	error_tween = create_tween();
	error_tween.parallel().tween_property(error_panel, "custom_minimum_size", Vector2(300, 0), 0.5);
	error_tween.parallel().tween_property(sign_up_panel, "size", Vector2(500, 290), 0.5);
	error_tween.play();
	await error_tween.finished;
	await get_tree().create_timer(0.3).timeout;

func render_error(message: String):
	if error_tween:
		error_tween.kill();
	error_message.text = message;
	error_panel.visible = true;
	error_tween = create_tween();
	error_tween.parallel().tween_property(sign_up_panel, "size", Vector2(500, 390), 0.5);
	error_tween.parallel().tween_property(error_panel, "custom_minimum_size", Vector2(300, 65), 0.5);
	error_tween.play();
	await error_tween.finished;

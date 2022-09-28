extends Control

@onready var sign_up_panel: Panel = $SignUp;
@onready var error_panel: Panel = $SignUp/SignUpErrorPanel;
@onready var error_message: Label = $SignUp/SignUpErrorPanel/ErrorMessage;
@onready var username: LineEdit = $SignUp/VBox/Username;
@onready var email: LineEdit = $SignUp/VBox/Email;
@onready var password: LineEdit = $SignUp/VBox/Password;
@onready var sign_up_btn: Button = $SignUp/VBox/SignUpButton;
@onready var loading_icon: TextureRect = $SignUp/VBox/SignUpButton/Icon;
@onready var back_btn: Button = $SignUp/Back;
@onready var error_tween: Tween;

func _ready():
	error_panel.custom_minimum_size.y = 0;
	sign_up_panel.size.y = 290;
	sign_up_btn.button_down.connect(sign_in);
	back_btn.button_down.connect(Globals.change_scene.bind("login_menu"));
	
func sign_in():
	sign_up_btn.disabled = true;
	sign_up_btn.text = "";
	loading_icon.visible = true;
	await hide_error();
	var uname: String = username.text;
	var mail: String = email.text;
	var passwd: String = password.text;
	var res: HttpResponse = await HttpController.sign_in(uname, mail, passwd.is_empty());
	match res.status:
		HTTPClient.RESPONSE_CREATED:
			Globals.on_sign_in();
		_:
			await render_error(res.data);
			sign_up_btn.disabled = false;
			sign_up_btn.text = "Sign up";
			loading_icon.visible = false;

func hide_error():
	if error_tween:
		error_tween.kill();
	error_tween = create_tween();
	error_tween.parallel().tween_property(error_panel, "custom_minimum_size", Vector2i(300, 0), 0.5);
	error_tween.parallel().tween_property(sign_up_panel, "size", Vector2(500, 310), 0.5);
	error_tween.play();
	await error_tween.finished;
	await get_tree().create_timer(0.3).timeout;

func render_error(message: String):
	if error_tween:
		error_tween.kill();
	error_message.text = message;
	error_panel.visible = true;
	error_tween = create_tween();
	error_tween.parallel().tween_property(sign_up_panel, "size", Vector2(500, 410), 0.5);
	error_tween.parallel().tween_property(error_panel, "custom_minimum_size", Vector2i(300, 65), 0.5);
	error_tween.play();
	await error_tween.finished;

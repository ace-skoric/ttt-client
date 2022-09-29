extends VBoxContainer

@export @onready var loader: Panel;

@onready var guest_btn: Button = $Guest;
@onready var login_btn: Button = $LogIn;
@onready var sign_up_btn: Button = $SignUp;
@onready var quit_btn: Button = $Quit;

func _ready() -> void:
	guest_btn.pressed.connect(guest_login);
	login_btn.pressed.connect(Globals.change_scene.bind("login"));
	sign_up_btn.pressed.connect(Globals.change_scene.bind("sign_up"));
	quit_btn.pressed.connect(get_tree().quit);

func guest_login() -> void:
	loader.visible = true;
	print("Logging in as guest...");
	var res: HttpResponse = await HttpController.guest_sign_in();
	match res.status:
		HTTPClient.RESPONSE_CREATED:
			Globals.on_sign_in();
		_:
			pass;
	loader.visible = false;


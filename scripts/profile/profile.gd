extends VBoxContainer

@onready var username: Label = $Username;
@onready var elo: Label = $Elo/Val;
@onready var wins: Label = $Wins/Val;
@onready var draws: Label = $Draws/Val;
@onready var losses: Label = $Losses/Val;
@onready var email_verified: HBoxContainer = $EmailVerified;
@onready var verify_email: Button = $VerifyEmail/Button;
@onready var claim_account: Button = $ClaimAccount/Button;
@onready var back_btn: Button = $Back;

func _ready() -> void:
	username.text = Globals.username;
	if Globals.guest:
		claim_account.get_parent().visible = true;
		email_verified.visible = false;
		verify_email.get_parent().visible = false;
	else:
		var is_email_verified = await HttpController.get_email_verified_status();
		email_verified.visible = is_email_verified;
		verify_email.get_parent().visible = !is_email_verified;
	await get_user_data();
	back_btn.pressed.connect(Globals.change_scene.bind("main_menu"));

func get_user_data() -> void:
	var res: HttpResponse = await HttpController.get_user_stats();
	var data = res.data;
	elo.text = str(data["elo"]);
	wins.text = str(data["wins"]);
	draws.text = str(data["draws"]);
	losses.text = str(data["losses"]);

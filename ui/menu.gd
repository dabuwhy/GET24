extends Control
#@onready var mainScene = preload("res://main.tscn").instantiate()
@onready var control = $Control
@onready var rounds = $Control/optionMenu/Rounds
@onready var leaderboardLabel = $Control/VBoxContainer/leaderboard
@onready var music = $Control/optionMenu/Music
@onready var sfx = $Control/optionMenu/SFX
@onready var max_int = $Control/optionMenu/HBoxContainer/maxInt
@onready var h_slider = $Control/optionMenu/HBoxContainer/HSlider
func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		get_tree().quit() # default behavior
		
func _init():
	if OS.get_name()!="iOS" && OS.get_name()!="Android":
		DisplayServer.window_set_size(Vector2i(450,900))
#		get_window().size=Vector2i(1024,768)


# Called when the node enters the scene tree for the first time.
func _ready():
	self.z_index=2
	rounds.text="Rounds: "+str(Globals.round_set)
	leaderboardLabel.text=""
	var ks=Globals.leaderboard.keys()
	ks.sort()
	for k in ks:
		leaderboardLabel.text+="%d:%02d    \t"%[int(k/60),int(k)%60]+Globals.leaderboard[k]+'\n'
	if TranslationServer.get_locale()=="en":
		$Control/optionMenu/HBoxContainer2/OptionButton.select(1)
	else:
		$Control/optionMenu/HBoxContainer2/OptionButton.select(0)
	if AudioServer.is_bus_mute(Globals.BGM_IDX):
		music.text="Music:  OFF"
	else:
		music.text="Music:  ON"
	if AudioServer.is_bus_mute(Globals.SFX_IDX):
		sfx.text="SFX:  OFF"
	else:
		sfx.text="SFX:  ON"
	if OS.get_name()=="iOS":
		$Control/mainMenu/Quit.visible=false
	h_slider.value=Globals.maxInt
	max_int.text=str(Globals.maxInt)


func _on_start_pressed():
	Globals.pkMode=false
	Globals.round_index=1
	Globals.started_at=Time.get_unix_time_from_system()
	Globals.restart()
	Globals.go_to_world("res://main.tscn")
	
#	get_tree().get_root().add_child(mainScene)
func _on_quit_pressed():
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	

func _on_leaderboard_pressed():
	var tween=get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(control,"anchor_left",0.334,0.5)
	tween.parallel().tween_property(control,"anchor_right",1.334,0.5)


func _on_back_pressed():
	var tween=get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(control,"anchor_left",0,0.5)
	tween.parallel().tween_property(control,"anchor_right",1.001,0.5)


func _on_option_pressed():
	var tween=get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(control,"anchor_left",-0.334,0.5)
	tween.parallel().tween_property(control,"anchor_right",0.666,0.5)


func _on_option_button_item_selected(index):
	if index==0:
		TranslationServer.set_locale("zh")
	else:
		TranslationServer.set_locale("en")
	Globals.save_config()

func _on_music_pressed():
	var bMute=AudioServer.is_bus_mute(Globals.BGM_IDX)
	AudioServer.set_bus_mute(Globals.BGM_IDX,!bMute)
	if bMute:
		music.text="Music:  ON"
	else:
		music.text="Music:  OFF"
	Globals.save_config()
		


func _on_sfx_pressed():
	var bMute=AudioServer.is_bus_mute(Globals.SFX_IDX)
	AudioServer.set_bus_mute(Globals.SFX_IDX,!bMute)
	if bMute:
		sfx.text="SFX:  ON"
	else:
		sfx.text="SFX:  OFF"
	Globals.save_config()


func _on_rounds_pressed():
	if Globals.round_set==1:
		Globals.round_set=10
	else:
		Globals.round_set=1
	rounds.text="Rounds: %2d"%(Globals.round_set)
	Globals.save_config()


func _on_h_slider_value_changed(value):
	max_int.text=str(value)
	Globals.maxInt=value
	


func _on_h_slider_drag_ended(value_changed):
	if value_changed:
		Globals.save_config()


func _on_tool_pressed():
	Globals.go_to_world("res://tool.tscn")


func _on_about_pressed():
	Globals.go_to_world("res://ui/about.tscn")


func _on_pk_pressed() -> void:
	Globals.pkMode=true
	Globals.round_index=1
	Globals.started_at=Time.get_unix_time_from_system()
	Globals.go_to_world("res://ui/pk.tscn")

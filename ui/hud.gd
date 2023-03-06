extends CanvasLayer
@onready var color_rect = $ColorRect
@onready var pause = $HBoxContainer/pause
@onready var conti = $HBoxContainer/continue
@onready var revoke = $HBoxContainer/revoke
@onready var forward = $HBoxContainer/forward
@onready var label = $HBoxContainer/Label
@onready var time = $time
@onready var ans = $PopupPanel/Label
@onready var popup_panel = $PopupPanel
@onready var restartButton = $HBoxContainer/restart

# Called when the node enters the scene tree for the first time.
func _ready():
	if Globals.round_set>=10:
		pause.disabled=true
	popup_panel.size.x=get_viewport().get_visible_rect().size.x
	ans.size.x=get_viewport().get_visible_rect().size.x
	restart()
	
func restart():
	revoke.disabled=true
	conti.disabled=true
	restartButton.disabled=true
	popup_panel.size.y=100
	ans.size.y=100
	ans.text=""
	for k in Globals.solution:
		ans.text+=Globals.solution[k]+'\n'
	await get_tree().create_timer(2.5).timeout
	restartButton.disabled=false
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var now:int=Time.get_unix_time_from_system()-Globals.started_at
	time.text="%02d:%02d"%[now/60,now%60]
	pass
func _on_restart_pressed():
	Globals.restart()
#	get_tree().reload_current_scene()
	self.restart()
	get_parent().restart()

func _on_pause_pressed():
	color_rect.visible=true
	pause.visible=false
	conti.visible=true
	conti.disabled=true
	color_rect.mouse_filter=Control.MOUSE_FILTER_STOP
	var tween=get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(color_rect,"modulate",Color(1,1,1,1),0.5)
	await tween.finished
	Globals.pause_sec=Time.get_unix_time_from_system()-Globals.started_at
	get_tree().paused=true
	conti.disabled=false
func _on_continue_pressed():
	get_tree().paused=false
	Globals.started_at=Time.get_unix_time_from_system()-Globals.pause_sec
	pause.visible=true
	pause.disabled=true
	conti.visible=false
	color_rect.mouse_filter=Control.MOUSE_FILTER_PASS
	var tween=get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(color_rect,"modulate",Color(1,1,1,0),0.5)
	await tween.finished
#	tween.kill()
	color_rect.visible=false
	pause.disabled=false
func revokeAbled():
	if Globals.historyIndex>0:
		revoke.disabled=false
	else:
		revoke.disabled=true
	if Globals.historyIndex<Globals.history.size()-1:
		forward.disabled=false
	else:
		forward.disabled=true
func recoveryScene(previous):
	var now=Globals.history[Globals.historyIndex]
	var pre=Globals.history[previous]
#	print("recoveryScene:",now)
	for n in Globals.nameRect.keys():
		Globals.nameRect[n].num=now[n][0]
		Globals.rectNumber[Globals.nameRect[n]]=int(now[n][0])
		if pre[n][2]==now[n][2]:
			Globals.moveTo(Globals.nameRect[n],pre[n][1],now[n][1])
		elif pre[n][2]==2 && now[n][2]==1:
			Globals.moveToShow(Globals.nameRect[n],pre[n][1],now[n][1])
		elif pre[n][2]==1 && now[n][2]==2:
			Globals.moveToHide(Globals.nameRect[n],pre[n][1],now[n][1])
		else:
			print("recoveryScene not consider ",pre[n],now[n])
	
func _on_revoke_pressed():
	if Globals.historyIndex>0:
		Globals.historyIndex-=1
		forward.disabled=false
		recoveryScene(Globals.historyIndex+1)
	if Globals.historyIndex<=0:
		revoke.disabled=true
	await get_tree().create_timer(1.1).timeout
	Globals.reloadOnce=true
	


func _on_forward_pressed():
	if Globals.historyIndex<Globals.history.size()-1:
		Globals.historyIndex+=1
		revoke.disabled=false
		recoveryScene(Globals.historyIndex-1)
	if Globals.historyIndex>=Globals.history.size()-1:
		forward.disabled=true
	
	pass # Replace with function body.


func _on_menu_pressed():
	Globals.go_to_world("res://ui/menu.tscn")


func _on_solution_pressed():
	popup_panel.size.y=100
	ans.size.y=100
	popup_panel.visible=true
	


func _on_label_gui_input(event):
	if (event is InputEventMouseButton && event.pressed) || event is InputEventScreenTouch :
		popup_panel.visible=false



func _on_popup_panel_popup_hide():
	if Globals.round_set>=10:
		Globals.restart()
		self.restart()
		get_parent().restart()

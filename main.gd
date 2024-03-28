extends Control
@onready var timer:Timer = $Timer
@onready var sky = $Sky
@onready var fireworks = $Fireworks
@onready var hud = $HUD
@onready var label = $Label/Label
@onready var rounds: Label = $Label/rounds
@onready var labels: Control = $Label

var beInRects=[]
var beAddRect=null
var collision1Rect=4
var initPos=[Vector2(80,384),Vector2(400,384),Vector2(80,808),Vector2(400,808)]
var rects=[]
func _notification(what):
	if (!Globals.pkMode)&&Globals.round_set!=10:
		if what==MainLoop.NOTIFICATION_APPLICATION_RESUMED || what==Node.NOTIFICATION_WM_WINDOW_FOCUS_IN:
			Globals.started_at=Time.get_unix_time_from_system()-Globals.pause_sec
			get_tree().paused=false
		elif what==MainLoop.NOTIFICATION_APPLICATION_PAUSED || what==Node.NOTIFICATION_WM_WINDOW_FOCUS_OUT:
			Globals.pause_sec=Time.get_unix_time_from_system()-Globals.started_at
			get_tree().paused=true
func _init():
	pass
func _enter_tree() -> void:
	set_multiplayer_authority(self.name.to_int())
	#self.name="1"
	#print(get_viewport().get_visible_rect())
	pass
# Called when the node enters the scene tree for the first time.
func _ready():
#	print(get_viewport().get_visible_rect().size.x,get_node("Number/CollisionShape2D").shape.size.x)
	initPos[0].x=get_viewport().get_visible_rect().size.x/9
	initPos[0].y=20+get_viewport().get_visible_rect().size.y/5
	initPos[2].x=initPos[0].x
	initPos[2].y=get_viewport().get_visible_rect().size.y/5+300
	initPos[1].x=get_viewport().get_visible_rect().size.x/9*8-240
	initPos[1].y=initPos[0].y
	initPos[3].x=initPos[1].x
	initPos[3].y=initPos[2].y
	
	rects.append($Number0)
	rects.append($Number1)
	rects.append($Number2)
	rects.append($Number3)
	if (!Globals.pkMode)||is_multiplayer_authority():
		for r in rects:
			r.MergeNumber.connect(hud.revokeAbled)
			Globals.nameRect[r.name]=r
	restart()
func restart():
	if (!Globals.pkMode)||is_multiplayer_authority():
		Globals.reloadOnce=true
		Globals.rectNumber.clear()
		var now={}
		var i=0
		for r in rects:
			r.collision_layer=1
			Globals.rectNumber[r]=Globals.numbers[i]
			r.num=str(Globals.numbers[i])
			Globals.moveToShow(r,Vector2(0.5*get_viewport().get_visible_rect().size.x,-38),initPos[i])
			now[r.name]=[r.num,initPos[i],r.collision_layer]
			i+=1
		Globals.history.push_back(now)
		Globals.historyIndex=0
		if !Globals.pkMode:
			label.text="Round:"
		elif self.name=="1":
			label.text="Server:"
		else:
			label.text="Client:"
		rounds.text=str(Globals.round_index)
		labels.modulate=Color(1,1,1,1)
		labels.scale=Vector2.ZERO
		var tween=get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_LINEAR)
		tween.tween_property($HUD/HBoxContainer/Label,"theme_override_colors/font_color",Color(1,0,0,1),0.1)
		tween.tween_property($HUD/HBoxContainer/Label,"theme_override_colors/font_color",Color(1,1,1,1),1.7)
		tween.parallel().tween_property(labels,"scale",Vector2.ONE,1)
		tween.tween_property(labels,"modulate",Color(1,1,1,0.5),0.5)
		await tween.finished
func nextRound(rect):
	Globals.moveToHide(rect,rect.position,Vector2(0.56*get_viewport().get_visible_rect().size.x,-38))
	var tween=get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_LINEAR)
	tween.tween_property($HUD/HBoxContainer/Label,"theme_override_colors/font_color",Color(1,0,0,1),1)
	await tween.finished
	if Globals.round_index>=Globals.round_set:
		if Globals.pkMode:
			var spendt=Time.get_unix_time_from_system()-Globals.started_at
			label.text="%.3f"%[spendt]
			rounds.text=" sec"
			if Globals.round_set>=10&&Globals.maxInt>=13:
				compareLeaderboard(spendt)
			Globals.history.clear()
			Globals.historyIndex=0
			hud.revokeAbled()
			if !Globals.pkWin:
				whoWin.rpc(spendt,multiplayer.get_unique_id())
				label.text="Win!"+label.text
		else:
			win()
	else:
		Globals.round_index+=1
#		get_tree().reload_current_scene()
		if Globals.pkMode:
			Globals.numbers=Globals.pkNumbers[Globals.round_index-1]
			Globals.solution=Globals.pkSolutions[Globals.round_index-1]
			Globals.history.clear()
		else:
			Globals.restart()
		restart()
		$HUD.restart()
@rpc("authority","call_remote","reliable")
func whoWin(secs,id)->void:
	Globals.pkWin=true
	print(id," call whoWin ",secs)
	print(multiplayer.get_unique_id())
	
func win():
	var spendt=Time.get_unix_time_from_system()-Globals.started_at
	label.text=" %d:%02d"%[int(spendt/60),int(spendt)%60]
	rounds.text=""
	if Globals.round_set>=10&&Globals.maxInt>=13:
		compareLeaderboard(spendt)
	Globals.round_index=1
	fireworks.visible=true
	var tween=get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_LINEAR)
	tween.tween_property($HUD/HBoxContainer/Label,"theme_override_colors/font_color",Color(0.93,0.2,0.2,1),1)
	tween.parallel().tween_property(sky,"modulate",Color(1,1,1,0),1)
	tween.parallel().tween_property(label,"modulate",Color(1,1,1,1),0.5)
	tween.tween_property(sky,"modulate",Color(1,1,1,0),2)
	tween.tween_property(sky,"modulate",Color(1,1,1,1),1)
	tween.parallel().tween_property(label,"modulate",Color(1,1,1,0),0.5)
	await tween.finished
	fireworks.visible=false
	Globals.restart()
	Globals.started_at=Time.get_unix_time_from_system()
#	get_tree().reload_current_scene()
	restart()
	$HUD.restart()

func compareLeaderboard(spendt):
	Globals.leaderboard[spendt]=Time.get_date_string_from_system()+" "+Time.get_time_string_from_system()
	if Globals.leaderboard.size()>7:
		var erase=[spendt]
		for k in Globals.leaderboard.keys():
			if spendt<k:
				erase.append(k)
		erase.sort_custom(func(a, b): return a > b)
		Globals.leaderboard.erase(erase[0])
		if erase[0]!=spendt:
			rounds.text="fast!"
	else:
		rounds.text="fast!"
	Globals.save_config()
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (!Globals.pkMode)||is_multiplayer_authority():
		beInRects.clear()
		collision1Rect=0
		for r in Globals.rectNumber.keys():
			if r!=null && r.collision_layer==1:
				collision1Rect+=1
				if r.beAdd:
					beAddRect=r
				elif r.beIn:
					beInRects.append(r)
					Globals.beSelectRect=r
		if collision1Rect==1:
	#		print(Globals.rectNumber.keys())
	#		print(Globals.beSelectRect)
			if Globals.rectNumber[Globals.beSelectRect]==24:
				if Globals.reloadOnce:
					Globals.reloadOnce=false
					nextRound(Globals.beSelectRect)
			elif Globals.reloadOnce:
				Globals.reloadOnce=false
				var a=label.text
				var b=rounds.text
				rounds.text=""
				label.text=str(Globals.rectNumber[Globals.beSelectRect])+" ≠ 24"
				var tween=get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_LINEAR)
				tween.tween_property(labels,"modulate",Color(1,1,1,1),3)
				tween.tween_property(label,"text",a,0)
				tween.tween_property(rounds,"text",b,0)
				
		if beInRects.size()>1:
			var minLen=INF
			var i=0
			for j in range(beInRects.size()):
				var l=beInRects[j].position.distance_squared_to(beAddRect.position)
	#			print(j,":",l,beInRects[j].position,beAddRect.position)
				if l<minLen:
					minLen=l
					i=j
			Globals.beSelectRect=beInRects[i]
			for j in range(beInRects.size()):
				if j!=i:
					beInRects[j].beSelect=false
				else:
					beInRects[j].beSelect=true		
		elif beAddRect!=null && beInRects.size()==0:
			beAddRect.beAdd=false

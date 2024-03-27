extends Node2D
@onready var globalAnimation = $AnimationPlayer
@onready var color_rect = $CanvasLayer/ColorRect
signal genSolution

const CONFIG_PATH="user://settings.cfg"
const BGM_IDX=1
const SFX_IDX=2
var numbers=[]
var rectNumber={}
var nameRect={}
var beSelectRect=null   #a bug ,not consider touch can multi beAdd rects
var operatorIndex:=0
var history:=[]
var historyIndex:=0
var solution={}:
	set(v):
		solution=v
		genSolution.emit()
var solKey=[0,0,0,0,0]
var operatorMap={0:'+',1:'-',2:'×',3:'÷'}
var started_at:float=Time.get_unix_time_from_system()
var pause_sec:float=0
var round_index:int=1
var peer_round:int=1
var round_set:int=1
var leaderboard={}
var reloadOnce=true
var maxInt:int=13
var aniTime:float=0.5
var musics=[preload("res://res/audio/joshua-mclean_air.ogg"),
	preload("res://res/audio/joshua-mclean_dreams-left-behind.ogg"),
	preload("res://res/audio/joshua-mclean_inner-calm.ogg"),
	preload("res://res/audio/cannon.ogg"),
	preload("res://res/audio/joshua-mclean_the-well-traveled-path.ogg"),
	preload("res://res/audio/joshua-mclean_shes-all-I-need.ogg")]
var musicIndex=randi()%musics.size()
var pkMode:bool=false
var pkNumbers=[]
var pkSolutions=[]
func Calc2Num(num1,num2,opIndex):
	if opIndex==0:
		return num1+num2
	elif opIndex==1:
		return abs(num1-num2)
	elif opIndex==2:
		return num1*num2
	elif opIndex==3:
		if num1<num2:
			var t=num1
			num1=num2
			num2=t
		if num2==0||(num1%num2)!=0:
#			print(num1%num2)
			return -1
		else:
			return num1/num2
	pass
func _init():
	load_config()
#	restart()
func genPkSubject():
	pkNumbers.clear()
	pkSolutions.clear()
	for j in range(Globals.round_set-1):
		restart()
		pkNumbers.append(numbers.duplicate(true))
		pkSolutions.append(solution.duplicate(true))
	restart()
	pkNumbers.insert(0,numbers)
	pkSolutions.insert(0,solution)
	print(pkNumbers)
	print(pkSolutions)
	
func restart():
	history.clear()
	solution.clear()
	while solution.size()==0:
		numbers.clear()
		randomize()
		for i in range(4):
			numbers.append(randi()%maxInt+1)
		print(numbers)
		getAns()
#only base types (int, float, string and the vector types) are passed by value to functions (value is copied).
#Everything else (instances, arrays, dictionaries, etc) is passed as reference.
func c42(a:Array):
	var ans=[]	
	for i in range(3):
		var res=[]
		var c1=a.pop_at(i)
		res.push_back(c1)
		for j in range(i,3):
			var c2=a.pop_at(j)
			res.push_back(c2)
			ans.push_back(res+a)
			res.pop_back()
			a.insert(j,c2)
		res.pop_back()
		a.insert(i,c1)
#	print(ans)
	return ans

func getAns():
	var ANums=numbers
	ANums.sort()
	ANums.reverse()
 #	print(ANums)
	var a=range(4)
	var ans=c42(a)
	threeFloorTree(ANums,ans.slice(0,3,1,true))
	var b=[]
	for an in ans:
		b.push_back([an[0],an[1],an[3],an[2]])
	ans+=b
	fourFloorTree(ANums,ans)
	print(solution)
func generateSolution(a,b,c,d,i,j,k):
	var s=""
	if i<2&&k>1:
		s='('+str(a)+operatorMap[i]+str(b)+')'+operatorMap[k]
		solKey[4]+=1
	else:
		s=str(a)+operatorMap[i]+str(b)+operatorMap[k]
	if (j<2&&k==0)||(j>1&&k<=2):
		s+=str(c)+operatorMap[j]+str(d)
	else:
		s+='('+str(c)+operatorMap[j]+str(d)+')'
		solKey[4]+=1
	solKey[i]+=1
	solKey[j]+=1
	solKey[k]+=1
	solution[solKey]=s
	
func threeFloorTree(ANums,index):
#	print(ANums,index)
	for order in index:
		for i in range(4):
			var a=Calc2Num(ANums[order[0]],ANums[order[1]],i)
			if a<0:continue
			for j in range(4):
				var b=Calc2Num(ANums[order[2]],ANums[order[3]],j)
				if b<0:continue
				for k in range(4):
					var c=Calc2Num(a,b,k)
					if c==24:
						solKey=[0,0,0,0,0]
						if a<b:
							generateSolution(ANums[order[2]],ANums[order[3]],ANums[order[0]],ANums[order[1]],j,i,k)
						else:
							generateSolution(ANums[order[0]],ANums[order[1]],ANums[order[2]],ANums[order[3]],i,j,k)
						
func generateStr(ansStr,i,j,a,num):
	if a>=num:
		if i<2&&j>1:
			solKey[4]+=1
			return '('+ansStr+')'+operatorMap[j]+str(num)
		else:
			return ansStr+operatorMap[j]+str(num)
	else:
		if (i<2&&j==0)||(i>1&&j<=2):
			return str(num)+operatorMap[j]+ansStr
		else:
			solKey[4]+=1
			return str(num)+operatorMap[j]+'('+ansStr+')'
func fourFloorTree(ANums,index):
#	print(ANums,index)
	for order in index:
		for i in range(4):
			var a=Calc2Num(ANums[order[0]],ANums[order[1]],i)
			if a<0:continue
			for j in range(4):
				var b=Calc2Num(a,ANums[order[2]],j)
				if b<0:continue
				for k in range(4):
					var c=Calc2Num(b,ANums[order[3]],k)
					if c==24:
						solKey=[0,0,0,0,0]
						var ansStr=str(ANums[order[0]])+operatorMap[i]+str(ANums[order[1]])
						ansStr=generateStr(ansStr,i,j,a,ANums[order[2]])
						ansStr=generateStr(ansStr,j,k,b,ANums[order[3]])
						solKey[i]+=1
						solKey[j]+=1
						solKey[k]+=1
						solution[solKey]=ansStr
						
func leftIn(path):
	var tween = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_LINEAR)
	tween.tween_property($CanvasLayer/ColorRect, "material:shader_parameter/cutoff", 0, 1)
	await  tween.finished
	$CanvasLayer/ColorRect.get_material().set_shader_parameter("cutoff",1)
	get_tree().change_scene_to_file(path)

func go_to_world(path):
	globalAnimation.play("fade-in")
	await  globalAnimation.animation_finished
	get_tree().change_scene_to_file(path)
	globalAnimation.play_backwards("fade-in")

func moveTo(rect,from,to):
	if from!=to:
		var tween = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_LINEAR)
		tween.tween_property(rect, "position", to, 1)
func moveToShow(rect,from,to):
	rect.modulate=Color(1,1,1,aniTime)
	rect.scale=Vector2(0,0)
	rect.position=from+Vector2(100,100)
	var tween = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(rect, "modulate", Color(1,1,1,1), aniTime)
	tween.parallel().tween_property(rect, "scale", Vector2(1,1), aniTime)
	tween.parallel().tween_property(rect, "position", to, aniTime)
	await tween.finished
	if rect!=null:
		rect.collision_layer=1
		rect.number.collision_layer=1

func moveToHide(rect,from,to):
	rect.collision_layer=2
	rect.modulate=Color(1,1,1,1)
	rect.scale=Vector2(1,1)
	rect.position=from
	var tween = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(rect, "modulate", Color(1,1,1,0.5), aniTime)
	tween.parallel().tween_property(rect, "scale", Vector2(0,0), aniTime)
	tween.parallel().tween_property(rect, "position", to+Vector2(100,100), aniTime)
#	tween.parallel().tween_property(rect, "rotation", 2*PI, 1)
#	tween.tween_callback(rect.queue_free)
func save_config():
	var file=ConfigFile.new()
	file.set_value("option","round_set",round_set)
	file.set_value("leaderboard","leaderboard",leaderboard)
	file.set_value("audio","bgm_enabled",AudioServer.is_bus_mute(BGM_IDX))
	file.set_value("audio","sfx_enabled",AudioServer.is_bus_mute(SFX_IDX))
	file.set_value("option","language",TranslationServer.get_locale())
	file.set_value("option","maxInt",Globals.maxInt)
	var err=file.save(CONFIG_PATH)
	if err!=OK:
		push_error("Failed to save config:%d"%err)
	
func load_config():
	var file=ConfigFile.new()
	var err=file.load(CONFIG_PATH)
	if err==OK:
		round_set=file.get_value("option","round_set",1)
		leaderboard=file.get_value("leaderboard","leaderboard",{})
		AudioServer.set_bus_mute(BGM_IDX,file.get_value("audio","bgm_enabled",false))
		AudioServer.set_bus_mute(SFX_IDX,file.get_value("audio","sfx_enabled",false))
		TranslationServer.set_locale(file.get_value("option","language",OS.get_locale_language()))
		maxInt=file.get_value("option","maxInt",13)
	else:
		push_warning("Failed to load config:%d"%err)
	
# Called when the node enters the scene tree for the first time.
func _ready():
	$BGM.stream=musics[musicIndex]
	$BGM.play()

func _on_bgm_finished():
	await get_tree().create_timer(1).timeout
	musicIndex=(musicIndex+randi()%(musics.size()-1)+1)%musics.size()
	$BGM.stream=musics[musicIndex]
	$BGM.play()
	

extends Control
@onready var button = $VBoxContainer/Button
@onready var label = $VBoxContainer/Label


# Called when the node enters the scene tree for the first time.
func _ready():
	button.disabled=true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_line_edit_text_changed(new_text):
	var a:PackedStringArray=new_text.split('-')
	if a.size()==4:
		button.disabled=false
		Globals.numbers.clear()
		for aa in a:
			Globals.numbers.append(int(aa))
	else:
		button.disabled=true


func _on_button_pressed():
	showAnswer()


func _on_line_edit_text_submitted(new_text):
	showAnswer()
func showAnswer():
	Globals.solution.clear()
	Globals.getAns()
	label.text=""
	for k in Globals.solution.keys():
		label.text+=Globals.solution[k]+'\n'
	if label.text.length()==0:
		label.text="No Answer"


func _on_back_pressed():
	Globals.go_to_world("res://ui/menu.tscn")

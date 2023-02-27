extends AudioStreamPlayer


# Called when the node enters the scene tree for the first time.
func _ready():
	_button_sound(get_parent())

func _button_sound(node):
	for c in node.get_children():
		if c is Button:
			c.connect("pressed",self.play)
		else:
			_button_sound(c)

extends Node2D
@export var operator:='+'
@export var opColor:Color
@onready var mesh_instance_2d:MeshInstance2D = $MeshInstance2D

func _draw():
	draw_rect(Rect2(-60,-60,120,120),opColor)
# Called when the node enters the scene tree for the first time.
func _ready():
	self.mesh_instance_2d.mesh.text=self.operator
	#self.color_rect.color=opColor



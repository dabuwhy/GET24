extends Area2D

@onready var collision_shape_2d:CollisionShape2D = $CollisionShape2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _draw():
	draw_circle(collision_shape_2d.position,collision_shape_2d.shape.radius,Color.DARK_RED)


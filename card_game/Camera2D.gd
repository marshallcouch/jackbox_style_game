extends Camera2D


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


# Called when the node enters the scene tree for the first time.

var zoom_min = Vector2(.2,.2)
var zoom_max = Vector2(2,2)
var zoom_speed = Vector2(.2, .2)
func _input(event):
	print(event)
	if event is not InputEventMouseButton:
		return
	if not event.is_pressed():
		return
	if event.button_index == BUTTON_WHEEL_UP
		zoom < zoom_max:
			zoom = zoom-zoom_speed
	elif event.button_index == BUTTON_WHEEL_DOWN
		zoom > zoom_min:
			zoom = zoom-zoom_speed

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass

extends Camera2D

var zoom_min = Vector2(.1,.1)
var zoom_max = Vector2(2,2)
var zoom_speed = Vector2(1, 1)
var previous_mouse_position = Vector2()
var is_dragging = false
var over_something = false
var scroll_zooming_enabled = true
signal load_preloaded_deck(file_name)
signal load_deck(file_name)
const DEAD_ZONE:float = .15
const MOVE_SPEED:float = 1000


@onready var preloaded_decks_button:MenuButton = $action_panel/action_menu_button/action_menu/deck_json_popup/VBoxContainer/HBoxContainer/PreloadedDecksButton
@onready var action_menu:PopupMenu = $action_panel/action_menu_button/action_menu
func _ready() -> void:
	$action_panel/show_hide_hand_button.set_global_position(Vector2(10,get_viewport().size.y - 70))
	$player_hand.transform = Transform2D(0,Vector2(10,140))
	var ip_address:String = ""
	for address in IP.get_local_addresses():
		if (address.split('.').size() == 4):
			ip_address+=address + '\n'


	var dir = DirAccess.open("res://assets/preloaded_decks/")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if "tres" in file_name:
				preloaded_decks_button.get_popup().add_item(file_name)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
		
	preloaded_decks_button.get_popup().connect("index_pressed",Callable(self,"_preloaded_id_pressed"))
	self.connect("load_preloaded_deck",Callable(get_parent(),"_load_preloaded_deck"))
	self.connect("load_deck",Callable(get_parent(),"_load_deck"))

func _process(delta):
	if action_menu.visible:
		return
	var x_movement:float = Input.get_joy_axis(0,JOY_AXIS_LEFT_X)
	if abs(x_movement) > DEAD_ZONE:
		offset.x += (x_movement*delta*(1./zoom.x)*MOVE_SPEED)
	var y_movement:float = Input.get_joy_axis(0, JOY_AXIS_LEFT_Y)
	if abs(y_movement) > DEAD_ZONE:
		offset.y += (y_movement*delta*(1.0/zoom.x)*MOVE_SPEED)
	var zoom_amount:float = Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)
	if abs(zoom_amount) > DEAD_ZONE:
		if (zoom < zoom_max and zoom_amount <0.0) or ( zoom > zoom_min and zoom_amount >0.0):
			zoom -= zoom_speed*zoom_amount*delta

		
func _input(event):
	if event.is_action_released("reset_view") and !action_menu.visible:
		_on_recenter_button_pressed()
		
	if event.is_action_released("start"):
		action_menu.show()
	#handle dragging
	if is_dragging and event is InputEventMouseMotion:
		offset -= (event.position - previous_mouse_position) * zoom
		previous_mouse_position = event.position
		
	if not event is InputEventMouseButton:
		return
	if not event.is_pressed():
		
		#End dragging
		if event.is_action_released("ui_middle_mouse"):
			previous_mouse_position = event.position
			is_dragging = false
		return

	#start dragging
	elif event.is_action_pressed("ui_middle_mouse"):
		is_dragging = true
		previous_mouse_position = event.position


func _on_deck_change_camera_scroll(enabled) -> void:
	scroll_zooming_enabled = enabled



func _on_show_hide_hand_button_pressed() -> void:
	if $player_hand.visible:
		$player_hand.hide()
		$action_panel/show_hide_hand_button.text = "Show"
	else:
		$player_hand.show()
		$action_panel/show_hide_hand_button.text = "Hide"


func _on_recenter_button_pressed() -> void:
	drag_vertical_offset = 0
	drag_horizontal_offset = 0
	offset = Vector2.ZERO
	zoom = Vector2(1,1)


func _on_close_about_window_button_pressed() -> void:
	$action_panel/action_menu_button/action_menu/about_popup.hide()

func _preloaded_id_pressed(idx: int) -> void:
	var item:String = preloaded_decks_button.get_popup().get_item_text(idx)
	print_debug(item)
	emit_signal("load_preloaded_deck",item)


func _on_LoadFileButton_pressed() -> void:
	$action_panel/action_menu_button/action_menu/deck_json_popup/OpenDeckDialog.show()


func _on_OpenDeckDialog_file_selected(path: String) -> void:
	$action_panel/action_menu_button/action_menu/deck_json_popup.hide()
	emit_signal("load_deck",path)


func _on_deck_json_popup_close_requested():
	$action_panel/action_menu_button/action_menu/deck_json_popup.hide() # Replace with function body.

signal remove_qr_code
func _on_action_menu_remove_qr_code():
	remove_qr_code.emit()
	
func remove_qr_code_option():
	$action_panel/action_menu_button/action_menu.remove_qr_code_option()

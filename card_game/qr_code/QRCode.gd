extends Control
class_name QRCode

# Called when the node enters the scene tree for the first time.
func _ready():
	show_qr("http://" + get_ip_address() + ":1088")



func get_ip_address() -> String:
	var addresses = IP.get_local_addresses()
	var all_addresses:String = ""
	for addr in addresses:
		all_addresses += addr + "\n"
	#print(addresses)
	if OS.get_name() == "Windows":
		return addresses[addresses.size()-1]
	else:
		return addresses[0]
	return all_addresses
	

func show_qr(str:String = "1"):
	var qr_code:QrCode = QrCode.new()
	qr_code.error_correct_level = QrCode.ErrorCorrectionLevel.MEDIUM
	for child in get_children():
		child.queue_free()
	var texture:ImageTexture = qr_code.get_texture(str)
	var texture_rect: TextureRect = TextureRect.new()
	texture_rect.texture = texture
	add_child(texture_rect)
	texture_rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	texture_rect.set_size(Vector2(400,400))
	#texture_rect.set_position(Vector2((size.x*.5),0))

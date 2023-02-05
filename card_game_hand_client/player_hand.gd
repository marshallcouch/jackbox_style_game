extends Control


var hand_array : Array

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().root.connect("size_changed", self, "_on_viewport_resized")
	_on_viewport_resized()
	


func _on_viewport_resized() -> void:
	var viewport_size = get_viewport().size
	$card_list.rect_size = viewport_size * Vector2(1,0.5)
	$card_preview.rect_position.y = $card_list.rect_size.y+5
	$card_preview/top_right.rect_position.x = viewport_size.x-65
	$card_preview/bottom.rect_position.y = $card_preview/top_right.rect_size.y + 10
	
	$card_preview/middle_scroller.rect_position = Vector2(10, $card_preview/bottom.rect_position.y + $card_preview/bottom.rect_size.y + 20)
	$card_preview/middle_scroller.rect_size = Vector2(viewport_size.x - 20, viewport_size.y - \
		($card_preview/middle_scroller.rect_position.y + $actions_list.rect_size.y + $card_list.rect_size.y + 40 ))
	
	$card_preview/middle_scroller/middle.rect_min_size = $card_preview/middle_scroller.rect_size - Vector2(10,10)
	
	$actions_list.rect_position = Vector2(viewport_size.x/2 - $actions_list.rect_size.x/2, viewport_size.y - ($actions_list.rect_size.y + 5))


func _on_play_button_pressed() -> void:
	for card_name in $card_list.get_selected_items():
		for i in range(0,hand_array.size()):
			if hand_array[i]["top_left"] == $card_list.get_item_text(card_name):
				hand_array.remove(i)
				$card_list.remove_item(i)
				break

	pass # Replace with function body.


func _on_deck_bottom_button_pressed() -> void:
	pass # Replace with function body.


func _on_draw_button_pressed() -> void:
	var new_card = {"top_left":"blah " + String(rand_range(1,20)), 
	"top_right":"1G",
	"middle":"the quick brown fox jumps over the lazy dog",
	}
	hand_array.append(new_card)
	$card_list.add_item(new_card["top_left"])


func _on_card_list_item_selected(index: int) -> void:
	$card_preview/top_left.text = "new" + String(rand_range(1,20))
	$card_preview/top_right.text = "new" + String(rand_range(1,20))
	$card_preview/middle_scroller/middle.text = "new" + String(rand_range(1,20))
	$card_preview/bottom.text = "new"+ String(rand_range(1,20))
	pass

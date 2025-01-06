extends Control
class_name LargeCard

func set_card_parts(tl:String, tr:String, mid:String, br:String, bl:String):
	$VBoxContainer/TopHBox/LeftLabel.text = tl
	$VBoxContainer/TopHBox/RightLabel.text = tr
	$VBoxContainer/MiddleLabel.text = mid
	$VBoxContainer/BottomHbox/LeftLabel.text = bl
	$VBoxContainer/BottomHbox/RightLabel.text = br

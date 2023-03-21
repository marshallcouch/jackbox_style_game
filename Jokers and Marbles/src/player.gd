class_name Player

var id:String
var hand: Array[String]
var name:String

func set_id():
	id = uuid.v4()

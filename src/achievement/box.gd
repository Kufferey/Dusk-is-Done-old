extends Panel

signal Change_box(_text:String, _description:String)

func _on_change_box(_text, _description) -> void:
	$_desc.text = _description
	$_name.text = _text

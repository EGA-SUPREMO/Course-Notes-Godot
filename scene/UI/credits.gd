extends Control


func _on_exit_button_pressed() -> void:
	get_parent().remove_child(self)

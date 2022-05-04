tool
extends EditorPlugin

var multi_edit_dialog

func _enter_tree():

	multi_edit_dialog = preload("res://addons/multi_scene_editor/multi_edit_dialog.tscn").instance()

	get_editor_interface().get_editor_viewport().add_child(multi_edit_dialog)

	multi_edit_dialog.set_multi_scene_edit(self)

	make_visible(false)
	pass


# Set the display visibility
func make_visible(is_visible):
	if(multi_edit_dialog):
		multi_edit_dialog.visible = is_visible
		pass
	pass

#func enable_plugin() -> void:
#
#	# TODO: Add autoload utilities script with add_autoload_singleton
#	pass

func has_main_screen():
	return true
	pass


# Sets the display name in the editor
func get_plugin_name():
	return "Multi-Scene Edit"
	pass

# Sets the icon display in the editor
func get_plugin_icon():
	return preload("res://addons/multi_scene_editor/icon.svg")


#func RequestEdit(scene_to_edit):
#	#return true
#	pass

	
func _exit_tree():
	if(multi_edit_dialog):
		multi_edit_dialog.free()
		pass
	pass

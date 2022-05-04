tool
extends "res://addons/multi_scene_editor/scripts/base_operation.gd"

export var node_name_to_remove_label_path:NodePath
var node_name_to_remove_label

func _enter_tree():
	node_name_to_remove_label = get_node(node_name_to_remove_label_path)
	
	if(!node_name_to_remove_label.is_connected("text_changed",self,"VerifyInput")):
		var _connection = node_name_to_remove_label.connect("text_changed",self,"VerifyInput")
		pass

		verify_input("")
	pass


func get_operation_parameters():
	var parameters = {}
	parameters['operation_type'] = "remove"
	parameters["node_name_to_remove"] = node_name_to_remove_label.text

	return parameters
	pass

func verify_input(var _nullargs):
	is_operation_valid  = false
	if(node_name_to_remove_label.text == ""):
		is_operation_valid = false
		error_label.text = "ERROR: Node Name Not Defined"
		error_label.visible = true
		return
		pass


	# All checks have passed, operation is valid
	is_operation_valid = true
	error_label.visible = false
	pass

func remove_button_pressed():
	self.queue_free()
	pass
	
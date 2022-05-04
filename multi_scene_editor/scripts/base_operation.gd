tool
extends Node

var is_operation_valid = false

export var error_label_path:NodePath
var error_label

func _enter_tree():
	error_label = get_node(error_label_path)
	if(error_label != null):
		error_label.visible = false
		pass
	#print("Base operation initalized")
	pass


func _get_operation_parameters():
	# NO-OP
	pass

# Returns bool indicating if all values in the operation valid
func get_is_operation_valid()-> bool: return is_operation_valid


func _verify_input():
	# NO-OP
	pass

func remove_button_pressed():
	self.queue_free()
	pass
	
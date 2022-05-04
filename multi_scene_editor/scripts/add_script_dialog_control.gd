tool
extends "res://addons/multi_scene_editor/scripts/base_operation.gd"

# References
var add_to_root_check:CheckBox
var non_root_add

export var script_to_add_label_path:NodePath
var script_to_add_label:LineEdit

export var set_added_script_button_path:NodePath
var set_added_script_button:Button

# Data fields 
export(Dictionary) var data_input_fields = {}
export(Dictionary) var data_toggles = {}

export var non_root_add_error_path:NodePath
var non_root_add_error_item:OptionButton

export var remove_operation_path:NodePath
var remove_operation

signal open_file_pressed(filters,selection_mode)

func _enter_tree():
	script_to_add_label = get_node(script_to_add_label_path)
	non_root_add = $MarginContainer/Wrapper/Body/Parameters/NonRootAdd
	add_to_root_check = $MarginContainer/Wrapper/Body/Parameters/AddToRoot
	non_root_add_error_item = get_node(non_root_add_error_path)
	set_added_script_button = get_node(set_added_script_button_path)

	remove_operation = get_node(remove_operation_path)

	add_to_root_check.pressed = true
	non_root_add.visible = false


	# Signals
	var _connection = add_to_root_check.connect("toggled",self,"add_to_root_changed")
	_connection = remove_operation.connect("pressed",self,"remove_button_pressed")
	_connection = set_added_script_button.connect("pressed",self,"open_file_pressed")
	_connection = get_node(data_input_fields["non_root_add_name"]).connect("text_changed",self,"verify_input")


	verify_input("")
	pass

# Get the parameters for this operation
func get_operation_parameters():
	var parameters = {}
	parameters['operation_type'] = "add_script"
	parameters['script_path'] = script_to_add_label.text
	parameters['add_to_root'] = get_node(data_toggles['add_to_root']).pressed
	parameters['non_root_add_name'] = get_node(data_input_fields["non_root_add_name"]).text

	var non_root_failure_choice = "exit" if non_root_add_error_item.selected == 0 else "add_to_root"
	parameters['non_root_add_error'] = non_root_failure_choice
	
	return parameters
	pass


func open_file_pressed():
	emit_signal("open_file_pressed",["*.gd"],0)
	pass


func return_file_dialog_path(file_path):
	script_to_add_label.text = file_path
	verify_input(null)
	return

func verify_input(var _nullargs):
	is_operation_valid = false
	# Perform Checks

	if(script_to_add_label.text ==""):
		error_label.text = "ERROR: No script path defined!"
		error_label.visible = true
		return

	# Check non-root
	if(!get_node(data_toggles["add_to_root"]).pressed && get_node(data_input_fields["non_root_add_name"]).text == ""):
		error_label.text = "ERROR: No non-root node name defined!"
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
	

func add_to_root_changed(is_checked:bool):
	non_root_add.visible = !is_checked
	verify_input("")
	pass